import 'package:flutter/material.dart';

class LabelTypeSelectionDialog extends StatefulWidget {
  final String? selectedLabelType;
  final void Function(String labelType) onLabelTypeSelected;
  final Map<String, String> labelTypes;

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
  String? _selectedLabelType;

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
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.label,
                    color: Colors.orange.shade600,
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
              'Pilih informasi yang akan ditampilkan pada marker:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Column(
              children:
                  widget.labelTypes.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _selectedLabelType == entry.key
                                  ? Colors.orange.shade300
                                  : Colors.grey.shade300,
                        ),
                        color:
                            _selectedLabelType == entry.key
                                ? Colors.orange.shade50
                                : Colors.transparent,
                      ),
                      child: RadioListTile<String>(
                        value: entry.key,
                        groupValue: _selectedLabelType,
                        onChanged: (value) {
                          setState(() {
                            _selectedLabelType = value;
                          });
                        },
                        title: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                _selectedLabelType == entry.key
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color:
                                _selectedLabelType == entry.key
                                    ? Colors.orange.shade700
                                    : Colors.black87,
                          ),
                        ),
                        activeColor: Colors.orange,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                      ),
                    );
                  }).toList(),
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
                      backgroundColor: Colors.orange,
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
