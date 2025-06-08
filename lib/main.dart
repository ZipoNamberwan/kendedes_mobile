import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/bloc/login/login_bloc.dart';
import 'package:kendedes_mobile/bloc/login/login_event.dart';
import 'package:kendedes_mobile/bloc/project/project_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/hive/hive_registrar.g.dart';
import 'package:path_provider/path_provider.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationDocumentsDirectory();
  Hive
    ..init(appDir.path)
    ..registerAdapters();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc()..add(MockupLogin()),
        ),
        BlocProvider<ProjectBloc>(create: (context) => ProjectBloc()),
        BlocProvider<TaggingBloc>(create: (context) => TaggingBloc()),
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
