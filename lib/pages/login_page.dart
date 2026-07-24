import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/login/login_bloc.dart';
import 'package:kendedes_mobile/bloc/login/login_event.dart';
import 'package:kendedes_mobile/bloc/login/login_state.dart';
import 'package:kendedes_mobile/classes/app_config.dart';
import 'package:kendedes_mobile/pages/home_page.dart';
import 'package:kendedes_mobile/pages/register_page.dart';
import 'package:kendedes_mobile/widgets/other_widgets/loading_scaffold.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AppLinks _appLinks = AppLinks();
  late final LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = context.read<LoginBloc>();
    _listenToDeepLinks();
  }

  void _listenToDeepLinks() {
    _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          final encodedData = uri.queryParameters['data'];
          if (encodedData != null) {
            try {
              final decodedJson = utf8.decode(base64.decode(encodedData));
              final jsonMap = json.decode(decodedJson);

              if (jsonMap is Map<String, dynamic> &&
                  jsonMap.containsKey('token') &&
                  jsonMap.containsKey('user')) {
                final token = jsonMap['token'];
                final user = jsonMap['user'];
                _loginBloc.add(LoginMajapahit(token: token, user: user));
              } else {
                _loginBloc.add(
                  ThrowLoginError(
                    'Deep link data tidak valid: key "token" atau "user" tidak ditemukan',
                  ),
                );
              }
            } catch (e) {
              _loginBloc.add(
                ThrowLoginError('Failed to decode deep link data: $e'),
              );
            }
          }
        }
      },
      onError: (err) {
        _loginBloc.add(ThrowLoginError('Failed to listen to deep links: $err'));
      },
    );
  }

  Future<void> _openSSOLogin() async {
    final ssoUrl = AppConfig.majapahitLoginUrl;

    // const chromePackage = 'com.android.chrome';

    if (await canLaunchUrl(Uri.parse(ssoUrl))) {
      await launchUrl(
        Uri.parse(ssoUrl),
        mode: LaunchMode.externalApplication,
        // webOnlyWindowName: chromePackage,
      );
    } else {
      _loginBloc.add(ThrowLoginError('Pastikan menggunakan Google Chrome'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          // Navigate to the home page or dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else if (state is LoginFailed) {
          showDialog(
            context: context,
            builder:
                (context) => MessageDialog(
                  title: 'Login Gagal',
                  message: state.errorMessage,
                  type: MessageType.error,
                  buttonText: 'Ok',
                ),
          );
        } else if (state is RedirectToRegister) {
          // go to register page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      RegisterPage(email: state.email, name: state.name),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is Initializing) {
          return LoadingScaffold(
            title: 'Menyiapkan aplikasi...',
            subtitle: 'Mohon tunggu sebentar',
          );
        } else if (state is LoginSuccess) {
          return LoadingScaffold(
            title: 'Login Berhasil',
            subtitle: 'Mengalihkan ke halaman utama...',
          );
        }
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // App Icon and Logo
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'images/icon.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Image.asset(
                                'images/long_icon.png',
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Title and Subtitle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kendedes',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Mobile',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                          // --- Slogan ---
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tag Anywhere. ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Discover Everywhere.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          // --- End Slogan ---
                          const SizedBox(height: 32),

                          // --- Login Options ---
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _openSSOLogin();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4B3FAE),
                                          Color(0xFF2196F3),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Container(
                                      height: 48,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Image.asset(
                                                'images/logo-majapahit.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Login with ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Text(
                                            'Majapahit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // --- OR Divider ---
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  endIndent: 8,
                                ),
                              ),
                              Text(
                                'atau login dengan Email & Password',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  indent: 8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // --- End Login Options ---

                          // --- Compact Login Form ---
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Email Field
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'Email',
                                              labelStyle: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.email_outlined,
                                                color: Colors.grey.shade400,
                                                size: 20,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.orange.shade400,
                                                  width: 2,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.red.shade400,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              errorText: state.data.email.error,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                            ),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            onChanged:
                                                (value) => _loginBloc.add(
                                                  LoginEmailChanged(value),
                                                ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Password Field
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              labelStyle: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.lock_outline,
                                                color: Colors.grey.shade400,
                                                size: 20,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.orange.shade400,
                                                  width: 2,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.red.shade400,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              errorText:
                                                  state.data.password.error,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  state.data.obscurePassword
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  color: Colors.grey.shade400,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  _loginBloc.add(
                                                    ToggleObscurePassword(),
                                                  );
                                                },
                                              ),
                                            ),
                                            obscureText:
                                                state.data.obscurePassword,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            onChanged:
                                                (value) => _loginBloc.add(
                                                  LoginPasswordChanged(value),
                                                ),
                                          ),
                                          const SizedBox(height: 18),

                                          // Login Button
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.orange.shade500,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              elevation: 0,
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            onPressed:
                                                state.data.isSubmitting
                                                    ? null
                                                    : () {
                                                      _loginBloc.add(
                                                        LoginSubmitted(),
                                                      );
                                                    },
                                            child:
                                                state.data.isSubmitting
                                                    ? const SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                    )
                                                    : const Text('Login'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- OR Continue With Divider ---
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  endIndent: 8,
                                ),
                              ),
                              Text(
                                'atau lanjutkan dengan Google',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  indent: 8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // --- Google Login Button ---
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      state.data.isLoginGoogleLoading
                                          ? null
                                          : () => _loginBloc.add(
                                            const LoginGoogle(),
                                          ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.03,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Image.asset(
                                            'images/google.ico',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                        // ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // --- End Google Login Button ---
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.data.isLoginGoogleLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
