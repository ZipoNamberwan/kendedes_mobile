import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/version/version_event.dart';
import 'package:kendedes_mobile/bloc/version/version_state.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/repositories/version_checking_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionBloc extends Bloc<VersionEvent, VersionState> {
  VersionBloc() : super(CheckVersionInitializing()) {
    on<CheckVersion>((event, emit) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      // Emit the current version name
      final currentVersionName = packageInfo.version;
      emit(
        VersionState(
          data: state.data.copyWith(currentVersionName: currentVersionName),
        ),
      );

      final now = DateTime.now();
      final lastCheckMillis = VersionCheckingRepository().getLastCheckVersion();

      if (lastCheckMillis != null) {
        final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckMillis);
        if (now.difference(lastCheck).inHours < 3) {
          return;
        }
      }

      await ApiServerHandler.run(
        action: () async {
          // Check for updates
          int buildNumber = int.parse(packageInfo.buildNumber);
          final organization =
              AuthRepository().getUser().organization?.id ?? '3500';
          final response = await VersionCheckingRepository().checkForUpdates(
            buildNumber,
            organization,
          );

          if (response['shouldUpdate'] == true) {
            emit(
              UpdateNotification(
                data: VersionStateData(
                  shouldUpdate: true,
                  newVersion: response['version'],
                  currentVersionName: currentVersionName,
                ),
              ),
            );
          } else {
            // Save last check
            await VersionCheckingRepository().saveLastCheckVersion(
              now.millisecondsSinceEpoch,
            );
          }
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {},
        onOtherError: (e) {},
      );
    });

    on<ShowBrowserError>((event, emit) async {
      emit(
        BrowserWontOpen(
          errorTitle: 'Chrome Tidak Mau Terbuka',
          errorSubtitle:
              'Silakan buka saja s.bps.go.id/kendedes, kemudian download apk nya dan install. Tidak perlu uninstall langsung timpa saja.',
          data: state.data,
        ),
      );
      emit(VersionState(data: state.data));
    });
  }
}
