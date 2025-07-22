import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_event.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:kendedes_mobile/widgets/download_polygon_dialog.dart';
import 'package:kendedes_mobile/widgets/delete_polygon_dialog.dart';

class PolygonSidebarWidget extends StatefulWidget {
  final String projectId;
  const PolygonSidebarWidget({super.key, required this.projectId});

  @override
  State<PolygonSidebarWidget> createState() => _PolygonSidebarWidgetState();
}

class _PolygonSidebarWidgetState extends State<PolygonSidebarWidget> {
  late TaggingBloc _taggingBloc;

  @override
  void initState() {
    super.initState();
    _taggingBloc = context.read<TaggingBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaggingBloc, TaggingState>(
      listener: (context, state) {},
      builder: (context, state) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: 0,
          right: state.data.isPolygonSideBarOpen ? 0 : -300,
          bottom: 0,
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 10,
                    left: 20,
                    right: 10,
                  ),
                  decoration: BoxDecoration(color: Colors.purple),
                  child: Row(
                    children: [
                      Icon(Icons.pentagon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'List Poligon',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Close button
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed:
                            () =>
                                _taggingBloc.add(SetPolygonSideBarOpen(false)),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Download Button
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade400,
                                Colors.purple.shade600,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder:
                                      (context) => DownloadPolygonDialog(
                                        projectId: widget.projectId,
                                      ),
                                );

                                _taggingBloc.add(const UpdatePolygon());
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.download,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Download Poligon',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Search Field
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey.shade100,
                        //     borderRadius: BorderRadius.circular(8),
                        //     border: Border.all(
                        //       color: Colors.grey.shade300,
                        //       width: 1,
                        //     ),
                        //   ),
                        //   child: TextField(
                        //     decoration: InputDecoration(
                        //       hintText: 'Cari poligon...',
                        //       hintStyle: TextStyle(
                        //         color: Colors.grey.shade500,
                        //         fontSize: 14,
                        //       ),
                        //       prefixIcon: Icon(
                        //         Icons.search,
                        //         color: Colors.grey.shade500,
                        //         size: 20,
                        //       ),
                        //       border: InputBorder.none,
                        //       contentPadding: const EdgeInsets.symmetric(
                        //         horizontal: 16,
                        //         vertical: 12,
                        //       ),
                        //     ),
                        //     style: const TextStyle(fontSize: 14),
                        //     onChanged: (value) {
                        //       // TODO: Search polygon logic
                        //     },
                        //   ),
                        // ),

                        // const SizedBox(height: 16),

                        // Polygon List Header
                        Row(
                          children: [
                            Icon(
                              Icons.list_rounded,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Daftar Poligon',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Polygon List
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child:
                                state.data.polygons.isEmpty
                                    ? const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.pentagon_outlined,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Belum ada poligon',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Download poligon untuk melihat daftar',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: state.data.polygons.length,
                                      itemBuilder: (context, index) {
                                        final polygon =
                                            state.data.polygons[index];
                                        return _buildPolygonItem(polygon);
                                      },
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolygonItem(Polygon polygon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                _taggingBloc.add(SelectPolygon(polygon: polygon));
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'ID: ${polygon.id}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      polygon.fullName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Type: ${_getIndonesianTypeName(polygon.type.name)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        // Text(
                        //   'Node: ${polygon.points.length}',
                        //   style: const TextStyle(fontSize: 10, color: Colors.grey),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Delete Button positioned in center right
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => DeletePolygonDialog(
                              polygon: polygon,
                              onConfirm: () {
                                _taggingBloc.add(
                                  DeletePolygon(polygon: polygon),
                                );
                              },
                            ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.shade300,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIndonesianTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'regency':
        return 'KABUPATEN';
      case 'subdistrict':
        return 'KECAMATAN';
      case 'village':
        return 'DESA';
      case 'sls':
        return 'SLS';
      default:
        return type.toUpperCase();
    }
  }
}
