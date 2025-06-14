import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/map_type.dart';

class MapTypeSelectionDialog extends StatefulWidget {
  final MapType? selectedMapType;
  final void Function(MapType mapType) onMapTypeSelected;
  final List<MapType> mapTypes;

  const MapTypeSelectionDialog({
    super.key,
    this.selectedMapType,
    required this.onMapTypeSelected,
    required this.mapTypes,
  });

  @override
  State<MapTypeSelectionDialog> createState() => _MapTypeSelectionDialogState();
}

class _MapTypeSelectionDialogState extends State<MapTypeSelectionDialog> {
  MapType? _selectedMapType;

  @override
  void initState() {
    super.initState();
    _selectedMapType = widget.selectedMapType;
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
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.layers_rounded,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pilih Jenis Peta',
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
              'Pilih tampilan peta yang ingin digunakan:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Column(
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
                        groupValue: _selectedMapType,
                        onChanged: (value) {
                          setState(() {
                            _selectedMapType = value;
                          });
                        },
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
                        _selectedMapType != null
                            ? () {
                              widget.onMapTypeSelected(_selectedMapType!);
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
