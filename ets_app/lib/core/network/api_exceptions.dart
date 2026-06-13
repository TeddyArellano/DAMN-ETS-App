import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final Object? details;

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }

    return '$message (Código: $statusCode)';
  }

  static ApiException fromDio(DioException exception) {
    return fromDioException(exception);
  }

  static ApiException fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'La conexión tardó demasiado. Verifica tu conexión e intenta nuevamente.',
          statusCode: exception.response?.statusCode,
          details: exception,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          'No se pudo conectar con el servidor. Verifica que el backend esté encendido o que tengas conexión.',
          statusCode: exception.response?.statusCode,
          details: exception,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          'El certificado de seguridad del servidor no es válido.',
          statusCode: exception.response?.statusCode,
          details: exception,
        );

      case DioExceptionType.cancel:
        return ApiException(
          'La solicitud fue cancelada.',
          statusCode: exception.response?.statusCode,
          details: exception,
        );

      case DioExceptionType.badResponse:
        return _fromResponse(exception.response, exception);

      case DioExceptionType.unknown:
        return ApiException(
          'Ocurrió un error inesperado. Intenta nuevamente.',
          statusCode: exception.response?.statusCode,
          details: exception,
        );
    }
  }

  static ApiException _fromResponse(
    Response<dynamic>? response,
    DioException exception,
  ) {
    final statusCode = response?.statusCode;
    final backendMessage = _extractBackendMessage(response?.data);

    switch (statusCode) {
      case 400:
        return ApiException(
          backendMessage ?? 'La solicitud contiene datos inválidos.',
          statusCode: statusCode,
          details: exception,
        );

      case 401:
        return ApiException(
          backendMessage ?? 'Tu sesión expiró. Inicia sesión nuevamente.',
          statusCode: statusCode,
          details: exception,
        );

      case 403:
        return ApiException(
          backendMessage ?? 'No tienes permisos para realizar esta acción.',
          statusCode: statusCode,
          details: exception,
        );

      case 404:
        return ApiException(
          backendMessage ?? 'El recurso solicitado no existe.',
          statusCode: statusCode,
          details: exception,
        );

      case 409:
        return ApiException(
          backendMessage ?? 'El registro ya existe o entra en conflicto.',
          statusCode: statusCode,
          details: exception,
        );

      case 422:
        return ApiException(
          backendMessage ?? 'Los datos enviados no son válidos.',
          statusCode: statusCode,
          details: exception,
        );

      case 500:
        return ApiException(
          backendMessage ?? 'Error interno del servidor. Intenta más tarde.',
          statusCode: statusCode,
          details: exception,
        );

      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiException(
            backendMessage ?? 'El servidor presentó un error. Intenta más tarde.',
            statusCode: statusCode,
            details: exception,
          );
        }

        return ApiException(
          backendMessage ?? 'No fue posible completar la solicitud.',
          statusCode: statusCode,
          details: exception,
        );
    }
  }

  static String? _extractBackendMessage(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      if (message is List) {
        final joinedMessage = message
            .whereType<String>()
            .where((item) => item.trim().isNotEmpty)
            .join('\n');

        if (joinedMessage.isNotEmpty) {
          return joinedMessage;
        }
      }

      final error = data['error'];

      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }
    }

    return null;
  }
}

String getReadableErrorMessage(Object error) {
  if (error is ApiException) {
    return error.message;
  }

  if (error is DioException) {
    final dioError = error.error;

    if (dioError is ApiException) {
      return dioError.message;
    }

    return ApiException.fromDioException(error).message;
  }

  return 'Ocurrió un error inesperado. Intenta nuevamente.';
}