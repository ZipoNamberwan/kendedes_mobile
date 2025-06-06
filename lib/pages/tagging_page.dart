import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_event.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/models/poligon_data.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/widgets/clustered_markers_dialog.dart';
import 'package:kendedes_mobile/widgets/marker_dialog.dart';
import 'package:kendedes_mobile/widgets/marker_widget.dart';
import 'package:kendedes_mobile/widgets/sidebar_widget.dart';
import 'package:kendedes_mobile/widgets/tagging_form_dialog.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'package:kendedes_mobile/widgets/delete_tagging_confirmation_dialog.dart';

class TaggingPage extends StatefulWidget {
  final Project project;

  const TaggingPage({super.key, required this.project});

  @override
  State<TaggingPage> createState() => _TaggingPageState();
}

class _TaggingPageState extends State<TaggingPage>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  late TaggingBloc _taggingBloc;
  bool _isSidebarOpen = false;

  // Example polygon data
  final List<PoligonData> _polygonData = [
    PoligonData(
      id: 'P001',
      polygonType: 'Area',
      points: [
        LatLng(-7.9650, 112.6250),
        LatLng(-7.9650, 112.6350),
        LatLng(-7.9720, 112.6350),
        LatLng(-7.9720, 112.6250),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _taggingBloc =
        context.read<TaggingBloc>()
          ..add(InitTag(project: widget.project))
          ..add(GetCurrentLocation());

    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleController.repeat();

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);
      _taggingBloc.add(UpdateCurrentLocation(newPosition: newLocation));
    });

    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        _taggingBloc.add(UpdateZoom(zoomLevel: event.camera.zoom));
      }

      if (event is MapEventRotate) {
        _taggingBloc.add(UpdateRotation(rotation: event.camera.rotation));
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _showMarkerDialog(TagData tagData) {
    showDialog(
      context: context,
      builder:
          (context) => MarkerDialog(
            tagData: tagData,
            onDelete: (tagData) {
              _taggingBloc.add(DeleteTag(tagData));
            },
            onMove: (tagData) {},
          ),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
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
        clickedTag.position,
        tag.position,
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaggingBloc, TaggingState>(
      listener: (context, state) {
        if (state is TagSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location tagged successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is TagError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
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
            _mapController.move(selectedTag.position, state.data.currentZoom);
            _toggleSidebar();
          }
        } else if (state is RecordedLocation) {
          _mapController.move(
            state.data.formFields['position']?.value ??
                LatLng(-7.9666, 112.6326),
            state.data.currentZoom,
          );
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => TaggingFormDialog(),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(-7.9666, 112.6326),
                      initialZoom: state.data.currentZoom,
                      onLongPress: (tapPosition, point) => {},
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.kendedes_mobile',
                      ),

                      // Polygon layer
                      PolygonLayer(
                        polygons:
                            _polygonData
                                .map(
                                  (polygonData) => Polygon(
                                    points: polygonData.points,
                                    color: Colors.orange.withValues(alpha: 0.3),
                                    borderStrokeWidth: 2,
                                    borderColor: Colors.orange,
                                  ),
                                )
                                .toList(),
                      ),

                      // Marker layer from bloc state
                      MarkerLayer(
                        markers: [
                          // User tags: show selected tags above non-selected tags
                          ...[
                            ...state.data.tags.where(
                              (tag) => !state.data.selectedTags.contains(tag),
                            ),
                            ...state.data.selectedTags,
                          ].map((tagData) {
                            final isSelected = state.data.selectedTags.contains(
                              tagData,
                            );
                            return Marker(
                              point: tagData.position,
                              width: isSelected ? 40 : 30,
                              height: isSelected ? 40 : 30,
                              child: MarkerWidget(
                                tagData: tagData,
                                isSelected: isSelected,
                                onTap:
                                    () => _handleMarkerClick(
                                      tagData,
                                      state.data.tags,
                                      state.data.selectedTags,
                                      state.data.currentZoom,
                                      mapSize,
                                    ),
                              ),
                            );
                          }),

                          // Current location marker
                          if (state.data.currentLocation != null)
                            Marker(
                              point: state.data.currentLocation!,
                              width: 60,
                              height: 60,
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
                                          width: 60 * _rippleAnimation.value,
                                          height: 60 * _rippleAnimation.value,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue.withValues(
                                              alpha:
                                                  (1 - _rippleAnimation.value) *
                                                  0.3,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.withValues(
                                                alpha:
                                                    1 - _rippleAnimation.value,
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
                    ],
                  ),

                  // Floating title bar
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 15,
                    left: 15,
                    right: 15,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.deepOrange],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.data.project.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.list_alt,
                                color: Colors.white,
                              ),
                              onPressed: _toggleSidebar,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Compass button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 85,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Transform.rotate(
                        angle: state.data.rotation * math.pi / 180,
                        child: IconButton(
                          icon: const Icon(
                            Icons.navigation_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                          onPressed: () {
                            // Reset map rotation
                            _mapController.rotate(0.0);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Main tag location button
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: BlocBuilder<TaggingBloc, TaggingState>(
                      builder: (context, state) {
                        return Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              splashColor: Colors.white.withValues(alpha: 0.2),
                              highlightColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              onTap:
                                  state.data.isLoadingTag
                                      ? null
                                      : () =>
                                          _taggingBloc.add(RecordTagLocation()),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (state.data.isLoadingTag)
                                    const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.add_location_alt,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    state.data.isLoadingTag
                                        ? 'Tagging...'
                                        : 'Tag Location',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Download polygon button
                  Positioned(
                    bottom: 170,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Colors.orange,
                          size: 24,
                        ),
                        onPressed: () {
                          // Download polygon functionality
                        },
                      ),
                    ),
                  ),

                  // My location button
                  Positioned(
                    bottom: 110,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon:
                            state.data.isLoadingCurrentLocation
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(
                                  Icons.my_location,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                        onPressed:
                            state.data.isLoadingCurrentLocation
                                ? null
                                : () => _taggingBloc.add(
                                  const GetCurrentLocation(),
                                ),
                      ),
                    ),
                  ),

                  // Sidebar overlay
                  if (_isSidebarOpen)
                    GestureDetector(
                      onTap: _toggleSidebar,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),

                  // Right sidebar
                  SidebarWidget(
                    tags: state.data.tags,
                    selectedTags: state.data.selectedTags,
                    isSidebarOpen: _isSidebarOpen,
                    isMultiSelectMode: state.data.isMultiSelectMode,
                    onToggleSidebar: _toggleSidebar,
                    onTagTap: (tag) {
                      if (state.data.isMultiSelectMode) {
                        if (state.data.selectedTags.contains(tag)) {
                          _taggingBloc.add(RemoveTagFromSelection(tag));
                        } else {
                          _taggingBloc.add(AddTagToSelection(tag));
                        }
                      } else {
                        _taggingBloc.add(SelectTag(tag));
                      }
                    },
                    onTagLongPress: (tag) {
                      if (!state.data.isMultiSelectMode) {
                        _taggingBloc.add(ToggleMultiSelectMode());
                        _taggingBloc.add(AddTagToSelection(tag));
                      }
                    },
                    toggleMultiSelectMode:
                        () => _taggingBloc.add(ToggleMultiSelectMode()),
                    clearTagSelection:
                        () => _taggingBloc.add(ClearTagSelection()),
                    deleteSelectedTags: () {
                      if (state.data.selectedTags.length == 1) {
                        // Direct delete for single tag
                        _taggingBloc.add(DeleteSelectedTags());
                      } else if (state.data.selectedTags.length > 1) {
                        // Show confirmation dialog for multiple tags
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DeleteTaggingConfirmationDialog(
                              tagCount: state.data.selectedTags.length,
                              onConfirm: () {
                                Navigator.of(context).pop();
                                _taggingBloc.add(DeleteSelectedTags());
                              },
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
