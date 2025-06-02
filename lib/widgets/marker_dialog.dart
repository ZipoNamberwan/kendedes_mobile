import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_event.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class MarkerDialog extends StatelessWidget {
  final TagData markerData;

  const MarkerDialog({super.key, required this.markerData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            'ID: ${markerData.id}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Type: ${markerData.type}'),
          SizedBox(height: 8),
          Text(
            'Position: ${markerData.position.latitude.toStringAsFixed(4)}, ${markerData.position.longitude.toStringAsFixed(4)}',
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
                context.read<TaggingBloc>().add(DeleteTag(markerData));
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
  }
}
