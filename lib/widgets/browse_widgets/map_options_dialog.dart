import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';

class MapOptionsDialog extends StatefulWidget {
  final MapType? selectedMapType;
  final LabelType? selectedLabelType;
  final void Function(MapType mapType, LabelType labelType) onApply;
  final List<MapType> mapTypes;
  final List<LabelType> labelTypes;

  const MapOptionsDialog({
    super.key,
    this.selectedMapType,
    this.selectedLabelType,
    required this.onApply,
    required this.mapTypes,
    required this.labelTypes,
  });

  @override
  State<MapOptionsDialog> createState() => _MapOptionsDialogState();
}

class _MapOptionsDialogState extends State<MapOptionsDialog> {
  MapType? _selectedMapType;
  LabelType? _selectedLabelType;

  @override
  void initState() {
    super.initState();
    _selectedMapType = widget.selectedMapType;
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pengaturan Peta',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Map Type Section
            Row(
              children: [
                Icon(Icons.layers_rounded, size: 18, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Jenis Peta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RadioGroup<MapType>(
              groupValue: _selectedMapType,
              onChanged: (value) {
                setState(() {
                  _selectedMapType = value;
                });
              },
              child: Column(
                children:
                    widget.mapTypes.map((mapType) {
                      final isSelected = _selectedMapType?.key == mapType.key;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.blue.shade300
                                    : Colors.grey.shade300,
                          ),
                          color:
                              isSelected
                                  ? Colors.blue.shade50
                                  : Colors.transparent,
                        ),
                        child: RadioListTile<MapType>(
                          value: mapType,
                          title: Row(
                            children: [
                              Icon(
                                mapType.icon,
                                size: 20,
                                color:
                                    isSelected
                                        ? Colors.blue.shade600
                                        : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  mapType.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors.blue.shade700
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          activeColor: Colors.blue,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Label Type Section
            Row(
              children: [
                Icon(Icons.label, size: 18, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Jenis Label',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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

            // Buttons
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
                        (_selectedMapType != null && _selectedLabelType != null)
                            ? () {
                              widget.onApply(
                                _selectedMapType!,
                                _selectedLabelType!,
                              );
                              Navigator.of(context).pop();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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