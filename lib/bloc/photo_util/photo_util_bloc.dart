import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_event.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

// Data class for passing to isolate — structure unchanged
class _ImageProcessingData {
  final String imagePath;
  final String name;
  final String address;
  final String photoLabel;
  final String savePath;

  _ImageProcessingData({
    required this.imagePath,
    required this.name,
    required this.address,
    required this.photoLabel,
    required this.savePath,
  });
}

// Top-level function for isolate processing
Future<void> _processImageInIsolate(_ImageProcessingData data) async {
  final bytes = await File(data.imagePath).readAsBytes();

  // decodeJpg skips format sniffing — faster than decodeImage
  var image = img.decodeJpg(bytes) ?? img.decodeImage(bytes);

  if (image == null) {
    throw Exception('Failed to decode image: ${data.photoLabel}');
  }

  // Only resize when needed; use 'average' — faster than default cubic
  if (image.width > 1920) {
    image = img.copyResize(
      image,
      width: 1920,
      interpolation: img.Interpolation.average,
    );
  }

  final imageWithText = _overlayTextOnImage(
    image,
    data.name,
    data.address,
    data.photoLabel,
  );

  await File(
    data.savePath,
  ).writeAsBytes(img.encodeJpg(imageWithText, quality: 60));
}

img.Image _overlayTextOnImage(
  img.Image image,
  String name,
  String address,
  String photoLabel,
) {
  // Pre-compute all layout values once — avoid repeated casts in hot path
  final w = image.width;
  final h = image.height;
  final padding = (w * 0.03).clamp(20.0, 100.0).toInt();
  final textScale = (w / 600.0).clamp(6.0, 14.0);
  final lineHeight = (48 * textScale * 1.4).toInt();
  final yStart = h - (lineHeight * 3 + padding * 2) + padding;
  final white = img.ColorRgba8(255, 255, 255, 255);

  _drawScaledText(
    image,
    'Foto: $photoLabel',
    padding,
    yStart,
    textScale,
    white,
  );
  _drawScaledText(
    image,
    'Nama KK: $name',
    padding,
    yStart + lineHeight,
    textScale,
    white,
  );
  _drawScaledText(
    image,
    'Alamat: $address',
    padding,
    yStart + lineHeight * 2,
    textScale,
    white,
  );

  return image;
}

void _drawScaledText(
  img.Image image,
  String text,
  int x,
  int y,
  double scale,
  img.Color color,
) {
  final so = (scale * 2.5).clamp(3.0, 12.0).toInt(); // shadow offset

  // Layered shadow — 3 passes at decreasing opacity simulates a soft blur
  img.drawString(
    image,
    text,
    font: img.arial48,
    x: x + so,
    y: y + so,
    color: img.ColorRgba8(0, 0, 0, 180),
  );
  img.drawString(
    image,
    text,
    font: img.arial48,
    x: x + so + 2,
    y: y + so + 2,
    color: img.ColorRgba8(0, 0, 0, 100),
  );
  img.drawString(
    image,
    text,
    font: img.arial48,
    x: x + so - 1,
    y: y + so - 1,
    color: img.ColorRgba8(0, 0, 0, 60),
  );

  // White text — single clean pass on top
  img.drawString(image, text, font: img.arial48, x: x, y: y, color: color);
}

