import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_event.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_state.dart';
import 'package:kendedes_mobile/models/photo_util/photo_field_form.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';

// ---------------------------------------------------------------------------
// Data class for isolate - contains compressed bytes (no platform channels)
// ---------------------------------------------------------------------------
class _ImageProcessingData {
  final Uint8List compressedBytes;
  final String name;
  final String address;
  final String photoLabel;
  final String savePath;
  final Uint8List fontBytes;

  _ImageProcessingData({
    required this.compressedBytes,
    required this.name,
    required this.address,
    required this.photoLabel,
    required this.savePath,
    required this.fontBytes,
  });
}

// ---------------------------------------------------------------------------
// Top-level isolate function - ONLY Dart operations (no platform channels)
// Must be top-level to work with compute()
// ---------------------------------------------------------------------------
Future<void> _processImageInIsolate(_ImageProcessingData data) async {
  // Load custom font from bytes
  final font = img.BitmapFont.fromZip(data.fontBytes);

  // Decode the compressed bytes
  final image = img.decodeJpg(data.compressedBytes);

  if (image == null) {
    throw Exception('[${data.photoLabel}] Failed to decode compressed bytes');
  }

  // Text overlay with custom font
  final imageWithText = _overlayTextOnImage(
    image,
    data.name,
    data.address,
    data.photoLabel,
    font,
  );
  final encodedBytes = img.encodeJpg(imageWithText, quality: 35);
  await File(data.savePath).writeAsBytes(encodedBytes);
}

// Helper functions for isolate (must be top-level)
img.Image _overlayTextOnImage(
  img.Image image,
  String name,
  String address,
  String photoLabel,
  img.BitmapFont font,
) {
  final w = image.width;
  final h = image.height;
  final padding = (w * 0.03).clamp(20.0, 100.0).toInt();
  final textScale = (w / 600.0).clamp(6.0, 55.0);
  final lineHeight = (16 * textScale * 1.4).toInt();
  // Position text in bottom 1/3: center the text block within the bottom third
  final totalTextHeight = lineHeight * 3;
  final bottomThirdStart = h * 2 / 3;
  final bottomThirdHeight = h / 3;
  final yStart =
      (bottomThirdStart + (bottomThirdHeight - totalTextHeight) / 2).toInt();
  final white = img.ColorRgba8(255, 255, 255, 255);

  _drawScaledText(image, name, padding, yStart, white, font);
  _drawScaledText(image, address, padding, yStart + lineHeight, white, font);
  _drawScaledText(
    image,
    photoLabel,
    padding,
    yStart + lineHeight * 2,
    white,
    font,
  );

  return image;
}

void _drawScaledText(
  img.Image image,
  String text,
  int x,
  int y,
  img.Color color,
  img.BitmapFont font,
) {
  final shadowOffset = 3;

  // Single shadow layer for speed
  img.drawString(
    image,
    text,
    font: font,
    x: x + shadowOffset,
    y: y + shadowOffset,
    color: img.ColorRgba8(0, 0, 0, 200),
  );

  // White text on top
  img.drawString(image, text, font: font, x: x, y: y, color: color);
}

class PhotoUtilBloc extends Bloc<PhotoUtilEvent, PhotoUtilState> {
  // Configuration: Enable/disable save destinations
  static const bool saveToDownloadsFolder = true;
  static const bool saveToGallery = true;
  static const String galleryAlbumName = 'kdm';

