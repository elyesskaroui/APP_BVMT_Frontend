import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userName;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userName,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userName,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, userName, errorMessage];
}