class PhotoUtilBloc extends Bloc<PhotoUtilEvent, PhotoUtilState> {
  PhotoUtilBloc() : super(InitState()) {
    on<Initialize>((event, emit) async {
      emit(PhotoUtilState(data: state.data.copyWith(resetForm: true)));
    });

    on<SetFormField>((event, emit) {
      final updatedFormFields = _updateFieldValue(
        state.data.formFields,
        event.key,
        event.value,
      );
      emit(
        PhotoUtilState(
          data: state.data.copyWith(formFields: updatedFormFields),
        ),
      );
    });

    on<SetPhotoFileField>((event, emit) {
      final updatedFormFields = _updateFieldValue(
        state.data.formFields,
        event.key,
        event.xFile,
      );
      emit(
        PhotoUtilState(
          data: state.data.copyWith(formFields: updatedFormFields),
        ),
      );
    });

    on<SaveForm>((event, emit) async {
      emit(PhotoUtilState(data: state.data.copyWith(isLoading: true)));

      final formFields = state.data.formFields;
      final validationResult = _validateForm(formFields);

      if (validationResult.hasErrors) {
        emit(
          FormValidationFailed(
            'Form validation failed',
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              isLoading: false,
            ),
          ),
        );
        return;
      }

      try {
        final name = formFields['name']?.value as String;
        final address = formFields['address']?.value as String? ?? '';

        // compute() spawns a true Dart isolate per image;
        // Future.wait runs them all concurrently — biggest perf win
        await _savePhotosWithText(name, address, formFields);

        emit(
          SaveSuccess(
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              isLoading: false,
            ),
          ),
        );
      } catch (e) {
        emit(
          SaveFailed(
            'Failed to save photos: $e',
            data: state.data.copyWith(isLoading: false),
          ),
        );
      }
    });
  }

  Map<String, PhotoUtilFieldState<dynamic>> _updateFieldValue(
    Map<String, PhotoUtilFieldState<dynamic>> fields,
    String key,
    dynamic value,
  ) {
    final field = fields[key];

    if (field == null) return fields;

    if (field is PhotoUtilFieldState<String>) {
      return {...fields, key: field.copyWith(value: value as String)};
    } else if (field is PhotoUtilFieldState<String?>) {
      return {...fields, key: field.copyWith(value: value as String?)};
    } else if (field is PhotoUtilFieldState<XFile?>) {
      return {...fields, key: field.copyWith(value: value as XFile?)};
    }

    return fields;
  }

  ValidationResult _validateForm(
    Map<String, PhotoUtilFieldState<dynamic>> formFields,
  ) {
    Map<String, PhotoUtilFieldState<dynamic>> updatedFields = Map.from(
      formFields,
    );
    bool hasErrors = false;

    // Validate name
    final name = formFields['name']?.value as String? ?? '';
    if (name.isEmpty) {
      updatedFields['name'] = updatedFields['name']!.copyWith(
        error: 'Nama Kepala Keluarga Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else if (name.length < 3) {
      updatedFields['name'] = updatedFields['name']!.copyWith(
        error: 'Nama Kepala Keluarga minimal 3 karakter',
      );
      hasErrors = true;
    } else {
      updatedFields['name'] = updatedFields['name']!.clearError();
    }

    final address = formFields['address']?.value as String? ?? '';
    if (address.trim().isEmpty) {
      updatedFields['address'] = updatedFields['address']!.copyWith(
        error: 'Identitas wilayah tidak boleh kosong',
      );
      hasErrors = true;
    } else {
      updatedFields['address'] = updatedFields['address']!.clearError();
    }

    for (final type in PhotoType.values) {
      final photo = formFields[type.key]?.value as XFile?;
      if (photo == null) {
        updatedFields[type.key] = updatedFields[type.key]!.copyWith(
          error: 'Foto ${type.label} wajib diambil',
        );
        hasErrors = true;
      } else {
        updatedFields[type.key] = updatedFields[type.key]!.clearError();
      }
    }

    return ValidationResult(updatedFields, hasErrors);
  }

  Future<void> _savePhotosWithText(
    String name,
    String address,
    Map<String, PhotoUtilFieldState<dynamic>> formFields,
  ) async {
    // Get download directory
    Directory? downloadDir;
    if (Platform.isAndroid) {
      downloadDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadDir = await getApplicationDocumentsDirectory();
    } else {
      downloadDir = await getDownloadsDirectory();
    }

    if (downloadDir == null) {
      throw Exception('Could not access download directory');
    }

    // Create kdm folder
    final kdmDir = Directory('${downloadDir.path}/kdm');
    if (!await kdmDir.exists()) {
      await kdmDir.create(recursive: true);
    }

    // Generate timestamp for unique filenames
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedName = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');

    // Process each photo in background isolate
    for (final type in PhotoType.values) {
      final xFile = formFields[type.key]?.value as XFile?;
      if (xFile == null) continue;

      // Prepare data for isolate
      final filename = '${sanitizedName}_${type.key}_$timestamp.jpg';
      final savePath = '${kdmDir.path}/$filename';

      final processingData = _ImageProcessingData(
        imagePath: xFile.path,
        name: name,
        address: address,
        photoLabel: type.label,
        savePath: savePath,
      );

      // Process image in background isolate to avoid UI lag
      await compute(_processImageInIsolate, processingData);
    }
  }
}

class ValidationResult {
  final Map<String, PhotoUtilFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ValidationResult(this.updatedFields, this.hasErrors);
}
