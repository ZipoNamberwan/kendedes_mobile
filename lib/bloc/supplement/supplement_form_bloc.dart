import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/supplement/supplement_form_event.dart';
import 'package:kendedes_mobile/bloc/supplement/supplement_form_state.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class SupplementFormBloc
    extends Bloc<SupplementFormEvent, SupplementFormState> {
  final Uuid _uuid = const Uuid();

  SupplementFormBloc()
    : super(
        SupplementFormState(
          data: SupplementFormStateData(
            position: LatLng(0, 0),
            isSubmitting: false,
          ),
        ),
      ) {
    on<CreateForm>((event, emit) {
      emit(SupplementFormState(data: state.data.copyWith(resetForm: true)));
    });

    Map<String, SupplementFormFieldState<dynamic>> updateFieldValue(
      Map<String, SupplementFormFieldState<dynamic>> fields,
      String key,
      dynamic value,
    ) {
      final field = fields[key];

      if (field == null) return fields;

      if (field is SupplementFormFieldState<String>) {
        return {...fields, key: field.copyWith(value: value as String)};
      } else if (field is SupplementFormFieldState<String?>) {
        return {...fields, key: field.copyWith(value: value as String?)};
      } else if (field is SupplementFormFieldState<BuildingStatus>) {
        return {...fields, key: field.copyWith(value: value as BuildingStatus)};
      } else if (field is SupplementFormFieldState<Sector>) {
        return {...fields, key: field.copyWith(value: value as Sector)};
      }

      return fields;
    }

    on<SetSupplementFormField>((event, emit) {
      final updatedFormFields = updateFieldValue(
        state.data.formFields,
        event.key,
        event.value,
      );
      emit(
        SupplementFormState(
          data: state.data.copyWith(formFields: updatedFormFields),
        ),
      );
    });

    on<SaveForm>((event, emit) {
      emit(SupplementFormState(data: state.data.copyWith(isSubmitting: true)));

      final formFields = state.data.formFields;
      final validationResult = _validateForm(formFields);

      if (validationResult.hasErrors) {
        emit(
          SupplementFormState(
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              isSubmitting: false,
            ),
          ),
        );
        return;
      }

      final tagData = _createTagData(formFields);

      emit(
        TagDataSaved(
          tagData,
          data: state.data.copyWith(
            isSubmitting: false,
            formFields: validationResult.updatedFields,
          ),
        ),
      );
    });
  }

  ValidationResult _validateForm(
    Map<String, SupplementFormFieldState<dynamic>> formFields,
  ) {
    Map<String, SupplementFormFieldState<dynamic>> updatedFields = Map.from(
      formFields,
    );
    bool hasErrors = false;

    // Validate name
    final name = formFields['name']?.value as String? ?? '';
    if (name.isEmpty) {
      updatedFields['name'] = updatedFields['name']!.copyWith(
        error: 'Nama Usaha Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else {
      updatedFields['name'] = updatedFields['name']!.clearError();
    }

    // Validate description
    final description = formFields['description']?.value as String? ?? '';
    if (description.isEmpty) {
      updatedFields['description'] = updatedFields['description']!.copyWith(
        error: 'Deskripsi Aktivitas Usaha Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else {
      updatedFields['description'] = updatedFields['description']!.clearError();
    }

    // Validate address
    final address = formFields['address']?.value as String? ?? '';
    if (address.isEmpty) {
      updatedFields['address'] = updatedFields['address']!.copyWith(
        error: 'Alamat Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else {
      updatedFields['address'] = updatedFields['address']!.clearError();
    }

    // Validate building
    final building = formFields['building']?.value as BuildingStatus? ;
    if (building == null) {
      updatedFields['building'] = updatedFields['building']!.copyWith(
        error: 'Status Bangunan Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else {
      updatedFields['building'] = updatedFields['building']!.clearError();
    }

    // Validate sector
    final sector = formFields['sector']?.value as Sector?;
    if (sector == null) {
      updatedFields['sector'] = updatedFields['sector']!.copyWith(
        error: 'Sektor Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else {
      updatedFields['sector'] = updatedFields['sector']!.clearError();
    }

    return ValidationResult(updatedFields, hasErrors);
  }

  TagData _createTagData(
    Map<String, SupplementFormFieldState<dynamic>> formFields,
  ) {
    final tagDataId = formFields['id']?.value as String?;
    final name = formFields['name']?.value as String;
    final owner = formFields['owner']?.value as String?;
    final address = formFields['address']?.value as String?;
    final building = formFields['building']?.value as BuildingStatus;
    final description = formFields['description']?.value as String;
    final sector = formFields['sector']?.value as Sector;
    final note = formFields['note']?.value as String?;

    final isNewTag = tagDataId == null || tagDataId.isEmpty;

    return TagData(
      id: isNewTag ? _uuid.v4() : tagDataId,
      position: state.data.position,
      hasChanged: true,
      type: isNewTag ? TagType.auto : TagType.move,
      isDeleted: false,
      businessName: name,
      businessOwner: owner,
      businessAddress: address,
      buildingStatus: building,
      description: description,
      sector: sector,
      note: note,
    );
  }
}

class ValidationResult {
  final Map<String, SupplementFormFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ValidationResult(this.updatedFields, this.hasErrors);
}
