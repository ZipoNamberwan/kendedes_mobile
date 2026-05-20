import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_bloc.dart';
import 'package:kendedes_mobile/bloc/login/login_bloc.dart';
import 'package:kendedes_mobile/bloc/login/login_event.dart';
import 'package:kendedes_mobile/bloc/login/logout_bloc.dart';
import 'package:kendedes_mobile/bloc/login/register_bloc.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_bloc.dart';
import 'package:kendedes_mobile/bloc/polygon/polygon_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/version/version_bloc.dart';
import 'package:kendedes_mobile/bloc/home/home_bloc.dart';
import 'package:kendedes_mobile/bloc/version/version_event.dart';
import 'package:kendedes_mobile/bloc/version/version_state.dart';
import 'package:kendedes_mobile/classes/app_config.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/repositories/browse_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/area_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/browse_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/local_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/organization_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/photo_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/polygon_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/project_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/tagging_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/polygon_repository.dart';
import 'package:kendedes_mobile/classes/repositories/project_repository.dart';
import 'package:kendedes_mobile/classes/repositories/tagging_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/user_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/user_role_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/version_checking_repository.dart';
import 'package:kendedes_mobile/classes/telegram_logger.dart';
import 'package:kendedes_mobile/models/version.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:kendedes_mobile/widgets/version_update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  FlutterError.onError = (FlutterErrorDetails details) {
    try {
      final fullStack = details.stack.toString();
      final truncatedStack =
          fullStack.length > AppConfig.stackTraceLimitCharacter
              ? fullStack.substring(0, AppConfig.stackTraceLimitCharacter)
              : fullStack;

      final exceptionMessage = details.exception.toString();

      final ignoreKeywords = ['tile.openstreetmap.org', 'www.google.com/maps'];

      final shouldIgnore = ignoreKeywords.any(
        (keyword) => exceptionMessage.contains(keyword),
      );

      if (shouldIgnore) return;

      TelegramLogger.send('''🚨 *Flutter Error*

*Exception:* `$exceptionMessage`
*Library:* `${details.library}`
*Stack Trace:*
$truncatedStack
''');
    } catch (_) {}

    FlutterError.presentError(details);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ADD THIS
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await _initializeApp();

      runApp(MyApp());
    },
    (Object error, StackTrace stack) {
      try {
        final fullTrace = stack.toString();
        final truncatedTrace =
            fullTrace.length > AppConfig.stackTraceLimitCharacter
                ? fullTrace.substring(0, AppConfig.stackTraceLimitCharacter)
                : fullTrace;

        final user = AuthRepository().getUser();

        final userInfo =
            user.id != ''
                ? 'ID: ${user.id}, Name: ${user.firstname}, Email: ${user.email}, Organization: ${user.organization?.name ?? 'N/A'}'
                : 'User is null';

        final logMessage = '''
🚨 *Unhandled Dart Error*

*Error:* `${error.toString()}`
*User Info:* $userInfo
*Stack Trace:*
$truncatedTrace
''';

        TelegramLogger.send(logMessage);
      } catch (_) {}
    },
  );
}

Future<void> _initializeApp() async {
  await AuthRepository().init();
  await ProjectRepository().init();
  await TaggingRepository().init();
  await VersionCheckingRepository().init();
  await LocalDbRepository().init();
  await OrganizationDbRepository().init();
  await UserRoleDbRepository().init();
  await UserDbRepository().init();
  await ProjectDbRepository().init();
  await TaggingDbRepository().init();
  await PolygonDbRepository().init();
  await AreaDbRepository().init();
  await PolygonRepository().init();
  await BrowseRepository().init();
  await BrowseDbRepository().init();
  await PhotoDbRepository().init();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ProjectBloc _projectBloc;
  late TaggingBloc _taggingBloc;
  late LogoutBloc _logoutBloc;
  late VersionBloc _versionBloc;
  late PolygonBloc _polygonBloc;
  late BrowseBloc _browseBloc;
  late HomeBloc _homeBloc;
  late RegisterBloc _registerBloc;
  late PhotoUtilBloc _photoUtilBloc;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _projectBloc = ProjectBloc();
    _taggingBloc = TaggingBloc();
    _logoutBloc = LogoutBloc();
    _versionBloc = VersionBloc();
    _polygonBloc = PolygonBloc();
    _browseBloc = BrowseBloc();
    _homeBloc = HomeBloc();
    _registerBloc = RegisterBloc();
    _photoUtilBloc = PhotoUtilBloc();

    // Check once on cold start
    _checkForUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForUpdate();
    }
  }

  void _checkForUpdate() {
    _versionBloc.add(CheckVersion());
  }

  void _showVersionUpdateDialog(Version? newVersion) {
    final globalContext = navigatorKey.currentContext;
    if (globalContext == null) return;

    if (newVersion != null) {
      showDialog(
        context: globalContext,
        barrierDismissible: !newVersion.isMandatory,
        builder:
            (ctx) => PopScope(
              canPop: !newVersion.isMandatory,
              child: VersionUpdateDialog(
                version: newVersion,
                onUpdate: () async {
                  final updateUrl = newVersion.url ?? AppConfig.updateUrl;
                  _openUrl(updateUrl);
                },
              ),
            ),
      );
    }
  }

  void _showBrowserErrorDialog(String title, String message) {
    final globalContext = navigatorKey.currentContext;
    if (globalContext == null) return;

    showDialog(
      context: globalContext,
      builder:
          (context) => MessageDialog(
            title: title,
            message: message,
            type: MessageType.error,
            buttonText: 'Ok',
          ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _versionBloc.add(ShowBrowserError());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc()..add(InitLogin()),
        ),
        BlocProvider<ProjectBloc>(create: (context) => _projectBloc),
        BlocProvider<TaggingBloc>(create: (context) => _taggingBloc),
        BlocProvider<LogoutBloc>(create: (context) => _logoutBloc),
        BlocProvider<VersionBloc>(create: (context) => _versionBloc),
        BlocProvider<PolygonBloc>(create: (context) => _polygonBloc),
        BlocProvider<BrowseBloc>(create: (context) => _browseBloc),
        BlocProvider<HomeBloc>(create: (context) => _homeBloc),
        BlocProvider<RegisterBloc>(create: (context) => _registerBloc),
        BlocProvider<PhotoUtilBloc>(create: (context) => _photoUtilBloc),
      ],
      child: BlocListener<VersionBloc, VersionState>(
        listener: (context, versionState) {
          if (versionState is UpdateNotification) {
            _showVersionUpdateDialog(versionState.data.newVersion);
          } else if (versionState is BrowserWontOpen) {
            _showBrowserErrorDialog(
              versionState.errorTitle,
              versionState.errorSubtitle,
            );
          }
        },
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Kendedes Mobile',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: const LoginPage(),
        ),
      ),
    );
  }
}