  PhotoUtilBloc() : super(InitState()) {
    on<Initialize>((event, emit) async {
      emit(
        PhotoUtilState(
          data: state.data.copyWith(
            resetForm: true,
            resetProcessingMessage: true,
          ),
        ),
      );
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
      // generate a unique ID consisting of 6 random alphabet char
      final id =
          List.generate(
            6,
            (index) => String.fromCharCode(
              65 + (DateTime.now().millisecondsSinceEpoch + index) % 26,
            ),
          ).join();
      final updatedFormFields = _updateFieldValue(
        state.data.formFields,
        event.key,
        PhotoFieldForm(id: id, type: event.type, file: event.xFile),
      );
      emit(
        PhotoUtilState(
          data: state.data.copyWith(formFields: updatedFormFields),
        ),
      );
    });

    on<SaveForm>((event, emit) async {
      emit(
        Processing(
          data: state.data.copyWith(
            isLoading: true,
            processingMessage: 'Processing photos...',
          ),
        ),
      );

      final formFields = state.data.formFields;
      final validationResult = _validateForm(formFields);

      if (validationResult.hasErrors) {
        emit(
          FormValidationFailed(
            'Form validation failed',
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              isLoading: false,
              resetProcessingMessage: true,
            ),
          ),
        );
        return;
      }

      try {
        // compute() spawns a true Dart isolate per image;
        // Future.wait runs them all concurrently — biggest perf win
        await _savePhotosWithText(emit, formFields);

        emit(
          SaveSuccess(
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              isLoading: false,
              resetProcessingMessage: true,
            ),
          ),
        );
      } catch (e) {
        emit(
          SaveFailed(
            'Failed to save photos: $e',
            data: state.data.copyWith(
              isLoading: false,
              resetProcessingMessage: true,
            ),
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
    } else if (field is PhotoUtilFieldState<PhotoFieldForm?>) {
      return {...fields, key: field.copyWith(value: value as PhotoFieldForm?)};
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

    // final address = formFields['address']?.value as String? ?? '';
    // if (address.trim().isEmpty) {
    //   updatedFields['address'] = updatedFields['address']!.copyWith(
    //     error: 'Identitas wilayah tidak boleh kosong',
    //   );
    //   hasErrors = true;
    // } else {
    //   updatedFields['address'] = updatedFields['address']!.clearError();
    // }

    for (final type in PhotoType.values) {
      final photoData = formFields[type.key]?.value as PhotoFieldForm?;
      if (photoData == null) {
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
    Emitter<PhotoUtilState> emit,
    Map<String, PhotoUtilFieldState<dynamic>> formFields,
  ) async {
    emit(
      Processing(
        data: state.data.copyWith(processingMessage: 'Preparing photos...'),
      ),
    );

    // Load custom font from assets
    final fontData = await rootBundle.load('fonts/sans-serif.zip');
    final fontBytes = fontData.buffer.asUint8List();

    // Get save directory based on configuration
    Directory saveDir;

    if (saveToDownloadsFolder) {
      // Save to Downloads/kdm folder
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

      saveDir = Directory('${downloadDir.path}/kdm');
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }
    } else {
      // Use temporary directory if not saving to Downloads
      final tempDir = await getTemporaryDirectory();
      saveDir = Directory('${tempDir.path}/kdm_processing');
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }
    }

    final name = formFields['name']?.value as String;
    final address = formFields['address']?.value as String? ?? '';
    final sanitizedName = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');

    // Collect all photos to process
    final photosToProcess = <({PhotoFieldForm photoData, int index})>[];

    int index = 0;
    for (final type in PhotoType.values) {
      final photoData = formFields[type.key]?.value as PhotoFieldForm?;
      if (photoData != null) {
        index++;
        final filename =
            '${sanitizedName}_${photoData.type.key}_${photoData.id}.jpg';
        final savePath = '${saveDir.path}/$filename';
        photoData.setFilename(filename);
        photoData.setSavePath(savePath);
        photosToProcess.add((photoData: photoData, index: index));
      }
    }

    emit(
      Processing(
        data: state.data.copyWith(
          processingMessage: 'Compressing ${photosToProcess.length} photos...',
        ),
      ),
    );

    // PHASE 1: Compress all photos in parallel (native compression)
    final compressedResults = await Future.wait(
      photosToProcess.map((photoFieldForm) async {
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          photoFieldForm.photoData.file.path,
          minWidth: 1440, // Reduced from 1920 for faster processing
          minHeight: 1,
          quality: 70, // Optimized for speed
        );

        if (compressedBytes == null || compressedBytes.isEmpty) {
          throw Exception(
            'Native compress failed for ${photoFieldForm.photoData.type.label}',
          );
        }

        return (
          photo: photoFieldForm.photoData,
          compressedBytes: compressedBytes,
        );
      }),
    );

    emit(
      Processing(
        data: state.data.copyWith(processingMessage: 'Adding text overlays...'),
      ),
    );

    // PHASE 2: Process all photos in parallel (Dart operations in isolates)
    await Future.wait(
      compressedResults.map((result) async {
        final processingData = _ImageProcessingData(
          compressedBytes: Uint8List.fromList(result.compressedBytes),
          name: name,
          address: address,
          photoLabel: result.photo.type.label,
          savePath: result.photo.savePath ?? '',
          fontBytes: fontBytes,
        );

        await compute(_processImageInIsolate, processingData);
      }),
    );

    // PHASE 3: Save to gallery if enabled
    if (saveToGallery) {
      emit(
        Processing(
          data: state.data.copyWith(processingMessage: 'Saving to gallery...'),
        ),
      );

      await Future.wait(
        photosToProcess.map((photoFieldForm) async {
          final savePath = photoFieldForm.photoData.savePath;
          if (savePath != null && await File(savePath).exists()) {
            try {
              await Gal.putImage(savePath, album: galleryAlbumName);
            } catch (e) {
              throw Exception(
                'Failed to save ${photoFieldForm.photoData.type.label} to gallery: $e',
              );
            }
          }
        }),
      );
    }

    // Clean up temporary files if not saving to Downloads folder
    if (!saveToDownloadsFolder) {
      try {
        if (await saveDir.exists()) {
          await saveDir.delete(recursive: true);
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    }

    // Build completion message
    final List<String> savedLocations = [];
    if (saveToDownloadsFolder) savedLocations.add('Downloads/kdm folder');
    if (saveToGallery) savedLocations.add('gallery');
    final locationMessage = savedLocations.join(' and ');

    emit(
      Processing(
        data: state.data.copyWith(
          processingMessage: 'Complete! All photos saved to $locationMessage.',
        ),
      ),
    );
  }
}

class ValidationResult {
  final Map<String, PhotoUtilFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ValidationResult(this.updatedFields, this.hasErrors);
}
