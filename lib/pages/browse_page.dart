import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kendedes_mobile/bloc/browse/browse_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_event.dart';
import 'package:kendedes_mobile/bloc/browse/browse_state.dart';
import 'package:kendedes_mobile/bloc/polygon/polygon_event.dart'
    as polygonevent;
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/classes/marker_display_strategy.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/polygon.dart' as polygonmodel;
import 'package:kendedes_mobile/pages/login_page.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/browse_color_legend_dialog.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/browse_sidebar_widget.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/complex_marker_browse_widget.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/delete_sls_with_business_dialog.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/marker_browse_dialog.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/simple_marker_browse_widget.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/sls_with_business_sidebar.dart';
import 'package:kendedes_mobile/widgets/clustered_markers_dialog.dart';
import 'package:kendedes_mobile/widgets/delete_polygon_dialog.dart';
import 'package:kendedes_mobile/widgets/label_type_selection_dialog.dart';
import 'package:kendedes_mobile/widgets/map_type_selection_dialog.dart';
import 'package:kendedes_mobile/widgets/other_widgets/custom_snackbar.dart';
import 'package:kendedes_mobile/widgets/other_widgets/error_scaffold.dart';
import 'package:kendedes_mobile/widgets/other_widgets/loading_scaffold.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:kendedes_mobile/widgets/polygon_sidebar_widget.dart';
import 'package:kendedes_mobile/widgets/zoom_level_notification_dialog.dart';
import 'package:latlong2/latlong.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> with TickerProviderStateMixin {
  late final MapController _mapController;
  late BrowseBloc _browseBloc;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  bool _confirmToZoom = false;
  bool _forceGetTaggingInsideBounds = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _browseBloc = context.read<BrowseBloc>()..add(Initialize());

    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleController.repeat();

    try {
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        final newLocation = LatLng(position.latitude, position.longitude);
        _browseBloc.add(UpdateCurrentLocation(newPosition: newLocation));
      });
    } catch (e) {
      CustomSnackBar.showError(
        context,
        message: 'Gagal mendapatkan lokasi: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _afterInitSuccess() {
    _browseBloc.add(GetCurrentLocation());

    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        _browseBloc.add(UpdateZoom(zoomLevel: event.camera.zoom));
      }

      if (event is MapEventRotate) {
        _browseBloc.add(UpdateRotation(rotation: event.camera.rotation));
      }

      _logCurrentBounds();

      if (event is MapEventMove) {
        if (_confirmToZoom | _forceGetTaggingInsideBounds) {
          _confirmToZoom = false;
          _forceGetTaggingInsideBounds = false;
          _getBusinessInsideBounds();
          return;
        }
      }
    });
  }

  void _getBusinessInsideBounds() {
    _browseBloc.add(GetBusinessInsideBounds());
  }

  void _logCurrentBounds() {
    final bounds = _mapController.camera.visibleBounds;
    _browseBloc.add(
      UpdateVisibleMapBounds(sw: bounds.southWest, ne: bounds.northEast),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required bool isLoading,
    required List<T> items,
    required String Function(T) displayText,
    ValueChanged<T?>? onChanged,
    VoidCallback? onClear,
  }) {
    if (isLoading) {
      return Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$label...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final isEnabled = items.isNotEmpty && onChanged != null;
    final fillColor = isEnabled ? Colors.grey.shade50 : Colors.grey.shade100;
    final borderColor = isEnabled ? Colors.grey.shade200 : Colors.grey.shade300;
    final textColor = isEnabled ? Colors.grey.shade800 : Colors.grey.shade500;
    final trailingIconColor =
        isEnabled ? Colors.grey.shade600 : Colors.grey.shade400;
    final hasValue = value != null;

    Widget trailingWidget;
    Widget selectedTrailingWidget;

    if (hasValue) {
      final canClear = isEnabled && onClear != null;

      final clearButton = SizedBox(
        width: 32,
        height: 32,
        child: InkWell(
          onTap: canClear ? onClear : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Icon(
              Icons.close_rounded,
              color: trailingIconColor,
              size: 13,
            ),
          ),
        ),
      );

      trailingWidget = clearButton;
      selectedTrailingWidget = clearButton;
    } else {
      trailingWidget = Icon(
        Icons.expand_more_rounded,
        color: trailingIconColor,
      );
      selectedTrailingWidget = Icon(
        Icons.expand_less_rounded,
        color: trailingIconColor,
      );
    }

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.65,
      child: DropdownMenu<T>(
        key: ValueKey('${label}_${value?.hashCode ?? 'null'}'),
        initialSelection: value,
        enabled: isEnabled,
        onSelected: onChanged,
        hintText: label,
        width: double.infinity,
        menuHeight: 360,
        textStyle: TextStyle(color: textColor, fontSize: 13),
        trailingIcon: trailingWidget,
        selectedTrailingIcon: selectedTrailingWidget,
        dropdownMenuEntries:
            items
                .map(
                  (item) => DropdownMenuEntry<T>(
                    value: item,
                    label: displayText(item),
                  ),
                )
                .toList(),
        inputDecorationTheme: InputDecorationTheme(
          constraints: const BoxConstraints.tightFor(height: 42),
          isDense: true,
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildAreaDropdownCard(BrowseStateData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown<Regency>(
                label: 'Kab',
                value: data.selectedRegency,
                items: data.regencies,
                isLoading: data.isLoadingRegency,
                displayText:
                    (regency) => '[${regency.shortCode}] ${regency.name}',
                onChanged: (value) {
                  _browseBloc.add(SelectRegency(regency: value));
                },
                onClear: () {
                  _browseBloc.add(const ClearSelectedRegency());
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdown<Subdistrict>(
                label: 'Kec',
                value: data.selectedSubdistrict,
                items: data.subdistricts,
                isLoading: data.isLoadingSubdistrict,
                displayText:
                    (subdistrict) =>
                        '[${subdistrict.shortCode}] ${subdistrict.name}',
                onChanged: (value) {
                  _browseBloc.add(SelectSubdistrict(subdistrict: value));
                },
                onClear: () {
                  _browseBloc.add(const ClearSelectedSubdistrict());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildDropdown<Village>(
                label: 'Des',
                value: data.selectedVillage,
                items: data.villages,
                isLoading: data.isLoadingVillage,
                displayText:
                    (village) => '[${village.shortCode}] ${village.name}',
                onChanged: (value) {
                  _browseBloc.add(SelectVillage(village: value));
                },
                onClear: () {
                  _browseBloc.add(const ClearSelectedVillage());
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdown<Sls>(
                label: 'SLS',
                value: data.selectedSls,
                items: data.sls,
                isLoading: data.isLoadingSls,
                displayText: (sls) => '[${sls.shortCode}] ${sls.name}',
                onChanged: (value) {
                  _browseBloc.add(SelectSls(sls: value));
                },
                onClear: () {
                  _browseBloc.add(const ClearSelectedSls());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
    Color? backgroundColor,
    Widget? child,
    bool isEnabled = true,
  }) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: isEnabled ? onPressed : null,
          child:
              child ??
              Icon(
                icon,
                color:
                    isEnabled
                        ? (iconColor ?? const Color(0xFF6366F1))
                        : Colors.grey.shade400,
                size: 22,
              ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
    bool isEnabled = true,
    bool isLoading = false,
  }) {
    final isButtonEnabled = isEnabled && !isLoading;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors:
              isButtonEnabled
                  ? gradientColors
                  : [Colors.grey.shade500, Colors.grey.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isButtonEnabled ? gradientColors.first : Colors.grey)
                .withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          onTap: isButtonEnabled ? onPressed : null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildSaveCheckbox({
  //   required bool value,
  //   required ValueChanged<bool?> onChanged,
  //   required List<Color> gradientColors,
  // }) {
  //   return CheckboxListTile(
  //     value: value,
  //     onChanged: onChanged,
  //     title: Text(
  //       'Simpan ke database lokal',
  //       style: TextStyle(
  //         fontSize: 11,
  //         fontWeight: FontWeight.w400,
  //         color: Colors.grey.shade500,
  //       ),
  //     ),
  //     activeColor: gradientColors.first.withValues(alpha: 0.7),
  //     checkboxScaleFactor: 0.85,
  //     side: BorderSide(color: Colors.grey.shade300, width: 1.2),
  //     controlAffinity: ListTileControlAffinity.leading,
  //     contentPadding: EdgeInsets.zero,
  //     dense: true,
  //     visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
  //   );
  // }

  Widget _buildAreaContent(BrowseStateData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAreaDropdownCard(data),
        const SizedBox(height: 10),
        // _buildSaveCheckbox(
        //   value: data.isSaveToLocalDbByArea,
        //   onChanged: (value) {},
        //   gradientColors: const [Colors.blue, Colors.indigo],
        // ),
        const SizedBox(height: 6),
        _buildPrimaryActionButton(
          label: 'Load Prelist By SLS',
          icon: Icons.map_rounded,
          gradientColors: const [Colors.blue, Colors.indigo],
          isLoading: data.isBusinessBySlsLoading,
          isEnabled: data.selectedSls != null,
          onPressed: () {
            _browseBloc.add(GetBusinessByArea(sls: data.selectedSls!));
          },
        ),
      ],
    );
  }

  Widget _buildScreenContent(BrowseStateData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Muat semua prelist usaha yang terlihat di layar peta Anda. Minimum zoom level adalah ${MapConfig.minimumZoomToGetTaggingInsideBounds}.',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        // _buildSaveCheckbox(
        //   value: data.isSaveToLocalDbByScreen,
        //   onChanged: (value) {},
        //   gradientColors: const [Colors.orange, Colors.deepOrange],
        // ),
        const SizedBox(height: 6),
        _buildPrimaryActionButton(
          label: 'Load Prelist di Layar',
          icon: Icons.center_focus_strong_rounded,
          gradientColors: const [Colors.orange, Colors.deepOrange],
          isLoading: data.isBusinessInsideBoundsLoading,
          onPressed: () {
            _browseBloc.add(const GetBusinessInsideBounds());
          },
        ),
      ],
    );
  }

  Widget _buildLoadSegment({
    required BusinessLoadMode mode,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? (mode == BusinessLoadMode.area
                          ? Colors.blue.shade50
                          : Colors.orange.shade50)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected
                        ? (mode == BusinessLoadMode.area
                            ? Colors.blue.shade300
                            : Colors.orange.shade300)
                        : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color:
                      isSelected
                          ? (mode == BusinessLoadMode.area
                              ? Colors.blue.shade700
                              : Colors.orange.shade700)
                          : Colors.grey.shade500,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? (mode == BusinessLoadMode.area
                                ? Colors.blue.shade700
                                : Colors.orange.shade700)
                            : Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPolygonDeleteConfirmationDialog(
    polygonmodel.Polygon polygon,
    bool isDeletingPolygon,
  ) async {
    await showDialog(
      context: context,
      builder:
          (context) => DeletePolygonDialog(
            polygon: polygon,
            isDeletingPolygon: isDeletingPolygon,
            onConfirm: () {
              _browseBloc.add(DeletePolygon(polygon: polygon));
            },
          ),
    );
  }

  void _showSlsWithBusinessDeleteConfirmationDialog(
    SlsWithBusiness item,
    bool isDeleting,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteSlsWithBusinessDialog(
          slsWithBusiness: item,
          isDeleting: isDeleting,
          onConfirm: () {
            _browseBloc.add(DeleteSlsWithBusiness(slsWithBusiness: item));
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
          // isDeleting: isDeleting,
        );
      },
    );
  }

  void _togglePolygonSidebar(bool isOpen) {
    _browseBloc.add(SetPolygonSideBarOpen(isOpen));
  }

  void _toggleBrowseSidebar(bool isOpen) {
    _browseBloc.add(SetBrowseSideBarOpen(isOpen));
  }

  void _showLabelTypeDialog(LabelType? selectedLabelType) {
    showDialog(
      context: context,
      builder:
          (context) => LabelTypeSelectionDialog(
            labelTypes: LabelType.values,
            selectedLabelType: selectedLabelType,
            onLabelTypeSelected: (labelType) {
              _browseBloc.add(SelectLabelType(labelType));
            },
          ),
    );
  }

  void _showMapTypeDialog(MapType? selectedMapType) {
    showDialog(
      context: context,
      builder:
          (context) => MapTypeSelectionDialog(
            mapTypes: MapType.getMapTypes(),
            selectedMapType: selectedMapType,
            onMapTypeSelected: (mapType) {
              _browseBloc.add(SelectMapType(mapType));
            },
          ),
    );
  }

  void _toggleSlsWithBusinessSidebar(bool isOpen) {
    _browseBloc.add(SetSlsWithBusinessSidebarOpen(isOpen));
  }

  void _showColorLegendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BrowseColorLegendDialog();
      },
    );
  }

  void _showMarkerDialog(TagData tagData) {
    showDialog(
      context: context,
      builder: (context) => MarkerBrowseDialog(tagData: tagData),
    );
  }

  // Helper: pixel distance between two points
  double _distanceInPixels(LatLng a, LatLng b, double zoom, Size mapSize) {
    // Use the map's projection to convert LatLng to pixel coordinates
    // This is a simple approximation for Web Mercator projection
    double scale = math.pow(2, zoom).toDouble();
    double worldSize = 256 * scale;
    double x1 = (a.longitude + 180) / 360 * worldSize;
    double y1 =
        (1 -
            math.log(
                  math.tan(a.latitude * math.pi / 180) +
                      1 / math.cos(a.latitude * math.pi / 180),
                ) /
                math.pi) /
        2 *
        worldSize;
    double x2 = (b.longitude + 180) / 360 * worldSize;
    double y2 =
        (1 -
            math.log(
                  math.tan(b.latitude * math.pi / 180) +
                      1 / math.cos(b.latitude * math.pi / 180),
                ) /
                math.pi) /
        2 *
        worldSize;
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2));
  }

  // Find tags that are visually stacked (overlapping) at the current zoom
  List<TagData> _findStackedTagsVisual(
    TagData clickedTag,
    List<TagData> allTags,
    double zoom,
    Size mapSize,
  ) {
    const double markerPixelRadius =
        10; // Marker radius in pixels (adjust as needed)
    return allTags.where((tag) {
      if (tag == clickedTag) return true;
      double dist = _distanceInPixels(
        LatLng(clickedTag.positionLat, clickedTag.positionLng),
        LatLng(tag.positionLat, tag.positionLng),
        zoom,
        mapSize,
      );
      return dist < markerPixelRadius * 2;
    }).toList();
  }

  void _handleMarkerClick(
    TagData clickedTag,
    List<TagData> allTags,
    List<TagData> selectedTags,
    double zoom,
    Size mapSize,
  ) {
    final stackedTags = _findStackedTagsVisual(
      clickedTag,
      allTags,
      zoom,
      mapSize,
    );

    if (stackedTags.length > 1) {
      showDialog(
        context: context,
        builder:
            (context) => ClusteredMarkersDialog(
              tags: stackedTags,
              selectedTags: selectedTags,
              onClose: () => Navigator.of(context).pop(),
              onTagSelected: (tag) {
                _showMarkerDialog(tag);
              },
            ),
      );
    } else {
      _showMarkerDialog(clickedTag);
    }
  }

  Marker _buildTagMarker(
    TagData tagData,
    bool isSelected,
    String? labelType,
    double currentZoom,
    Size mapSize,
  ) {
    void onMarkerTap() {
      _handleMarkerClick(
        tagData,
        _browseBloc.state.data.businesses,
        _browseBloc.state.data.selectedBusinesses,
        currentZoom,
        mapSize,
      );
    }

    final mode = MarkerDisplayStrategy.getRenderMode(zoom: currentZoom);

    switch (mode) {
      case MarkerRenderMode.simple:
        return Marker(
          point: LatLng(tagData.positionLat, tagData.positionLng),
          alignment: Alignment.center,
          width: isSelected ? 28 : 20,
          height: isSelected ? 28 : 20,
          child: SimpleMarkerBrowseWidget(
            tagData: tagData,
            isSelected: isSelected,
            onTap: onMarkerTap,
          ),
        );
      default:
        return Marker(
          point: LatLng(tagData.positionLat, tagData.positionLng),
          alignment: Alignment.center,
          width: isSelected ? 130 : 120,
          height: isSelected ? 130 : 120,
          child: ComplexMarkerBrowseWidget(
            tagData: tagData,
            isSelected: isSelected,
            labelType: labelType,
            onTap: onMarkerTap,
          ),
        );
    }
  }

  void _showZoomLevelNotificationDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => ZoomLevelNotificationDialog(
            message: message,
            onYes: () {
              Navigator.of(context).pop();
              _confirmToZoom = true;
              _mapController.move(
                _mapController.camera.center,
                MapConfig.minimumZoomToGetTaggingInsideBounds,
              );
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return BlocConsumer<BrowseBloc, BrowseState>(
      listener: (context, state) {
        if (state is InitializingSuccess) {
          _afterInitSuccess();
        } else if (state is MovedCurrentLocation) {
          if (state.data.currentLocation != null) {
            _mapController.move(
              state.data.currentLocation ?? LatLng(-7.9666, 112.6326),
              state.data.currentZoom,
            );
          }
        } else if (state is BusinessSelected) {
          if (state.data.selectedBusinesses.isNotEmpty) {
            final selectedBusiness = state.data.selectedBusinesses.first;
            _mapController.move(
              LatLng(
                selectedBusiness.positionLat,
                selectedBusiness.positionLng,
              ),
              state.data.currentZoom,
            );
            _toggleBrowseSidebar(false);
          }
        } else if (state is ZoomLevelNotification) {
          _showZoomLevelNotificationDialog(state.message);
        } else if (state is NoBusinessInsideBounds) {
          CustomSnackBar.showInfo(context, message: state.message);
        } else if (state is TokenExpired) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else if (state is BusinessInsideBoundsFailed ||
            state is BusinessBySlsFailed) {
          final message = switch (state) {
            BusinessInsideBoundsFailed(:final errorMessage) => errorMessage,
            BusinessBySlsFailed(:final errorMessage) => errorMessage,
            _ => '',
          };
          CustomSnackBar.showError(context, message: message);
        } else if (state is MockupLocationDetected) {
          showDialog(
            context: context,
            builder:
                (context) => MessageDialog(
                  title: 'Fake GPS Terdeteksi',
                  message:
                      'Kami mendeteksi bahwa Anda menggunakan aplikasi Fake GPS. '
                      'Silakan matikan aplikasi tersebut untuk melanjutkan tagging.',
                  type: MessageType.error,
                  buttonText: 'Tutup',
                ),
          );
        } else if (state is BusinessBySlsSuccess) {
          _mapController.move(state.centerLocation, state.data.currentZoom);
        } else if (state is PolygonSelected) {
          _mapController.move(
            LatLng(state.polygonCenter.latitude, state.polygonCenter.longitude),
            state.data.currentZoom,
          );
        } else if (state is PolygonDeleted) {
          Navigator.of(context).pop();

          CustomSnackBar.show(
            context,
            message: 'Poligon berhasil dihapus',
            type: SnackBarType.success,
          );
        } else if (state is SlsWithBusinessDeleted) {
          Navigator.of(context).pop();

          CustomSnackBar.show(
            context,
            message: 'Prelist SLS berhasil dihapus',
            type: SnackBarType.success,
          );
        }
      },
      builder: (context, state) {
        if (state is InitializingStarted) {
          return LoadingScaffold(
            title: state.message,
            subtitle: 'Mohon tunggu sebentar',
          );
        } else if (state is InitializingError) {
          return ErrorScaffold(
            title: 'Gagal Memuat Peta',
            errorMessage: state.errorMessage,
            retryButtonText: 'Coba Lagi',
            onRetry: () {
              _browseBloc.add(Initialize());
            },
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mapSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(-7.9666, 112.6326),
                        initialZoom: state.data.currentZoom,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              state.data.selectedMapType?.url ??
                              MapType.openStreetMapDefault.url,
                          userAgentPackageName: 'com.example.kendedes_mobile',
                        ),

                        // SLS Polygon layer
                        PolygonLayer(
                          polygons:
                              state.data.polygons
                                  .where(
                                    (polygonData) =>
                                        polygonData.type.name.toLowerCase() ==
                                        'sls',
                                  )
                                  .map(
                                    (polygonData) => Polygon(
                                      points: polygonData.points,
                                      color: Colors.purple.withValues(
                                        alpha: 0.05,
                                      ),
                                      borderStrokeWidth: 2,
                                      borderColor: Colors.purple,
                                      label:
                                          '${polygonData.longCode}\n${polygonData.fullName}',
                                      labelStyle: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        backgroundColor: Colors.white70,
                                      ),
                                      labelPlacement:
                                          PolygonLabelPlacement.centroid,
                                    ),
                                  )
                                  .toList(),
                        ),

                        // Village Polygon layer
                        PolygonLayer(
                          polygons:
                              state.data.polygons
                                  .where(
                                    (polygonData) =>
                                        polygonData.type.name.toLowerCase() ==
                                        'village',
                                  )
                                  .map(
                                    (polygonData) => Polygon(
                                      points: polygonData.points,
                                      color: Colors.orange.withValues(
                                        alpha: 0.05,
                                      ),
                                      borderStrokeWidth: 2,
                                      borderColor: Colors.orange,
                                      label:
                                          '${polygonData.longCode}\n${polygonData.fullName}',
                                      labelStyle: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        backgroundColor: Colors.white70,
                                      ),
                                      labelPlacement:
                                          PolygonLabelPlacement.centroid,
                                    ),
                                  )
                                  .toList(),
                        ),

                        // Marker layer from bloc state
                        MarkerLayer(
                          markers: [
                            // User businesses: show selected businesses above non-selected businesses
                            ...[
                              ...state.data.businesses.where(
                                (business) =>
                                    !state.data.selectedBusinesses.contains(
                                      business,
                                    ),
                              ),
                              ...state.data.selectedBusinesses,
                            ].map((business) {
                              return _buildTagMarker(
                                business,
                                state.data.selectedBusinesses.contains(
                                  business,
                                ),
                                state.data.selectedLabelType?.key,
                                state.data.currentZoom,
                                mapSize,
                              );
                            }),

                            // Current location marker
                            if (state.data.currentLocation != null)
                              Marker(
                                point: state.data.currentLocation!,
                                width: 70,
                                height: 70,
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Animated ripple effect
                                      AnimatedBuilder(
                                        animation: _rippleAnimation,
                                        builder: (context, child) {
                                          return Container(
                                            width: 70 * _rippleAnimation.value,
                                            height: 70 * _rippleAnimation.value,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue.withValues(
                                                alpha:
                                                    (1 -
                                                        _rippleAnimation
                                                            .value) *
                                                    0.3,
                                              ),
                                              border: Border.all(
                                                color: Colors.blue.withValues(
                                                  alpha:
                                                      1 -
                                                      _rippleAnimation.value,
                                                ),
                                                width: 2,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      // Main location dot
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Scalebar
                        Scalebar(
                          textStyle: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.only(
                            right: 10,
                            left: 50,
                            bottom: 120,
                          ),
                          lineColor: Colors.grey.shade700,
                          alignment: Alignment.bottomLeft,
                          length: ScalebarLength.l,
                        ),
                      ],
                    ),

                    // Floating title bar (Tagging-like)
                    Positioned(
                      top: topPadding + 12,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Image.asset(
                                    'images/icon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Kendedes Mobile',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Mode Jelajah',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Toggle Sidebar Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => _toggleBrowseSidebar(true),
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.menu_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Right-side action buttons (map only)
                    Positioned(
                      top: topPadding + 92,
                      right: 16,
                      child: Column(
                        children: [
                          // Compass
                          _buildActionButton(
                            icon: Icons.navigation_rounded,
                            iconColor: Colors.red,
                            onPressed: () {
                              _mapController.rotate(0.0);
                            },
                            child: Transform.rotate(
                              angle: state.data.rotation * math.pi / 180,
                              child: const Icon(
                                Icons.navigation_rounded,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Label type button
                          _buildActionButton(
                            icon: Icons.label,
                            iconColor: Colors.green,
                            onPressed: () {
                              _showLabelTypeDialog(
                                state.data.selectedLabelType,
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          // Map type button
                          _buildActionButton(
                            icon: Icons.layers_rounded,
                            iconColor: Colors.blue.shade600,
                            onPressed: () {
                              _showMapTypeDialog(state.data.selectedMapType);
                            },
                          ),

                          const SizedBox(height: 12),

                          // Polygon button
                          _buildActionButton(
                            icon: Icons.pentagon_outlined,
                            iconColor: Colors.purple.shade600,
                            onPressed: () {
                              _togglePolygonSidebar(true);
                            },
                          ),

                          const SizedBox(height: 12),

                          // Clear selection button
                          if (state.data.selectedBusinesses.isNotEmpty) ...[
                            _buildActionButton(
                              icon: Icons.clear_all_rounded,
                              iconColor: Colors.red,
                              onPressed:
                                  () => _browseBloc.add(ClearBrowseSelection()),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Zoom level indicator
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 100,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Colors.orange.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Total tagging:',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    '${state.data.businesses.length} di map',
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Zoom Level: ${state.data.currentZoom.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Color Legend Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _showColorLegendDialog,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.palette,
                                        size: 12,
                                        color: Colors.purple.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Legenda',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom load business container with current location button
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Current location button
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 0,
                                  bottom: 12,
                                ),
                                child: // My location button
                                    _buildActionButton(
                                  icon: Icons.my_location_rounded,
                                  iconColor: Colors.blue.shade700,
                                  isEnabled:
                                      !state.data.isLoadingCurrentLocation,
                                  onPressed:
                                      () => _browseBloc.add(
                                        const GetCurrentLocation(),
                                      ),
                                  child:
                                      state.data.isLoadingCurrentLocation
                                          ? Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                child:
                                                    CircularProgressIndicator(
                                                      color:
                                                          Colors.blue.shade700,
                                                      strokeWidth: 2.5,
                                                    ),
                                              ),
                                              Icon(
                                                Icons.my_location_rounded,
                                                color: Colors.blue.shade700,
                                                size: 14,
                                              ),
                                            ],
                                          )
                                          : Icon(
                                            Icons.my_location_rounded,
                                            color: Colors.blue.shade700,
                                            size: 22,
                                          ),
                                ),
                              ),
                            ),
                            // Load business container
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.98),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Section header with collapse toggle
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            onTap:
                                                () => _browseBloc.add(
                                                  const ToggleLoadBusinessContainer(),
                                                ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.blue.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.storefront_rounded,
                                                      color:
                                                          Colors.blue.shade700,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      'Load Prelist Usaha',
                                                      style: TextStyle(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade900,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (state.data.loadMode ==
                                          BusinessLoadMode.area) ...[
                                        SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () {
                                                _toggleSlsWithBusinessSidebar(
                                                  true,
                                                );
                                              },
                                              child: Center(
                                                child: Icon(
                                                  Icons.download_done_rounded,
                                                  color: Colors.blue.shade700,
                                                  size: 19,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap:
                                                () => _browseBloc.add(
                                                  const ToggleLoadBusinessContainer(),
                                                ),
                                            child: Center(
                                              child: AnimatedRotation(
                                                turns:
                                                    state
                                                            .data
                                                            .isLoadBusinessContainerExpanded
                                                        ? 0
                                                        : 0.5,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                child: Icon(
                                                  Icons.expand_more_rounded,
                                                  color: Colors.grey.shade700,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (state
                                      .data
                                      .isLoadBusinessContainerExpanded) ...[
                                    const SizedBox(height: 10),

                                    // Load mode tab (wrapped in a container)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildLoadSegment(
                                            mode: BusinessLoadMode.area,
                                            icon: Icons.map_rounded,
                                            label: 'By SLS',
                                            onTap:
                                                () => _browseBloc.add(
                                                  SetBusinessLoadMode(
                                                    loadMode:
                                                        BusinessLoadMode.area,
                                                  ),
                                                ),
                                            isSelected:
                                                state.data.loadMode ==
                                                BusinessLoadMode.area,
                                          ),
                                          const SizedBox(width: 10),
                                          _buildLoadSegment(
                                            mode: BusinessLoadMode.screen,
                                            icon:
                                                Icons
                                                    .center_focus_strong_rounded,
                                            label: 'By Layar',
                                            onTap:
                                                () => _browseBloc.add(
                                                  SetBusinessLoadMode(
                                                    loadMode:
                                                        BusinessLoadMode.screen,
                                                  ),
                                                ),
                                            isSelected:
                                                state.data.loadMode ==
                                                BusinessLoadMode.screen,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (state.data.loadMode ==
                                        BusinessLoadMode.area)
                                      _buildAreaContent(state.data)
                                    else
                                      _buildScreenContent(state.data),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sidebar overlay
                    if (state.data.isSlsWithBusinessSidebarOpen ||
                        state.data.isPolygonSideBarOpen ||
                        state.data.isBrowseSideBarOpen)
                      GestureDetector(
                        onTap: () {
                          _toggleSlsWithBusinessSidebar(false);
                          _togglePolygonSidebar(false);
                          _toggleBrowseSidebar(false);
                        },
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),

                    // Sls with business sidebar
                    SlsWithBusinessSidebar(
                      isOpen: state.data.isSlsWithBusinessSidebarOpen,
                      items: state.data.filteredSlsWithBusinessList,
                      onClose: () => _toggleSlsWithBusinessSidebar(false),
                      onSearch:
                          (value) => _browseBloc.add(
                            SearchSlsWithBusiness(query: value),
                          ),
                      onClear:
                          () => _browseBloc.add(
                            const SearchSlsWithBusiness(reset: true),
                          ),
                      onItemTap: (item) {
                        if (item.sls.polygon != null) {
                          _browseBloc.add(
                            SelectPolygon(polygon: item.sls.polygon!),
                          );
                        }
                      },
                      onDeleteTap: (item) {
                        _showSlsWithBusinessDeleteConfirmationDialog(
                          item,
                          state.data.isDeletingSlsWithBusiness,
                        );
                      },
                    ),

                    // Business Sidebar
                    const BrowseSidebarWidget(),

                    // Polygon sidebar
                    PolygonSidebarWidget(
                      dataId: state.data.currentUser?.id ?? '',
                      pairType: polygonevent.PolygonPairType.user,
                      isPolygonSideBarOpen: state.data.isPolygonSideBarOpen,
                      polygons: state.data.polygons,
                      onClose: () => _togglePolygonSidebar(false),
                      onSelect:
                          (polygon) =>
                              _browseBloc.add(SelectPolygon(polygon: polygon)),
                      onUpdate: () => _browseBloc.add(UpdatePolygon()),
                      onDelete:
                          (polygon) => _showPolygonDeleteConfirmationDialog(
                            polygon,
                            state.data.isDeletingPolygon,
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
