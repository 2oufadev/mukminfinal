part of 'userstate_cubit.dart';

@immutable
abstract class UserState {}

class UserStateInitial extends UserState {}

class LoginState extends UserState {
  final Map<String, dynamic>? userStateMap;

  LoginState(this.userStateMap);
}
