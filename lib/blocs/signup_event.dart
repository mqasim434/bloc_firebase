import 'package:equatable/equatable.dart';
import 'package:bloc_firebase/models/user_model.dart';

class SignupEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SignupButtonPressedEvent extends SignupEvent {
  UserModel user;

  SignupButtonPressedEvent({
    required this.user
  });

  @override
  List<Object> get props => [user];
}
