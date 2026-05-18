import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_event.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_state.dart';

class PhotoUtilBloc extends Bloc<PhotoUtilEvent, PhotoUtilState> {
  PhotoUtilBloc() : super(InitState()) {
    on<Initialize>((event, emit) async {});

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
        'photoFile',
        event.xFile,
      );
      emit(
        PhotoFileTakenSuccess(
          data: state.data.copyWith(formFields: updatedFormFields),
        ),
      );
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
}

class ValidationResult {
  final Map<String, PhotoUtilFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ValidationResult(this.updatedFields, this.hasErrors);
}
