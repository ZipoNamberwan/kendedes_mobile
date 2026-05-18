import 'package:equatable/equatable.dart';
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

class PhotoUtilStateData {
  final List<Photo> photos;
  final List<Photo> filteredPhotos;
  final String? searchQuery;

  PhotoUtilStateData({
    required this.photos,
    required this.filteredPhotos,
    this.searchQuery,
  });

  PhotoUtilStateData copyWith({
    List<Photo>? photos,
    List<Photo>? filteredPhotos,
    String? searchQuery,
  }) {
    return PhotoUtilStateData(
      photos: photos ?? this.photos,
      filteredPhotos: filteredPhotos ?? this.filteredPhotos,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
