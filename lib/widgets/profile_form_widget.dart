import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user_role.dart';

class ProfileFormWidget extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final Organization? selectedOrganization;
  final UserRole? selectedRole;
  final Function(String) onNameChanged;
  final Function(Organization) onOrganizationChanged;
  final Function(UserRole) onRoleChanged;
  final bool isLoading;
  final Function() onActionPressed;
  final String actionLabel;
  final double contentPadding;
  final double formPadding;
  final List<Organization> organizations;
  final List<UserRole> userRoles;
  final bool hideUserRoleField;
  final bool hideOrganizationField;

  const ProfileFormWidget({
    super.key,
    required this.emailController,
    required this.nameController,
    this.selectedOrganization,
    this.selectedRole,
    required this.onNameChanged,
    required this.onOrganizationChanged,
    required this.onRoleChanged,
    required this.isLoading,
    required this.onActionPressed,
    required this.actionLabel,
    this.contentPadding = 24,
    this.formPadding = 24,
    required this.organizations,
    required this.userRoles,
    this.hideUserRoleField = false,
    this.hideOrganizationField = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(contentPadding),
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
            padding: EdgeInsets.all(formPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Email'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: emailController,
                  hint: 'Masukkan email Anda',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                _buildSectionLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: nameController,
                  onChanged: onNameChanged,
                  hint: 'Masukkan nama lengkap Anda',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                if (!hideOrganizationField) ...[
                  _buildSectionLabel('Satker'),
                  const SizedBox(height: 8),
                  _buildDropdown<Organization>(
                    value: selectedOrganization,
                    items: organizations,
                    hint: 'Petugas dari Satker Mana?',
                    icon: Icons.badge_outlined,
                    itemLabel: (org) => '[${org.shortCode}] ${org.name}',
                    onChanged: onOrganizationChanged,
                  ),
                ],
                const SizedBox(height: 20),
                if (!hideUserRoleField) ...[
                  _buildSectionLabel('Role'),
                  const SizedBox(height: 8),
                  _buildDropdown<UserRole>(
                    value: selectedRole,
                    items: userRoles,
                    hint: 'Pilih Role Pengguna',
                    icon: Icons.manage_accounts_outlined,
                    itemLabel: (role) => role.name,
                    onChanged: onRoleChanged,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(isLoading: isLoading),
        ],
      ),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      padding: EdgeInsets.zero,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.only(left: 14, right: 8),
          hint: Row(
            children: [
              Icon(icon, size: 20, color: Colors.orange.shade600),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  hint,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
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
                      Expanded(
                        child: Text(
                          itemLabel(item),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildActionButton({bool isLoading = false}) {
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
                    onActionPressed();
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
                    : Text(
                      actionLabel,
                      style: const TextStyle(
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
