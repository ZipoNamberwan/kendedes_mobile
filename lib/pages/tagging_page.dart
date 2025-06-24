import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_event.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/classes/marker_display_strategy.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:kendedes_mobile/pages/login_page.dart';
import 'package:kendedes_mobile/widgets/area_not_requested_dialog.dart';
import 'package:kendedes_mobile/widgets/clustered_markers_dialog.dart';
import 'package:kendedes_mobile/widgets/color_legend_dialog.dart';
import 'package:kendedes_mobile/widgets/delete_tag_confirmation_dialog.dart';
import 'package:kendedes_mobile/widgets/label_type_selection_dialog.dart';
import 'package:kendedes_mobile/widgets/marker_dialog.dart';
import 'package:kendedes_mobile/widgets/complex_marker_widget.dart';
import 'package:kendedes_mobile/widgets/other_widgets/custom_snackbar.dart';
import 'package:kendedes_mobile/widgets/other_widgets/error_scaffold.dart';
import 'package:kendedes_mobile/widgets/other_widgets/loading_scaffold.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:kendedes_mobile/widgets/sidebar_widget.dart';
import 'package:kendedes_mobile/widgets/simple_marker_widget.dart';
import 'package:kendedes_mobile/widgets/tagging_form_dialog.dart';
import 'package:kendedes_mobile/widgets/map_type_selection_dialog.dart';
import 'package:kendedes_mobile/widgets/project_info_dialog.dart';
import 'package:kendedes_mobile/widgets/zoom_level_notification_dialog.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class TaggingPage extends StatefulWidget {
  final Project project;

  const TaggingPage({super.key, required this.project});

  @override
  State<TaggingPage> createState() => _TaggingPageState();
}

