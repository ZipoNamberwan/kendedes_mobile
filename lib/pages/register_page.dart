import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/login/register_bloc.dart';
import 'package:kendedes_mobile/bloc/login/register_event.dart';
import 'package:kendedes_mobile/bloc/login/register_state.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user_role.dart';
import 'package:kendedes_mobile/pages/home_page.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:kendedes_mobile/widgets/profile_form_widget.dart';

class RegisterPage extends StatefulWidget {
  final String? email;
  final String? name;
  const RegisterPage({super.key, this.email, this.name});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterBloc _registerBloc;
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _registerBloc =
        context.read<RegisterBloc>()
          ..add(InitFields(email: widget.email, name: widget.name));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is FieldsInitialized) {
          _emailController.text = state.data.email ?? '';
          _nameController.text = state.data.name ?? '';
        } else if (state is RegisterSuccess) {
          // Navigate to the home page or dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else if (state is RegisterFailed) {
          showDialog(
            context: context,
            builder:
                (context) => MessageDialog(
                  title: 'Registrasi Gagal',
                  message: state.errorMessage,
                  type: MessageType.error,
                  buttonText: 'Ok',
                ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrange.shade700,
                    Colors.deepOrange.shade400,
                    Colors.orange.shade700,
                    Colors.orange.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Daftar Akun',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lengkapi informasi untuk melanjutkan',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: ProfileFormWidget(
            emailController: _emailController,
            nameController: _nameController,
            selectedOrganization: state.data.organization,
            selectedRole: state.data.role,
            onNameChanged:
                (value) => _registerBloc.add(UpdateNameField(name: value)),
            onOrganizationChanged:
                (value) => _registerBloc.add(
                  ChangeOrganizationField(organization: value),
                ),
            onRoleChanged:
                (value) => _registerBloc.add(ChangeUserRoleField(role: value)),
            onActionPressed: () => _registerBloc.add(Register()),
            isLoading: state.data.isLoading,
            actionLabel: 'Daftar',
            organizations: Organization.staticOrganizations,
            userRoles: UserRole.getNonAdminRoles(),
          ),
        );
      },
    );
  }
}
