import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_event.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_state.dart';

class PhotoUtilBloc extends Bloc<PhotoUtilEvent, PhotoUtilState> {
  PhotoUtilBloc() : super(InitState()) {
    on<Initialize>((event, emit) async {});
  }
}

class ValidationResult {
  final Map<String, PhotoUtilFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ValidationResult(this.updatedFields, this.hasErrors);
}
