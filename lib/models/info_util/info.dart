import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Info {
  final String id;
  final String title;
  final String? subtitle;
  final String? tags;
  final String? type;
  final String? content;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool needUpdate;
  final bool isRead;

  const Info({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.type,
    required this.content,
    required this.isPublished,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.needUpdate,
    required this.isRead,
  });

  /// Creates an [Info] instance from a JSON map (server response `data` field).
  factory Info.fromServerJson(Map<String, dynamic> json) {
    return Info(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      tags: json['tags'] as String?,
      type: json['type'] as String?,
      content: json['content'] as String?,
      isPublished: (json['is_published'] as int) == 1,
      publishedAt:
          json['published_at'] != null
              ? DateTime.parse(json['published_at'] as String)
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      needUpdate: true,
      isRead: false,
    );
  }

  factory Info.fromDbJson(Map<String, dynamic> json) {
    return Info(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      tags: json['tags'] as String?,
      type: json['type'] as String?,
      content: json['content'] as String?,
      isPublished: (json['is_published'] as int) == 1,
      publishedAt:
          json['published_at'] != null
              ? DateTime.parse(json['published_at'] as String)
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      needUpdate: json['need_update'] == 1 ? true : false,
      isRead: json['is_read'] == 1 ? true : false,
    );
  }

  /// Serializes this [Info] instance back to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'tags': tags,
      'type': type,
      'content': content,
      'is_published': isPublished ? 1 : 0,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'need_update': needUpdate,
      'is_read': isRead,
    };
  }

  Color getTypeColor() {
    switch (type) {
      case 'announcement':
        return Colors.deepOrange.shade500;
      case 'faq':
        return Colors.teal.shade500;
      case 'problem-solution':
        return Colors.amber.shade700;
      case 'other':
        return Colors.blueGrey.shade400;
      default:
        return Colors.blueGrey.shade400;
    }
  }

  String getTypeLabel() {
    switch (type) {
      case 'announcement':
        return 'Pengumuman';
      case 'faq':
        return 'FAQ';
      case 'problem-solution':
        return 'Kendala/Solusi';
      case 'other':
        return 'Lainnya';
      default:
        return type ?? '-';
    }
  }

  String getFormatDate() {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(updatedAt);
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(updatedAt);
    }
  }
}
