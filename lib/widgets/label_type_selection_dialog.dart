import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/label_type.dart';

class LabelTypeSelectionDialog extends StatefulWidget {
  final LabelType? selectedLabelType;
  final void Function(LabelType labelType) onLabelTypeSelected;
  final List<LabelType> labelTypes;

  const LabelTypeSelectionDialog({
    super.key,
    this.selectedLabelType,
    required this.onLabelTypeSelected,
    required this.labelTypes,
  });

  @override
  State<LabelTypeSelectionDialog> createState() =>
      _LabelTypeSelectionDialogState();
}

class _LabelTypeSelectionDialogState extends State<LabelTypeSelectionDialog> {
  LabelType? _selectedLabelType;

  @override
  void initState() {
    super.initState();
    _selectedLabelType = widget.selectedLabelType;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.label,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pilih Jenis Label',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih label yang akan ditampilkan pada marker:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            RadioGroup<LabelType>(
              groupValue: _selectedLabelType,
              onChanged: (value) {
                setState(() {
                  _selectedLabelType = value;
                });
              },
              child: Column(
                children:
                    widget.labelTypes.map((labelType) {
                      final isSelected =
                          _selectedLabelType?.key == labelType.key;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.green.shade300
                                    : Colors.grey.shade300,
                          ),
                          color:
                              isSelected
                                  ? Colors.green.shade50
                                  : Colors.transparent,
                        ),
                        child: RadioListTile<LabelType>(
                          value: labelType,
                          title: Text(
                            labelType.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color:
                                  isSelected
                                      ? Colors.green.shade700
                                      : Colors.black87,
                            ),
                          ),
                          activeColor: Colors.green,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _selectedLabelType != null
                            ? () {
                              widget.onLabelTypeSelected(_selectedLabelType!);
                              Navigator.of(context).pop();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
