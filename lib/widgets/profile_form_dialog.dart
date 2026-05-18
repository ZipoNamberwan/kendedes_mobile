import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/login/register_bloc.dart';
import 'package:kendedes_mobile/bloc/login/register_event.dart';
import 'package:kendedes_mobile/bloc/login/register_state.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:kendedes_mobile/models/user_role.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:kendedes_mobile/widgets/profile_form_widget.dart';

class ProfileFormDialog extends StatefulWidget {
  final User user;

  const ProfileFormDialog({super.key, required this.user});

  @override
  State<ProfileFormDialog> createState() => _ProfileFormDialogState();
}

class _ProfileFormDialogState extends State<ProfileFormDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  late final RegisterBloc _registerBloc;
  @override
  void initState() {
    super.initState();
    _registerBloc =
        context.read<RegisterBloc>()..add(
          InitFields(
            email: widget.user.email,
            name: widget.user.firstname,
            organization: Organization.getById(
              widget.user.organization?.id ?? '',
            ),
            role:
                widget.user.roles.isNotEmpty
                    ? UserRole.getByName(widget.user.roles.first.name)
                    : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 20,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      contentPadding: const EdgeInsets.all(0),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            child: Icon(
              Icons.manage_accounts_rounded,
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Ubah Profil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is FieldsInitialized) {
            emailController.text = state.data.email ?? '';
            nameController.text = state.data.name ?? '';
          } else if (state is RegisterSuccess) {
            // Navigate to the home page or dashboard
            Navigator.pop(context);
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
          return ProfileFormWidget(
            emailController: emailController,
            nameController: nameController,
            selectedOrganization: state.data.organization,
            selectedRole: state.data.role,
            onNameChanged: (name) {
              _registerBloc.add(UpdateNameField(name: name));
            },
            onOrganizationChanged: (org) {
              _registerBloc.add(ChangeOrganizationField(organization: org));
            },
            onRoleChanged: (role) {
              _registerBloc.add(ChangeUserRoleField(role: role));
            },
            isLoading: state.data.isLoading,
            onActionPressed:
                () => _registerBloc.add(
                  ChangeProfile(
                    hideOrganization: widget.user.isAdminProv,
                    hideRole: widget.user.shouldHideRoleField,
                  ),
                ),
            actionLabel: 'Simpan',
            contentPadding: 16,
            formPadding: 8,
            organizations: Organization.staticOrganizations,
            userRoles: UserRole.getNonAdminRoles(),
            hideUserRoleField: widget.user.shouldHideRoleField,
            hideOrganizationField: widget.user.isAdminProv,
          );
        },
      ),
    );
  }
}
