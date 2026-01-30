import 'package:equatable/equatable.dart';

/// Generic state class to handle loading, success, and error states
sealed class AsyncState<T> extends Equatable {
  const AsyncState();

  bool get isLoading => this is AsyncLoading<T>;
  bool get isSuccess => this is AsyncSuccess<T>;
  bool get isError => this is AsyncError<T>;

  T? get data =>
      this is AsyncSuccess<T> ? (this as AsyncSuccess<T>).data : null;
  String? get errorMessage =>
      this is AsyncError<T> ? (this as AsyncError<T>).message : null;

  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message) error,
  }) {
    return switch (this) {
      AsyncLoading() => loading(),
      AsyncSuccess(:final data) => success(data),
      AsyncError(:final message) => error(message),
    };
  }

  R maybeWhen<R>({
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      AsyncLoading() => loading?.call() ?? orElse(),
      AsyncSuccess(:final data) => success?.call(data) ?? orElse(),
      AsyncError(:final message) => error?.call(message) ?? orElse(),
    };
  }

  @override
  List<Object?> get props => [];
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncSuccess<T> extends AsyncState<T> {
  @override
  final T data;

  const AsyncSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class AsyncError<T> extends AsyncState<T> {
  final String message;

  const AsyncError(this.message);

  @override
  List<Object?> get props => [message];
}
