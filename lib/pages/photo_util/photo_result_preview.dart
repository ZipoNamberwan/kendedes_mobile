import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';
import 'package:intl/intl.dart';

class PhotoResultPreview extends StatefulWidget {
  final Family family;

  const PhotoResultPreview({super.key, required this.family});

  @override
  State<PhotoResultPreview> createState() => _PhotoResultPreviewState();
}

class _PhotoResultPreviewState extends State<PhotoResultPreview> {
  late PageController _pageController;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
  }

  Future<File> _getPhotoFile(String filename) async {
    String downloadPath;
    if (Platform.isAndroid) {
      downloadPath = '/storage/emulated/0/Download/kdm';
    } else {
      downloadPath = '/Download/kdm';
    }
    return File('$downloadPath/$filename');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with family info
            Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.family.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (widget.family.address.isNotEmpty)
                              Text(
                                widget.family.address,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateTime(widget.family.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Storage location info banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.shade700.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Colors.blue.shade300,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Foto disimpan di Galeri (album KDM) dan folder Downloads/kdm',
                            style: TextStyle(
                              color: Colors.blue.shade100,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.family.photos.length > 1) ...[
                    const SizedBox(height: 12),
                    // Photo type indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.family.photos[_currentPhotoIndex].type.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Photo viewer with swipe
            Expanded(
              child:
                  widget.family.photos.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_outlined,
                              size: 64,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada foto',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : PageView.builder(
                        controller: _pageController,
                        itemCount: widget.family.photos.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPhotoIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final photo = widget.family.photos[index];
                          return FutureBuilder<File>(
                            future: _getPhotoFile(photo.filename),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.deepOrange,
                                  ),
                                );
                              }

                              if (snapshot.hasError ||
                                  !snapshot.hasData ||
                                  !snapshot.data!.existsSync()) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        size: 64,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Foto tidak ditemukan',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // InteractiveViewer for zoom functionality
                              return InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: Center(
                                  child: Image.file(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),

            // Bottom indicator and controls
            if (widget.family.photos.length > 1)
              Container(
                color: Colors.grey.shade900,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    // Swipe indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_left_rounded,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Geser untuk melihat foto lainnya',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.family.photos.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentPhotoIndex == index
                                    ? Colors.deepOrange.shade600
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
