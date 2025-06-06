import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/supplement/supplement_form_bloc.dart';
import 'package:kendedes_mobile/bloc/supplement/supplement_form_event.dart';
import 'package:kendedes_mobile/bloc/supplement/supplement_form_state.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';

class AddTagDialog extends StatefulWidget {
  final String? idTagData;
  final LatLng position;
  final VoidCallback onCancel;
  final Function(TagData tagData) onSave;

  const AddTagDialog({
    super.key,
    required this.position,
    required this.onCancel,
    required this.onSave,
    this.idTagData,
  });

  @override
  State<AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog>
    with TickerProviderStateMixin {
  final SupplementFormBloc _supplementFormBloc = SupplementFormBloc();
  final _businessNameController = TextEditingController();
  final _businessOwnerController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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
                  (value) => _supplementFormBloc.add(
                    SetSupplementFormField(fieldKey, value),
                  ),
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
                    int index = entry.key;
                    DropdownMenuItem<T> item = entry.value;
                    bool isEven = index % 2 == 0;

                    return DropdownMenuItem<T>(
                      value: item.value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isEven ? Colors.grey[50] : Colors.white,
                        ),
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
                  (newValue) => _supplementFormBloc.add(
                    SetSupplementFormField(fieldKey, newValue),
                  ),
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
    return BlocProvider<SupplementFormBloc>(
      create: (context) => _supplementFormBloc,
      child: BlocConsumer<SupplementFormBloc, SupplementFormState>(
        listener: (context, state) {},
        builder: (context, state) {
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Tag',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Fill in the business information',
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
                              onPressed: widget.onCancel,
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
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade50,
                                          Colors.cyan.shade50,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.shade400,
                                                Colors.cyan.shade400,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.my_location_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Current Location',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${widget.position.latitude.toStringAsFixed(6)}, ${widget.position.longitude.toStringAsFixed(6)}',
                                                style: TextStyle(
                                                  fontSize: 12,
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
                            const SizedBox(height: 32),

                            // Form fields with staggered animations
                            _buildAnimatedTextField(
                              fieldKey: 'name',
                              controller: _businessNameController,
                              label: 'Nama Usaha *',
                              icon: Icons.business_rounded,
                              delay: 0,
                              error: state.data.formFields['name']?.error,
                            ),
                            const SizedBox(height: 20),

                            _buildAnimatedTextField(
                              fieldKey: 'owner',
                              controller: _businessOwnerController,
                              label: 'Pemilik Usaha',
                              icon: Icons.person_rounded,
                              delay: 1,
                              error: state.data.formFields['owner']?.error,
                            ),
                            const SizedBox(height: 20),

                            _buildAnimatedTextField(
                              fieldKey: 'address',
                              controller: _businessAddressController,
                              label: 'Alamat Usaha',
                              icon: Icons.home_rounded,
                              maxLines: 2,
                              delay: 2,
                              error: state.data.formFields['address']?.error,
                            ),
                            const SizedBox(height: 20),

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
                            const SizedBox(height: 20),

                            _buildAnimatedTextField(
                              fieldKey: 'description',
                              controller: _descriptionController,
                              label: 'Deskripsi Aktivitas Usaha *',
                              icon: Icons.description_rounded,
                              maxLines: 3,
                              delay: 4,
                              error:
                                  state.data.formFields['description']?.error,
                            ),
                            const SizedBox(height: 20),

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
                            const SizedBox(height: 20),

                            _buildAnimatedTextField(
                              fieldKey: 'note',
                              controller: _noteController,
                              label: 'Catatan Tambahan',
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
                      left: 24,
                      right: 24,
                      bottom: MediaQuery.of(context).padding.bottom + 24,
                      top: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
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
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: widget.onCancel,
                                      child: const Center(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B35),
                                        Color(0xFFFF8E53),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap:
                                          () => _supplementFormBloc.add(
                                            SaveForm(),
                                          ),
                                      child: const Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.save_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Save Tag',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
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
      ),
    );
  }
}
