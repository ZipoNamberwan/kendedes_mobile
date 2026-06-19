import 'package:flutter/material.dart';

class DeleteFamiliesDialog extends StatelessWidget {
  final int selectedCount;
  final bool isDeleteLoading;
  final Function onDelete;

  const DeleteFamiliesDialog({
    super.key,
    required this.selectedCount,
    required this.isDeleteLoading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Konfirmasi Hapus',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text('Apakah akan menghapus $selectedCount foto keluarga?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (!isDeleteLoading) {
              onDelete();
            }
          },
          child:
              isDeleteLoading
                  ? const CircularProgressIndicator()
                  : const Text('Ya, Hapus'),
        ),
      ],
    );
  }
}
