import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_event.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';

class TaggingFormDialog extends StatefulWidget {
  final TagData? initialTagData;
  const TaggingFormDialog({super.key, this.initialTagData});

  @override
  State<TaggingFormDialog> createState() => _TaggingFormDialogState();
}

class _TaggingFormDialogState extends State<TaggingFormDialog>
    with TickerProviderStateMixin {
  late final TaggingBloc _taggingBloc;
  final _businessNameController = TextEditingController();
  final _businessOwnerController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isCreate = true;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();

    _taggingBloc = context.read<TaggingBloc>();
    if (widget.initialTagData != null) {
      _taggingBloc.add(EditForm(tagData: widget.initialTagData!));
      _isCreate = false;
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessOwnerController.dispose();
    _businessAddressController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedTextField({
    required String fieldKey,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int delay = 0,
    String? error,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (delay * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: TextFormField(
              controller: controller,
              onChanged:
                  (value) =>
                      _taggingBloc.add(SetTaggingFormField(fieldKey, value)),
              maxLines: maxLines,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText:
                    'Masukkan ${label.toLowerCase().replaceAll(' *', '')}',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.orange.shade400,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                prefixIcon: Icon(icon, color: Colors.orange.shade600, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                errorStyle: const TextStyle(fontSize: 11),
                errorText: error,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDropdown<T>({
    required String fieldKey,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required String label,
    required IconData icon,
    int delay = 0,
    String? error,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (delay * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: DropdownButtonFormField<T>(
              value: value,
              items:
                  items.asMap().entries.map((entry) {
                    DropdownMenuItem<T> item = entry.value;

                    return DropdownMenuItem<T>(
                      value: item.value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(color: Colors.white),
                        child: Text(
                          item.child is Text
                              ? (item.child as Text).data ?? ''
                              : item.child.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Prevent text overflow
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged:
                  (newValue) =>
                      _taggingBloc.add(SetTaggingFormField(fieldKey, newValue)),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              // Handle text overflow in the selected value display
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((DropdownMenuItem<T> item) {
                  return Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.child is Text
                          ? (item.child as Text).data ?? ''
                          : item.child.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList();
              },
              decoration: InputDecoration(
                hintText: 'Pilih ${label.toLowerCase().replaceAll(' *', '')}',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.orange.shade400,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                prefixIcon: Icon(icon, color: Colors.orange.shade600, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                errorStyle: const TextStyle(fontSize: 11),
                errorText: error,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              isExpanded: true, // This helps with text clipping
              isDense: true,
              // menuMaxHeight: 300, // Optional: limit dropdown height
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaggingBloc, TaggingState>(
      listener: (context, state) {
        if (state is TagSuccess) {
          Navigator.of(context).pop();
        } else if (state is EditFormShown) {
          _businessNameController.text =
              state.data.formFields['name']?.value ?? '';
          _businessOwnerController.text =
              state.data.formFields['owner']?.value ?? '';
          _businessAddressController.text =
              state.data.formFields['address']?.value ?? '';
          _descriptionController.text =
              state.data.formFields['description']?.value ?? '';
          _noteController.text = state.data.formFields['note']?.value ?? '';
        }
      },
      builder: (context, state) {
        if (state.data.formFields['position']?.value == null) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.shade100, width: 2),
                    ),
                    child: Icon(
                      Icons.location_off_rounded,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tidak Bisa Mendapatkan Lokasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan periksa pengaturan GPS Anda',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kembali'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Enhanced Header with gradient and glass effect
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 15,
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF6B35),
                        Color(0xFFFF8E53),
                        Color(0xFFFFB347),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_location_alt_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isCreate ? 'Tambah Tagging' : 'Ubah Tagging',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Text(
                                'Isi keterangan usaha',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Enhanced Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const ClampingScrollPhysics(),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced Position info
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade50,
                                        Colors.cyan.shade50,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.shade400,
                                              Colors.cyan.shade400,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.my_location_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Koordinat Lokasi',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${(state.data.formFields['position']?.value ?? LatLng(-7.9666, 112.6326)).latitude.toStringAsFixed(6)}, ${(state.data.formFields['position']?.value ?? LatLng(-7.9666, 112.6326)).longitude.toStringAsFixed(6)}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Form fields with staggered animations
                          _buildAnimatedTextField(
                            fieldKey: 'name',
                            controller: _businessNameController,
                            label: 'Nama Usaha *',
                            icon: Icons.business_rounded,
                            delay: 0,
                            error: state.data.formFields['name']?.error,
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                            fieldKey: 'owner',
                            controller: _businessOwnerController,
                            label: 'Pemilik Usaha (Opsional)',
                            icon: Icons.person_rounded,
                            delay: 1,
                            error: state.data.formFields['owner']?.error,
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                            fieldKey: 'address',
                            controller: _businessAddressController,
                            label: 'Alamat Usaha (Opsional)',
                            icon: Icons.home_rounded,
                            maxLines: 2,
                            delay: 2,
                            error: state.data.formFields['address']?.error,
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedDropdown<BuildingStatus?>(
                            fieldKey: 'building',
                            value: state.data.formFields['building']?.value,
                            label: 'Status bangunan *',
                            icon: Icons.apartment_rounded,
                            delay: 3,
                            error: state.data.formFields['building']?.error,
                            items:
                                BuildingStatus.getStatuses().map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.text),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                            fieldKey: 'description',
                            controller: _descriptionController,
                            label: 'Deskripsi Aktivitas Usaha *',
                            icon: Icons.description_rounded,
                            maxLines: 3,
                            delay: 4,
                            error: state.data.formFields['description']?.error,
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedDropdown<Sector?>(
                            fieldKey: 'sector',
                            value: state.data.formFields['sector']?.value,
                            label: 'Sektor *',
                            icon: Icons.category_rounded,
                            delay: 5,
                            error: state.data.formFields['sector']?.error,
                            items:
                                Sector.getSectors().map((sector) {
                                  return DropdownMenuItem(
                                    value: sector,
                                    child: Text(sector.text),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                            fieldKey: 'note',
                            controller: _noteController,
                            label: 'Catatan Tambahan (Opsional)',
                            icon: Icons.note_rounded,
                            maxLines: 2,
                            delay: 6,
                            error: state.data.formFields['note']?.error,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),

                // Enhanced Action buttons
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    top: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Center(
                                      child: Text(
                                        'Batal',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B35),
                                      Color(0xFFFF8E53),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _taggingBloc.add(SaveForm()),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.save_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Simpan',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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