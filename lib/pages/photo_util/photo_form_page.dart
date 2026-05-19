import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_bloc.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_event.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_state.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';
import 'package:kendedes_mobile/pages/photo_util/photo_result_preview.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';

class PhotoFormPage extends StatefulWidget {
  const PhotoFormPage({super.key});

  @override
  State<PhotoFormPage> createState() => _PhotoFormPageState();
}

class _PhotoFormPageState extends State<PhotoFormPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  late final PhotoUtilBloc _photoUtilBloc;

  Future<void> _takePhoto(PhotoType type) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null) return;

    _photoUtilBloc.add(SetPhotoFileField(key: type.key, xFile: file));
  }

  void _showPhotoDetail(PhotoType type, XFile photo) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade600,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_camera_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          type.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Photo
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Image.file(File(photo.path), fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _photoUtilBloc = context.read<PhotoUtilBloc>()..add(Initialize());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhotoUtilBloc, PhotoUtilState>(
      listener: (context, state) {
        if (state is SaveFailed) {
          showDialog(
            context: context,
            builder:
                (context) => MessageDialog(
                  title: 'Gagal Menyimpan',
                  message: state.errorMessage,
                  type: MessageType.error,
                  buttonText: 'Ok',
                ),
          );
        } else if (state is SaveSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PhotoResultPreview()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.deepOrange.shade600,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Data Foto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lengkapi informasi dan ambil foto',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Name field ────────────────────────────────────────────
                  _buildFieldLabel('Nama KK', Icons.person_rounded),
                  const SizedBox(height: 8),
                  _buildTextField(
                    fieldKey: 'name',
                    controller: _nameController,
                    hint: 'Masukkan nama...',
                    textInputAction: TextInputAction.next,
                    onChanged:
                        (key, value) => _photoUtilBloc.add(
                          SetFormField(key: key, value: value),
                        ),
                    errorText: state.data.formFields['name']?.error,
                  ),
                  const SizedBox(height: 24),

                  // ── Address field ─────────────────────────────────────────
                  _buildFieldLabel(
                    'Identitas Wilayah',
                    Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    fieldKey: 'address',
                    controller: _addressController,
                    hint:
                        'Masukkan identitas wilayah seperti RT/RW, Desa, Kecamatan...',
                    textInputAction: TextInputAction.done,
                    onChanged:
                        (key, value) => _photoUtilBloc.add(
                          SetFormField(key: key, value: value),
                        ),
                    errorText: state.data.formFields['area']?.error,
                  ),

                  const SizedBox(height: 24),

                  // ── Photo Type Cards ──────────────────────────────────────
                  _buildFieldLabel('Ambil Foto', Icons.camera_alt_rounded),
                  const SizedBox(height: 12),
                  Row(
                    children:
                        PhotoType.values
                            .map(
                              (type) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        PhotoType.values.indexOf(type) == 0
                                            ? 8
                                            : 0,
                                    left:
                                        PhotoType.values.indexOf(type) == 1
                                            ? 8
                                            : 0,
                                  ),
                                  child: _buildPhotoTypeCard(
                                    type: type,
                                    photo:
                                        state.data.formFields[type.key]?.value
                                            as XFile?,
                                    errorText:
                                        state.data.formFields[type.key]?.error,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 32),

                  // ── Save Button ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          state.data.isLoading
                              ? null
                              : () {
                                _photoUtilBloc.add(const SaveForm());
                              },
                      icon:
                          state.data.isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(Icons.save_rounded, size: 20),
                      label: Text(
                        state.data.isLoading ? 'Menyimpan...' : 'Simpan Data',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoTypeCard({
    required PhotoType type,
    XFile? photo,
    String? errorText,
  }) {
    final hasPhoto = photo != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPhoto ? Colors.green.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo preview area
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onTap: hasPhoto ? () => _showPhotoDetail(type, photo) : null,
              child: Container(
                height: 120,
                color: Colors.grey.shade100,
                child:
                    hasPhoto
                        ? Stack(
                          children: [
                            Image.file(
                              File(photo.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 120,
                            ),
                            // Overlay indicator for tap
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.zoom_in_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Belum diambil',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Label
          Text(
            type.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _takePhoto(type);
              },
              icon: Icon(
                hasPhoto ? Icons.refresh_rounded : Icons.camera_enhance_rounded,
                size: 16,
              ),
              label: Text(
                hasPhoto ? 'Ulangi' : 'Ambil',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    hasPhoto
                        ? Colors.orange.shade600
                        : Colors.deepOrange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText,
              style: TextStyle(fontSize: 11, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.deepOrange.shade600),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String fieldKey,
    required Function(String, String) onChanged,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputAction textInputAction = TextInputAction.done,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
      onChanged: (value) => onChanged(fieldKey, value),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        errorText: errorText,
      ),
    );
  }
}
