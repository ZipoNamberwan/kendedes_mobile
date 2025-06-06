import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';

class SupplementFormState extends Equatable {
  final SupplementFormStateData data;

  const SupplementFormState({required this.data});

  @override
  List<Object> get props => [data];
}

class ProjectLoaded extends SupplementFormState {
  const ProjectLoaded({required super.data});
}

class TagDataSaved extends SupplementFormState {
  final TagData tagData;
  const TagDataSaved(this.tagData, {required super.data});
}

class SupplementFormStateData {
  final LatLng position;
  final bool isSubmitting;
  final Map<String, SupplementFormFieldState<dynamic>> formFields;

  SupplementFormStateData({
    required this.position,
    required this.isSubmitting,
    Map<String, SupplementFormFieldState<dynamic>>? formFields,
  }) : formFields = formFields ?? _generateFormFields();

  // Automatically generate form fields based on defined field keys
  static Map<String, SupplementFormFieldState<dynamic>> _generateFormFields() {
    final formFields = <String, SupplementFormFieldState<dynamic>>{};

    formFields['id'] = SupplementFormFieldState<String?>();
    formFields['name'] = SupplementFormFieldState<String>();
    formFields['owner'] = SupplementFormFieldState<String?>();
    formFields['address'] = SupplementFormFieldState<String?>();
    formFields['building'] = SupplementFormFieldState<BuildingStatus>();
    formFields['description'] = SupplementFormFieldState<String>();
    formFields['sector'] = SupplementFormFieldState<Sector>();
    formFields['note'] = SupplementFormFieldState<String?>();

    return formFields;
  }

  SupplementFormStateData copyWith({
    LatLng? position,
    bool? isSubmitting,
    Map<String, SupplementFormFieldState<dynamic>>? formFields,
    bool? resetForm,
  }) {
    return SupplementFormStateData(
      position: position ?? this.position,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formFields:
          (resetForm ?? false)
              ? _generateFormFields()
              : formFields ?? this.formFields,
    );
  }
}

class SupplementFormFieldState<T> {
  final T? value;
  final String? error;

  SupplementFormFieldState({this.value, this.error});

  SupplementFormFieldState<T> copyWith({T? value, String? error}) {
    return SupplementFormFieldState<T>(
      value: value ?? this.value,
      error: error,
    );
  }

  SupplementFormFieldState<T> clearError() => copyWith(error: null);
}
