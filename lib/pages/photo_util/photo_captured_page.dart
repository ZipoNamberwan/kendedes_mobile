import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_bloc.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_state.dart';
import 'package:kendedes_mobile/pages/photo_util/photo_form_page.dart';

class PhotoCapturedPage extends StatefulWidget {
  /// Path to the captured image file. Pass null to show a placeholder preview.

  const PhotoCapturedPage({super.key});

  @override
  State<PhotoCapturedPage> createState() => _PhotoCapturedPageState();
}

class _PhotoCapturedPageState extends State<PhotoCapturedPage> {
  void _goToForm() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => PhotoFormPage(imagePath: widget.imagePath),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotoUtilBloc, PhotoUtilState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade600,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Foto Terambil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Periksa sebelum melanjutkan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: Colors.deepOrange.shade700,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _goToForm,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: Colors.deepOrange.shade700,
                              ),
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
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Step indicator ───────────────────────────────────────────
                _buildStepIndicator(),
                const SizedBox(height: 24),

                // ── Photo preview ────────────────────────────────────────────
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        state.data.formFields['photoFile'] != null
                            ? Hero(
                              tag: 'captured_photo',
                              child: Image.file(
                                File(
                                  state
                                          .data
                                          .formFields['photoFile']
                                          ?.value
                                          .path ??
                                      '',
                                ),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                            : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada foto',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Recapture button ─────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepOrange.shade700,
                    side: BorderSide(
                      color: Colors.deepOrange.shade300,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: Colors.deepOrange.shade700,
                  ),
                  label: Text(
                    'Ambil Ulang',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(1, 'Foto', isActive: true),
        _buildStepConnector(),
        _buildStep(2, 'Data'),
        _buildStepConnector(),
        _buildStep(3, 'Hasil'),
      ],
    );
  }

  Widget _buildStep(
    int number,
    String label, {
    bool isActive = false,
    bool isCompleted = false,
  }) {
    final color =
        isCompleted || isActive
            ? Colors.deepOrange.shade600
            : Colors.grey.shade300;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child:
                isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                      '$number',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color:
                isActive || isCompleted
                    ? Colors.deepOrange.shade600
                    : Colors.grey.shade400,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({bool isCompleted = false}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          gradient:
              isCompleted
                  ? LinearGradient(
                    colors: [
                      Colors.deepOrange.shade600,
                      Colors.orange.shade400,
                    ],
                  )
                  : null,
          color: isCompleted ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
