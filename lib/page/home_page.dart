import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();

  // Example marker data with details
  final List<Map<String, dynamic>> _markerData = [
    {'id': 'M001', 'type': 'Point A', 'position': LatLng(-7.9666, 112.6326)},
    {'id': 'M002', 'type': 'Point B', 'position': LatLng(-7.9700, 112.6400)},
    {'id': 'M003', 'type': 'Point C', 'position': LatLng(-7.9600, 112.6300)},
    {'id': 'M004', 'type': 'Point D', 'position': LatLng(-7.9750, 112.6280)},
    {'id': 'M005', 'type': 'Point E', 'position': LatLng(-7.9580, 112.6380)},
  ];

  // Example polygon points
  final List<LatLng> _polygonPoints = [
    LatLng(-7.9650, 112.6250),
    LatLng(-7.9650, 112.6350),
    LatLng(-7.9720, 112.6350),
    LatLng(-7.9720, 112.6250),
  ];

  Widget _buildMarker(Map<String, dynamic> markerData) {
    return GestureDetector(
      onTap: () => _showMarkerDialog(markerData),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.location_on, color: Colors.white, size: 16),
      ),
    );
  }

  void _showMarkerDialog(Map<String, dynamic> markerData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.orange),
              SizedBox(width: 8),
              Text('Marker Details'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${markerData['id']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Type: ${markerData['type']}'),
              SizedBox(height: 8),
              Text(
                'Position: ${markerData['position'].latitude.toStringAsFixed(4)}, ${markerData['position'].longitude.toStringAsFixed(4)}',
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Edit functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Delete functionality
                  },
                ),
                TextButton(
                  child: Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(-7.9666, 112.6326),
              initialZoom: 13.0,
              onLongPress:
                  (tapPosition, point) => {print('Long pressed at: $point')},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kendedes_mobile',
              ),

              // Polygon layer
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _polygonPoints,
                    color: Colors.orange.withValues(alpha: 0.3),
                    borderStrokeWidth: 2,
                    borderColor: Colors.orange,
                  ),
                ],
              ),

              // Marker layer
              MarkerLayer(
                markers:
                    _markerData
                        .map(
                          (markerData) => Marker(
                            point: markerData['position'],
                            width: 30,
                            height: 30,
                            child: _buildMarker(markerData),
                          ),
                        )
                        .toList(),
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
                  const Icon(Icons.location_on, color: Colors.white, size: 24),
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
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {},
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
              child: IconButton(
                icon: const Icon(
                  Icons.navigation_outlined,
                  color: Colors.grey,
                  size: 24,
                ),
                onPressed: () {
                  // Reset map rotation
                },
              ),
            ),
          ),

          // Main tag location button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
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
                  onTap: () {
                    // Tag location functionality
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_location_alt,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Tag Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                icon: const Icon(
                  Icons.my_location,
                  color: Colors.orange,
                  size: 24,
                ),
                onPressed: () {
                  // Get current location
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
