sealed class AppException implements Exception {
  final String message; final int? statusCode;
  const AppException(this.message, {this.statusCode});
}
class NetworkException extends AppException { const NetworkException(super.message, {super.statusCode}); }
class TimeoutExceptionEx extends AppException { const TimeoutExceptionEx(super.message); }
class ParsingException extends AppException { const ParsingException(super.message); }
class NotFoundException extends AppException { const NotFoundException(super.message, {super.statusCode}); }
class ServerException extends AppException { const ServerException(super.message, {super.statusCode}); }