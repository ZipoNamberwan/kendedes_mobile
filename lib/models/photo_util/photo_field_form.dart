import 'package:image_picker/image_picker.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';

class PhotoFieldForm {
  final String id;
  final PhotoType type;
  final XFile file;
  String? filename;
  String? savePath;

  PhotoFieldForm({
    required this.type,
    required this.file,
    this.filename,
    this.savePath,
    required this.id,
  });

  void setFilename(String newFilename) {
    filename = newFilename;
  }

  void setSavePath(String newSavePath) {
    savePath = newSavePath;
  }
}
