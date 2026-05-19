import 'package:image_picker/image_picker.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';

class PhotoFieldForm {
  final PhotoType type;
  final XFile file;

  PhotoFieldForm({required this.type, required this.file});
}
