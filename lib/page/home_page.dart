import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_event.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/models/poligon_data.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/widgets/marker_dialog.dart';
import 'package:kendedes_mobile/widgets/marker_widget.dart';
import 'package:kendedes_mobile/widgets/sidebar_widget.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomePageContent();
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePageContent>
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
    _taggingBloc = TaggingBloc();

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

  void _showMarkerDialog(TagData markerData) {
    showDialog(
      context: context,
      builder: (context) => MarkerDialog(markerData: markerData),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaggingBloc>(
      create: (context) => _taggingBloc..add(GetCurrentLocation()),
      child: BlocConsumer<TaggingBloc, TaggingState>(
        listener: (context, state) {
          if (state is TagSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location tagged successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            _mapController.move(state.newTag.position, state.data.currentZoom);
          } else if (state is TagError) {
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
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
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
                        // User tags
                        ...state.data.tags.map((markerData) {
                          final isSelected = state.data.selectedTags.contains(
                            markerData,
                          );
                          return Marker(
                            point: markerData.position,
                            width: isSelected ? 40 : 30,
                            height: isSelected ? 40 : 30,
                            child: MarkerWidget(
                              markerData: markerData,
                              isSelected: isSelected,
                              onTap: () => _showMarkerDialog(markerData),
                            ),
                          );
                        }),

                        // Current location marker
                        if (state.data.currentLocation != null)
                          Marker(
                            point: state.data.currentLocation!,
                            width: 60,
                            height: 60,
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
                                            alpha: 1 - _rippleAnimation.value,
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
                        const Expanded(
                          child: Text(
                            'Kendedes Mobile',
                            style: TextStyle(
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
                            highlightColor: Colors.white.withValues(alpha: 0.1),
                            onTap:
                                state.data.isLoadingTag
                                    ? null
                                    : () {
                                      context.read<TaggingBloc>().add(
                                        const TagLocation(),
                                      );
                                    },
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
                              : () {
                                context.read<TaggingBloc>().add(
                                  const GetCurrentLocation(),
                                );
                              },
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
                  onToggleSidebar: _toggleSidebar,
                  onTagTap: (tag) => _taggingBloc.add(SelectTag(tag)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
