import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_auth_state_changes.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetAuthStateChangesUseCase getAuthStateChangesUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getAuthStateChangesUseCase = getAuthStateChangesUseCase,
        super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Start listening to auth state changes
    _startAuthStateListener();
  }

  void _startAuthStateListener() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _getAuthStateChangesUseCase().listen(
      (user) {
        if (user != null) {
          add(const AuthStateChanged(isAuthenticated: true));
        } else {
          add(const AuthStateChanged(isAuthenticated: false));
        }
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final user = await _getCurrentUserUseCase();

    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final dataState = await _signInUseCase(
      params: SignInParams(
        email: event.email,
        password: event.password,
      ),
    );

    if (dataState.data != null) {
      emit(Authenticated(dataState.data!));
    } else {
      final errorString =
          dataState.exception?.toString() ?? dataState.error?.toString();
      final failure = _mapErrorToFailure(errorString);
      emit(AuthError(
        message: errorString ?? 'Sign in failed',
        failure: failure,
      ));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final dataState = await _signUpUseCase(
      params: SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName ?? '',
      ),
    );

    if (dataState.data != null) {
      emit(Authenticated(dataState.data!));
    } else {
      final errorString =
          dataState.exception?.toString() ?? dataState.error?.toString();
      final failure = _mapErrorToFailure(errorString);
      emit(AuthError(
        message: errorString ?? 'Sign up failed',
        failure: failure,
      ));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _signOutUseCase();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(
        message: e.toString(),
      ));
    }
  }

  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated) {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(Authenticated(user));
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  AuthFailure _mapErrorToFailure(String? error) {
    if (error == null) return AuthFailure.unknown;

    final lowerError = error.toLowerCase();

    if (lowerError.contains('invalid-email') ||
        lowerError.contains('invalid email')) {
      return AuthFailure.invalidEmail;
    }
    if (lowerError.contains('wrong-password') ||
        lowerError.contains('wrong password')) {
      return AuthFailure.wrongPassword;
    }
    if (lowerError.contains('user-not-found') ||
        lowerError.contains('user not found')) {
      return AuthFailure.userNotFound;
    }
    if (lowerError.contains('email-already-in-use') ||
        lowerError.contains('email already')) {
      return AuthFailure.emailAlreadyInUse;
    }
    if (lowerError.contains('weak-password') ||
        lowerError.contains('weak password')) {
      return AuthFailure.weakPassword;
    }
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return AuthFailure.networkError;
    }

    return AuthFailure.unknown;
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
