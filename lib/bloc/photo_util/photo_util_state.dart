import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';
import 'package:kendedes_mobile/models/photo_util/photo_field_form.dart';

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

class Processing extends PhotoUtilState {
  const Processing({required super.data});
  @override
  List<Object> get props => [data];
}

class PhotoUtilStateData {
  final List<Family> families;
  final List<Family> filteredFamilies;
  final String? searchQuery;
  final bool isLoading;

  final Map<String, PhotoUtilFieldState<dynamic>> formFields;
  final String? processingMessage;

  PhotoUtilStateData({
    required this.families,
    required this.filteredFamilies,
    this.searchQuery,
    Map<String, PhotoUtilFieldState<dynamic>>? formFields,
    required this.isLoading,
    this.processingMessage,
  }) : formFields = formFields ?? _generateFormFields();

  static Map<String, PhotoUtilFieldState<dynamic>> _generateFormFields() {
    final formFields = <String, PhotoUtilFieldState<dynamic>>{};

    formFields['id'] = PhotoUtilFieldState<String>();
    formFields['name'] = PhotoUtilFieldState<String>();
    formFields['address'] = PhotoUtilFieldState<String?>();
    // formFields['note'] = PhotoUtilFieldState<String?>();

    for (final type in PhotoType.values) {
      formFields[type.key] = PhotoUtilFieldState<PhotoFieldForm?>();
    }

    return formFields;
  }

  PhotoUtilStateData copyWith({
    List<Family>? families,
    List<Family>? filteredFamilies,
    String? searchQuery,
    bool? resetSearchQuery,
    Map<String, PhotoUtilFieldState<dynamic>>? formFields,
    bool? isLoading,
    bool? resetForm,
    String? processingMessage,
    bool? resetProcessingMessage,
  }) {
    return PhotoUtilStateData(
      families: families ?? this.families,
      filteredFamilies: filteredFamilies ?? this.filteredFamilies,
      searchQuery:
          (resetSearchQuery ?? false) ? null : searchQuery ?? this.searchQuery,
      formFields:
          (resetForm ?? false)
              ? _generateFormFields()
              : formFields ?? this.formFields,
      isLoading: isLoading ?? this.isLoading,
      processingMessage:
          (resetProcessingMessage ?? false)
              ? null
              : processingMessage ?? this.processingMessage,
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
