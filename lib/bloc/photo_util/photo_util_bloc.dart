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
import 'package:kendedes_mobile/classes/repositories/local_db/photo_db_repository.dart';
import 'package:uuid/uuid.dart';

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

  final Uuid _uuid = const Uuid();

  PhotoUtilBloc() : super(InitState()) {
    on<Initialize>((event, emit) async {
      List<Family> existingFamilies =
          await PhotoDbRepository().getAllFamilies();
      emit(
        PhotoUtilState(
          data: state.data.copyWith(
            families: existingFamilies,
            filteredFamilies: existingFamilies,
            resetForm: true,
            resetProcessingMessage: true,
          ),
        ),
      );
    });

    on<InitForm>((event, emit) async {
      // Initialize repository
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

    on<RefreshList>((event, emit) async {
      List<Family> existingFamilies =
          await PhotoDbRepository().getAllFamilies();
      emit(
        PhotoUtilState(
          data: state.data.copyWith(
            families: existingFamilies,
            filteredFamilies: existingFamilies,
            resetForm: true,
            resetProcessingMessage: true,
            resetSearchQuery: true,
          ),
        ),
      );
    });

    on<SearchFamily>((event, emit) {
      final query = event.query.toLowerCase();
      final filtered =
          state.data.families.where((family) {
            return family.name.toLowerCase().contains(query) ||
                family.address.toLowerCase().contains(query);
          }).toList();

      // Sort by createdAt descending (newest first)
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(
        PhotoUtilState(
          data: state.data.copyWith(
            filteredFamilies: filtered,
            searchQuery: event.query,
          ),
        ),
      );
    });

    on<SetPhotoFileField>((event, emit) {
      // Generate a unique ID using UUID
      final id = _uuid.v4();
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

        // Save family data to local database
        await _saveFamilyToDatabase(formFields);

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

    on<SelectFamily>((event, emit) {
      List<Family> updatedSelectedFamilies = List.from(
        state.data.selectedFamilies,
      );

      final exists = updatedSelectedFamilies.any(
        (f) => f.id == event.family.id,
      );

      if (exists) {
        updatedSelectedFamilies.removeWhere((f) => f.id == event.family.id);
      } else {
        updatedSelectedFamilies.add(event.family);
      }

      emit(
        PhotoUtilState(
          data: state.data.copyWith(selectedFamilies: updatedSelectedFamilies),
        ),
      );
    });

    on<SetSelectMode>((event, emit) {
      emit(
        PhotoUtilState(
          data: state.data.copyWith(
            isSelectMode: event.isSelectMode,
            selectedFamilies:
                event.isSelectMode ? state.data.selectedFamilies : [],
          ),
        ),
      );
    });

    on<ToggleSelectAllFamilies>((event, emit) {
      final allFamilies = state.data.families;
      final selectedFamilies = state.data.selectedFamilies;
      final isAllSelected = allFamilies.every(
        (f) => selectedFamilies.contains(f),
      );

      if (isAllSelected) {
        emit(PhotoUtilState(data: state.data.copyWith(selectedFamilies: [])));
      } else {
        emit(
          PhotoUtilState(
            data: state.data.copyWith(selectedFamilies: allFamilies),
          ),
        );
      }
    });

    on<DeleteFamilies>((event, emit) async {
      emit(PhotoUtilState(data: state.data.copyWith(isDeleteLoading: true)));

      try {
        for (var family in state.data.selectedFamilies) {
          await PhotoDbRepository().deleteFamily(family.id);
        }

        // Reload the list from DB so the grid reflects the deletion
        final updatedFamilies = await PhotoDbRepository().getAllFamilies();

        emit(
          DeleteSuccess(
            data: state.data.copyWith(
              families: updatedFamilies,
              filteredFamilies: updatedFamilies,
              selectedFamilies: [],
              isSelectMode: false,
              isDeleteLoading: false,
            ),
          ),
        );
      } catch (e) {
        emit(
          DeleteFailed(
            'Gagal menghapus data: $e',
            data: state.data.copyWith(
              isDeleteLoading: false,
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

  Future<void> _saveFamilyToDatabase(
    Map<String, PhotoUtilFieldState<dynamic>> formFields,
  ) async {
    final name = formFields['name']?.value as String;
    final address = formFields['address']?.value as String? ?? '';
    final familyId = _uuid.v4();

    // Collect photos from form fields
    final familyPhotos = <FamilyPhoto>[];
    for (final type in PhotoType.values) {
      final photoData = formFields[type.key]?.value as PhotoFieldForm?;
      if (photoData != null && photoData.filename != null) {
        familyPhotos.add(
          FamilyPhoto(
            id: photoData.id,
            type: photoData.type,
            filename: photoData.filename!,
          ),
        );
      }
    }

    // Create Family object
    final family = Family(
      id: familyId,
      name: name,
      address: address,
      photos: familyPhotos,
      createdAt: DateTime.now(),
    );

    // Save to database
    await PhotoDbRepository().insertFamily(family);
  }
}

class ValidationResult {
  final Map<String, PhotoUtilFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ValidationResult(this.updatedFields, this.hasErrors);
}
