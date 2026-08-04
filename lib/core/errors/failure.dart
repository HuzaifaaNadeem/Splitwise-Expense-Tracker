import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => <Object?>[message, cause];
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.cause});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.cause});
}

final class ExportFailure extends Failure {
  const ExportFailure({required super.message, super.cause});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.cause});
}
