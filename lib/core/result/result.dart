import '../errors/app_exception.dart';
sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(AppException) err});
}
final class Ok<T> extends Result<T> { final T value; const Ok(this.value);
@override R when<R>({required R Function(T) ok, required R Function(AppException) err}) => ok(value);
}
final class Err<T> extends Result<T> { final AppException error; const Err(this.error);
@override R when<R>({required R Function(T) ok, required R Function(AppException) err}) => err(error);
}