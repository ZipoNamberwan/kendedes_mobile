import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/login/login_bloc.dart';
import 'package:kendedes_mobile/bloc/login/login_event.dart';
import 'package:kendedes_mobile/bloc/login/logout_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/version/version_bloc.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/local_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/organization_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/project_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/tagging_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/project_repository.dart';
import 'package:kendedes_mobile/classes/repositories/tagging_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/user_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/user_role_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/version_checking_repository.dart';
import 'package:kendedes_mobile/classes/telegram_logger.dart';
import 'pages/login_page.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    TelegramLogger.send('''🚨 *Flutter Error*

    *Exception:* `${details.exception}`
    *Library:* `${details.library}`
    *Stack Trace:*
    ${details.stack.toString().substring(0, 1000)}

    ''');
    FlutterError.presentError(details);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _initializeApp();
      runApp(MyApp());
    },
    (Object error, StackTrace stack) {
      TelegramLogger.send('''🚨 *Unhandled Dart Error*

      *Error:* `${error.toString()}`
      *Stack Trace:*
      ${stack.toString().substring(0, 1000)}

      ''');
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc()..add(InitLogin()),
        ),
        BlocProvider<ProjectBloc>(create: (context) => ProjectBloc()),
        BlocProvider<TaggingBloc>(create: (context) => TaggingBloc()),
        BlocProvider<LogoutBloc>(create: (context) => LogoutBloc()),
        BlocProvider<VersionBloc>(create: (context) => VersionBloc()),
      ],
      child: MaterialApp(
        title: 'Kendedes Mobile',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const LoginPage(),
      ),
    );
  }
}
