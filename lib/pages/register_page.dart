import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/login/register_bloc.dart';
import 'package:kendedes_mobile/bloc/login/register_event.dart';
import 'package:kendedes_mobile/bloc/login/register_state.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user_role.dart';
import 'package:kendedes_mobile/pages/home_page.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';

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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Masukkan email Anda',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: widget.email == null,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Nama Lengkap'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        onChanged: (value) {
                          _registerBloc.add(UpdateNameField(name: value));
                        },
                        hint: 'Masukkan nama lengkap Anda',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Satker'),
                      const SizedBox(height: 8),
                      _buildDropdown<Organization>(
                        value: state.data.organization,
                        items: Organization.staticOrganizations,
                        hint: 'Petugas dari Satker Mana?',
                        icon: Icons.badge_outlined,
                        itemLabel: (org) => '[${org.shortCode}] ${org.name}',
                        onChanged:
                            (value) => _registerBloc.add(
                              ChangeOrganizationField(organization: value),
                            ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Role'),
                      const SizedBox(height: 8),
                      _buildDropdown<UserRole>(
                        value: state.data.role,
                        items: UserRole.staticUserRoles,
                        hint: 'Pilih Role Pengguna',
                        icon: Icons.manage_accounts_outlined,
                        itemLabel: (role) => role.name,
                        onChanged:
                            (value) => _registerBloc.add(
                              ChangeUserRoleField(role: value),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildRegisterButton(isLoading: state.data.isLoading),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: !enabled ? Colors.grey.shade200 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !enabled ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        enabled: enabled,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: !enabled ? Colors.grey.shade500 : Colors.grey.shade900,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: !enabled ? Colors.grey.shade400 : Colors.orange.shade600,
          ),
          suffixIcon:
              !enabled
                  ? Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required IconData icon,
    required String Function(T) itemLabel,
    required void Function(T) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 20, color: Colors.orange.shade600),
              const SizedBox(width: 12),
              Text(
                hint,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ],
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade500,
          ),
          borderRadius: BorderRadius.circular(12),
          items:
              items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Text(
                        itemLabel(item),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (item) => onChanged(item as T),
        ),
      ),
    );
  }

  Widget _buildRegisterButton({bool isLoading = false}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade600, Colors.orange.shade500],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap:
              isLoading
                  ? null
                  : () {
                    _registerBloc.add(Register());
                  },
          child: Center(
            child:
                isLoading
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                    : const Text(
                      'Daftar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
