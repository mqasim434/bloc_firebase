import 'package:bloc/bloc.dart';
import 'package:bloc_firebase/blocs/signup_bloc/signup_event.dart';
import 'package:bloc_firebase/blocs/signup_bloc/signup_state.dart';
import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/repository/signup_repository.dart';
import 'package:bloc_firebase/utils/enums.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupState(user: UserModel())) {
    on<SignupButtonPressedEvent>(_signup);
  }

  void _signup(SignupButtonPressedEvent event, Emitter<SignupState> emit) {
    SignupRepository.signupUser(event.user);
    emit(SignupState(
        signupStatus: SignupStatus.success,
        user: event.user,
        message: "Successful"));
  }
}
