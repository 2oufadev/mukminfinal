import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mukim_app/data/repository/mukmin_repository.dart';

part 'userstate_state.dart';

class UserStateCubit extends Cubit<UserState> {
  final MukminRepository mukminRepository;
  UserStateCubit(this.mukminRepository) : super(UserStateInitial());

  Map<String, dynamic>? map;

  Map<String, dynamic> checkUserState() {
    mukminRepository.checkUserState().then((value) {
      map = value;
      emit(LoginState(map));
      print(value);
    });

    return map ?? {};
  }

  Map<String, dynamic>? checkUserFirstState() {
    mukminRepository.checkUserFirstState().then((value) {
      map = value;
      emit(LoginState(map));
      print(value);
    });

    return map;
  }
}
