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
          photos: [],
          filteredPhotos: [],
          searchQuery: null,
        ),
      );

  @override
  List<Object> get props => [data];
}

class PhotoFileTakenSuccess extends PhotoUtilState {
  const PhotoFileTakenSuccess({required super.data});
  @override
  List<Object> get props => [data];
}

class PhotoFileTakenFailed extends PhotoUtilState {
  final String errorMessage;
  const PhotoFileTakenFailed(this.errorMessage, {required super.data});
  @override
  List<Object> get props => [data, errorMessage];
}

class PhotoUtilStateData {
  final List<Photo> photos;
  final List<Photo> filteredPhotos;
  final String? searchQuery;

  final Map<String, PhotoUtilFieldState<dynamic>> formFields;

  PhotoUtilStateData({
    required this.photos,
    required this.filteredPhotos,
    this.searchQuery,
    Map<String, PhotoUtilFieldState<dynamic>>? formFields,
  }) : formFields = formFields ?? _generateFormFields();

  static Map<String, PhotoUtilFieldState<dynamic>> _generateFormFields() {
    final formFields = <String, PhotoUtilFieldState<dynamic>>{};

    formFields['id'] = PhotoUtilFieldState<String>();
    formFields['name'] = PhotoUtilFieldState<String>();
    formFields['area'] = PhotoUtilFieldState<String?>();
    formFields['note'] = PhotoUtilFieldState<String?>();
    formFields['photoUrl'] = PhotoUtilFieldState<String>();
    formFields['photoFile'] = PhotoUtilFieldState<XFile?>();

    return formFields;
  }

  PhotoUtilStateData copyWith({
    List<Photo>? photos,
    List<Photo>? filteredPhotos,
    String? searchQuery,
    Map<String, PhotoUtilFieldState<dynamic>>? formFields,
    bool? resetForm,
  }) {
    return PhotoUtilStateData(
      photos: photos ?? this.photos,
      filteredPhotos: filteredPhotos ?? this.filteredPhotos,
      searchQuery: searchQuery ?? this.searchQuery,
      formFields:
          (resetForm ?? false)
              ? _generateFormFields()
              : formFields ?? this.formFields,
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
