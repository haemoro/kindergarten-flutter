class ApiException implements Exception {
  final int status;
  final String code;
  final String message;
  final DateTime timestamp;

  ApiException({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
  });

  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(
      status: json['status'] ?? 0,
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'Unknown error occurred',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ApiException(status: $status, code: $code, message: $message)';
  }
}