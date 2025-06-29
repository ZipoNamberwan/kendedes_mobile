import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class DeleteTagConfirmationDialog extends StatelessWidget {
  final TagData tagData;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeleteTagConfirmationDialog({
    super.key,
    required this.tagData,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaggingBloc, TaggingState>(
      listener: (context, state) {
        if (state is TagDeletedSuccess) {
          Navigator.of(context).pop(); // Close dialog on success
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade400,
                        Colors.red.shade500,
                        Colors.red.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child:
                            state.data.isDeletingTag
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.data.isDeletingTag
                              ? 'Menghapus Tagging...'
                              : 'Hapus Tagging',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Error message (if any)
                      if (state is TagDeletedError) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Tag info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tagData.businessName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (tagData.businessOwner != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      tagData.businessOwner!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (tagData.sector != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.business_outlined,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      tagData.sector?.text ?? '-',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirmation text
                      Text(
                        state.data.isDeletingTag
                            ? 'Sedang menghapus tagging, mohon tunggu...'
                            : 'Apakah Anda yakin ingin menghapus tagging ini? Data yang dihapus tidak dapat dikembalikan.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed:
                                  state.data.isDeletingTag
                                      ? null
                                      : () {
                                        Navigator.of(context).pop();
                                      },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor:
                                    state.data.isDeletingTag
                                        ? Colors.grey[200]
                                        : Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color:
                                      state.data.isDeletingTag
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  state.data.isDeletingTag ? null : onConfirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    state.data.isDeletingTag
                                        ? Colors.grey.shade400
                                        : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  state.data.isDeletingTag
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Menghapus...',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                      : const Text(
                                        'Hapus',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
