import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/utils/enums.dart';
import 'package:equatable/equatable.dart';

class SignupState extends Equatable {
  final SignupStatus signupStatus;
  UserModel user = UserModel();
  final String message;

  SignupState({
    this.signupStatus = SignupStatus.loading,
    required this.user,
    this.message = '',
  });

  SignupState copyWith({SignupStatus? signupStatus, UserModel? user, String? message}){
    return SignupState(
      signupStatus: signupStatus ?? this.signupStatus,
      user: user ?? this.user,
      message: message ?? this.message,
    );
}

  @override
  // TODO: implement props
  List<Object?> get props => [signupStatus,user,message];
}
