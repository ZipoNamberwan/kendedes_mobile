import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';

class PhotoUtilState extends Equatable {
  final PhotoUtilStateData data;

  const PhotoUtilState({required this.data});

  @override
  List<Object> get props => [data];
}

class InitState extends PhotoUtilState {
  InitState()
    : super(
        data: PhotoUtilStateData(
          families: [],
          filteredFamilies: [],
          searchQuery: null,
          isLoading: false,
        ),
      );

  @override
  List<Object> get props => [data];
}

class SaveSuccess extends PhotoUtilState {
  const SaveSuccess({required super.data});
  @override
  List<Object> get props => [data];
}

class SaveFailed extends PhotoUtilState {
  final String errorMessage;

  const SaveFailed(this.errorMessage, {required super.data});
  @override
  List<Object> get props => [data, errorMessage];
}

class FormValidationFailed extends PhotoUtilState {
  final String errorMessage;
  const FormValidationFailed(this.errorMessage, {required super.data});
  @override
  List<Object> get props => [data, errorMessage];
}

class PhotoUtilStateData {
  final List<Family> families;
  final List<Family> filteredFamilies;
  final String? searchQuery;
  final bool isLoading;

  final Map<String, PhotoUtilFieldState<dynamic>> formFields;

  PhotoUtilStateData({
    required this.families,
    required this.filteredFamilies,
    this.searchQuery,
    Map<String, PhotoUtilFieldState<dynamic>>? formFields,
    required this.isLoading,
  }) : formFields = formFields ?? _generateFormFields();

  static Map<String, PhotoUtilFieldState<dynamic>> _generateFormFields() {
    final formFields = <String, PhotoUtilFieldState<dynamic>>{};

    formFields['id'] = PhotoUtilFieldState<String>();
    formFields['name'] = PhotoUtilFieldState<String>();
    formFields['address'] = PhotoUtilFieldState<String?>();
    // formFields['note'] = PhotoUtilFieldState<String?>();

    for (final type in PhotoType.values) {
      formFields[type.key] = PhotoUtilFieldState<XFile?>();
    }

    return formFields;
  }

  PhotoUtilStateData copyWith({
    List<Family>? families,
    List<Family>? filteredFamilies,
    String? searchQuery,
    Map<String, PhotoUtilFieldState<dynamic>>? formFields,
    bool? isLoading,
    bool? resetForm,
  }) {
    return PhotoUtilStateData(
      families: families ?? this.families,
      filteredFamilies: filteredFamilies ?? this.filteredFamilies,
      searchQuery: searchQuery ?? this.searchQuery,
      formFields:
          (resetForm ?? false)
              ? _generateFormFields()
              : formFields ?? this.formFields,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PhotoUtilFieldState<T> {
  final T? value;
  final String? error;

  PhotoUtilFieldState({this.value, this.error});

  PhotoUtilFieldState<T> copyWith({T? value, String? error}) {
    return PhotoUtilFieldState<T>(value: value ?? this.value, error: error);
  }

  PhotoUtilFieldState<T> clearError() => copyWith(error: null);
}