class _TaggingPageState extends State<TaggingPage>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  late TaggingBloc _taggingBloc;

  // Example polygon data
  // final List<PoligonData> _polygonData = [
  //   PoligonData(
  //     id: 'P001',
  //     polygonType: 'Area',
  //     points: [
  //       LatLng(-7.9650, 112.6250),
  //       LatLng(-7.9650, 112.6350),
  //       LatLng(-7.9720, 112.6350),
  //       LatLng(-7.9720, 112.6250),
  //     ],
  //   ),
  // ];

  bool _confirmToZoom = false;
  bool _forceGetTaggingInsideBounds = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _taggingBloc =
        context.read<TaggingBloc>()..add(InitTag(project: widget.project));

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
        _taggingBloc.add(UpdateCurrentLocation(newPosition: newLocation));
      });
    } catch (e) {
      CustomSnackBar.showError(
        context,
        message: 'Gagal mendapatkan lokasi: ${e.toString()}',
      );
    }

    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        _taggingBloc.add(UpdateZoom(zoomLevel: event.camera.zoom));
      }

      if (event is MapEventRotate) {
        _taggingBloc.add(UpdateRotation(rotation: event.camera.rotation));
      }

      _logCurrentBounds();

      if (event is MapEventMove) {
        if (_confirmToZoom | _forceGetTaggingInsideBounds) {
          _confirmToZoom = false;
          _forceGetTaggingInsideBounds = false;
          _getTaggingInsideBounds();
          return;
        }
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _taggingBloc.add(CloseProject());
    _mapController.dispose();
    super.dispose();
  }

  void _checkNearbyTagging(
    MapController mapController,
    LatLng targetLocation,
    double targetZoom,
  ) {
    final currentCenter = mapController.camera.center;
    final currentZoom = mapController.camera.zoom;

    final needsMove =
        currentCenter.latitude != targetLocation.latitude ||
        currentCenter.longitude != targetLocation.longitude ||
        currentZoom != targetZoom;

    if (needsMove) {
      _forceGetTaggingInsideBounds = true;
      mapController.move(targetLocation, targetZoom);
    } else {
      _getTaggingInsideBounds();
    }
  }

  void _getTaggingInsideBounds() {
    _taggingBloc.add(GetTaggingInsideBounds());
  }

  void _logCurrentBounds() {
    final bounds = _mapController.camera.visibleBounds;
    _taggingBloc.add(
      UpdateVisibleMapBounds(sw: bounds.southWest, ne: bounds.northEast),
    );
  }

  void _onMapReady() {
    _taggingBloc.add(GetCurrentLocation());
  }

  void _showMarkerDialog(TagData tagData, Project project, User? currentUser) {
    showDialog(
      context: context,
      builder:
          (context) => MarkerDialog(
            tagData: tagData,
            project: project,
            currentUser: currentUser,
            onDelete: (tagData) {
              _showDeleteConfirmationDialog(tagData);
            },
            onMove: (tagData) {
              CustomSnackBar.showInfo(
                context,
                message: 'Fitur pemindahan marker belum tersedia.',
              );
            },
            onEdit: (tagData) => _showTaggingFormDialog(tagData),
          ),
    );
  }

  void _showDeleteConfirmationDialog(TagData tagData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteTagConfirmationDialog(
          tagData: tagData,
          onConfirm: () {
            _taggingBloc.add(DeleteTag(tagData));
          },
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _showTaggingFormDialog(TagData? tagData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TaggingFormDialog(initialTagData: tagData),
    );
  }

  void _showLabelTypeDialog(LabelType? selectedLabelType) {
    showDialog(
      context: context,
      builder:
          (context) => LabelTypeSelectionDialog(
            labelTypes: LabelType.values,
            selectedLabelType: selectedLabelType,
            onLabelTypeSelected:
                (labelType) => {_taggingBloc.add(SelectLabelType(labelType))},
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
              _taggingBloc.add(SelectMapType(mapType));
            },
          ),
    );
  }

  void _showColorLegendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorLegendDialog(
          currentProject: widget.project,
          currentUserId: _taggingBloc.state.data.currentUser?.id,
        );
      },
    );
  }

  void _showProjectInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProjectInfoDialog();
      },
    );
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

  void _toggleSidebar(bool isOpen) {
    _taggingBloc.add(SetSideBarOpen(isOpen));
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
    Project project,
    User? currentUser,
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
                _showMarkerDialog(tag, project, currentUser);
              },
            ),
      );
    } else {
      _showMarkerDialog(clickedTag, project, currentUser);
    }
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
      width: 52,
      height: 52,
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaggingBloc, TaggingState>(
      listener: (context, state) {
        if (state is SaveFormSuccess || state is TagDeletedSuccess) {
          final message = switch (state) {
            SaveFormSuccess(:final successMessage) => successMessage,
            TagDeletedSuccess(:final successMessage) => successMessage,
            _ => '',
          };

          CustomSnackBar.showSuccess(context, message: message);
        } else if (state is TagError || state is TagDeletedError) {
          final message = switch (state) {
            TagError(:final errorMessage) => errorMessage,
            TagDeletedError(:final errorMessage) => errorMessage,
            _ => '',
          };

          CustomSnackBar.showError(context, message: message);
        } else if (state is MovedCurrentLocation) {
          if (state.data.currentLocation != null) {
            _mapController.move(
              state.data.currentLocation ?? LatLng(-7.9666, 112.6326),
              state.data.currentZoom,
            );
          }
        } else if (state is TagSelected) {
          if (state.data.selectedTags.isNotEmpty) {
            final selectedTag = state.data.selectedTags.first;
            _mapController.move(
              LatLng(selectedTag.positionLat, selectedTag.positionLng),
              state.data.currentZoom,
            );
            _toggleSidebar(false);
          }
        } else if (state is RecordedLocation) {
          _mapController.move(state.recordedLocation, state.data.currentZoom);
          _showTaggingFormDialog(null);
        } else if (state is TaggingInsideBoundsFailed) {
          CustomSnackBar.showError(
            context,
            message:
                'Gagal mengambil data tagging di area ini. ${state.errorMessage}',
          );
        } else if (state is TokenExpired) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else if (state is ZoomLevelNotification) {
          _showZoomLevelNotificationDialog(state.message);
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
        } else if (state is AreaNotRequestedNotification) {
          showDialog(
            context: context,
            builder:
                (context) => AreaNotRequestedDialog(
                  onContinue: () {
                    _taggingBloc.add(RecordTagLocation(forceTagging: true));
                  },
                  onCheckNearby: () {
                    _checkNearbyTagging(
                      _mapController,
                      state.recordedLocation,
                      MapConfig.minimumZoomToGetTaggingInsideBounds,
                    );
                    Navigator.of(context).pop();
                  },
                ),
          );
        }
      },
      builder: (context, state) {
        if (state is InitializingStarted) {
          return LoadingScaffold(
            title: 'Memuat Peta...',
            subtitle: 'Mohon tunggu sebentar',
          );
        } else if (state is InitializingError) {
          return ErrorScaffold(
            title: 'Gagal Memuat Peta',
            errorMessage: state.errorMessage,
            retryButtonText: 'Coba Lagi',
            onRetry: () {
              _taggingBloc.add(InitTag(project: widget.project));
            },
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mapSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(-7.9666, 112.6326),
                          initialZoom: state.data.currentZoom,
                          onLongPress: (tapPosition, point) => {},
                          onMapReady: () {
                            _onMapReady();
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                state.data.selectedMapType?.url ??
                                MapType.openStreetMapDefault.url,
                            userAgentPackageName: 'com.example.kendedes_mobile',
                          ),

                          // // Polygon layer
                          // PolygonLayer(
                          //   polygons:
                          //       _polygonData
                          //           .map(
                          //             (polygonData) => Polygon(
                          //               points: polygonData.points,
                          //               color: Colors.orange.withValues(alpha: 0.3),
                          //               borderStrokeWidth: 2,
                          //               borderColor: Colors.orange,
                          //             ),
                          //           )
                          //           .toList(),
                          // ),

                          // Marker layer from bloc state
                          MarkerLayer(
                            markers: [
                              // User tags: show selected tags above non-selected tags
                              ...[
                                ...state.data.tags.where(
                                  (tag) =>
                                      !state.data.selectedTags.contains(tag),
                                ),
                                ...state.data.selectedTags,
                              ].map((tagData) {
                                final isSelected = state.data.selectedTags
                                    .contains(tagData);

                                final labelType =
                                    state.data.selectedLabelType?.key;
                                final currentUser = state.data.currentUser;
                                final currentProject = state.data.project;
                                void onMarkerTap() {
                                  _handleMarkerClick(
                                    tagData,
                                    state.data.project,
                                    state.data.currentUser,
                                    state.data.tags,
                                    state.data.selectedTags,
                                    state.data.currentZoom,
                                    mapSize,
                                  );
                                }

                                final mode =
                                    MarkerDisplayStrategy.getRenderMode(
                                      zoom: state.data.currentZoom,
                                    );

                                switch (mode) {
                                  case MarkerRenderMode.simple:
                                    return Marker(
                                      point: LatLng(
                                        tagData.positionLat,
                                        tagData.positionLng,
                                      ),
                                      alignment: Alignment.center,
                                      width: isSelected ? 28 : 20,
                                      height: isSelected ? 28 : 20,
                                      child: SimpleMarkerWidget(
                                        tagData: tagData,
                                        isSelected: isSelected,
                                        labelType: labelType,
                                        currentUser: currentUser,
                                        currentProject: currentProject,
                                        onTap: onMarkerTap,
                                      ),
                                    );
                                  default:
                                    return Marker(
                                      point: LatLng(
                                        tagData.positionLat,
                                        tagData.positionLng,
                                      ),
                                      alignment: Alignment.center,
                                      width: isSelected ? 130 : 120,
                                      height: isSelected ? 130 : 120,
                                      child: ComplexMarkerWidget(
                                        tagData: tagData,
                                        isSelected: isSelected,
                                        labelType: labelType,
                                        currentUser: currentUser,
                                        currentProject: currentProject,
                                        onTap: onMarkerTap,
                                      ),
                                    );
                                }
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
                                              width:
                                                  70 * _rippleAnimation.value,
                                              height:
                                                  70 * _rippleAnimation.value,
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
                                    '${state.data.tags.length} di map',
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

                    // Floating title bar
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.folder_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        state.data.project.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),

                                      Builder(
                                        builder: (context) {
                                          final syncedCount =
                                              state.data.tags.where((tag) {
                                                return tag.hasSentToServer &&
                                                    tag.project.id ==
                                                        state.data.project.id;
                                              }).length;
                                          final unsyncedCount =
                                              state.data.tags.where((tag) {
                                                return !tag.hasSentToServer &&
                                                    tag.project.id ==
                                                        state.data.project.id;
                                              }).length;

                                          return Row(
                                            children: [
                                              // Synced tags counter
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withValues(alpha: 0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.cloud_done_rounded,
                                                      color: Colors.white,
                                                      size: 10,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '$syncedCount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              // Unsynced tags counter
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.cloud_off_rounded,
                                                      color: Colors.white,
                                                      size: 10,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '$unsyncedCount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Project detail button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: _showProjectInfoDialog,
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.info_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => _toggleSidebar(true),
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

                    // Right action buttons column
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 92,
                      right: 16,
                      child: Column(
                        children: [
                          // Compass button
                          _buildActionButton(
                            icon: Icons.navigation_rounded,
                            iconColor: Colors.red,
                            onPressed: () {
                              _mapController.rotate(0.0);
                            },
                            child: Transform.rotate(
                              angle: state.data.rotation * math.pi / 180,
                              child: Icon(
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

                          // Clear selection button
                          if (state.data.selectedTags.isNotEmpty) ...[
                            _buildActionButton(
                              icon: Icons.clear_all_rounded,
                              iconColor: Colors.red,
                              onPressed:
                                  () => _taggingBloc.add(ClearTagSelection()),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Bottom action buttons row
                    Positioned(
                      bottom: 120,
                      right: 16,
                      child: Column(
                        children: [
                          // Refresh tagging button
                          _buildActionButton(
                            icon: Icons.sync,
                            iconColor: Colors.deepOrange,
                            onPressed: () {
                              _getTaggingInsideBounds();
                            },
                            child:
                                state.data.isTaggingInsideBoundsLoading
                                    ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const SizedBox(
                                          child: CircularProgressIndicator(
                                            color: Colors.deepOrange,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.sync,
                                          color: Colors.deepOrange,
                                          size: 14,
                                        ),
                                      ],
                                    )
                                    : const Icon(
                                      Icons.sync,
                                      color: Colors.deepOrange,
                                      size: 22,
                                    ),
                          ),

                          const SizedBox(height: 12),

                          // My location button
                          _buildActionButton(
                            icon: Icons.my_location_rounded,
                            iconColor: Colors.deepOrange,
                            isEnabled: !state.data.isLoadingCurrentLocation,
                            onPressed:
                                () => _taggingBloc.add(
                                  const GetCurrentLocation(),
                                ),
                            child:
                                state.data.isLoadingCurrentLocation
                                    ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const SizedBox(
                                          child: CircularProgressIndicator(
                                            color: Colors.deepOrange,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.my_location_rounded,
                                          color: Colors.deepOrange,
                                          size: 14,
                                        ),
                                      ],
                                    )
                                    : const Icon(
                                      Icons.my_location_rounded,
                                      color: Colors.deepOrange,
                                      size: 22,
                                    ),
                          ),
                        ],
                      ),
                    ),

                    // Main tag location button
                    Positioned(
                      bottom: 32,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.4),
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
                            borderRadius: BorderRadius.circular(32),
                            splashColor: Colors.white.withValues(alpha: 0.2),
                            highlightColor: Colors.white.withValues(alpha: 0.1),
                            onTap:
                                state.data.isLoadingCurrentLocation ||
                                        state.data.isLoadingTag
                                    ? null
                                    : () => _taggingBloc.add(
                                      RecordTagLocation(forceTagging: false),
                                    ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (state.data.isLoadingCurrentLocation ||
                                      state.data.isLoadingTag)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_location_alt_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  Text(
                                    state.data.isLoadingCurrentLocation
                                        ? 'Mengambil Lokasi...'
                                        : state.data.isLoadingTag
                                        ? 'Tagging...'
                                        : 'Tag Usaha',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Sidebar overlay
                    if (state.data.isSideBarOpen)
                      GestureDetector(
                        onTap: () => _toggleSidebar(false),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),

                    // Right sidebar
                    const SidebarWidget(),
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
