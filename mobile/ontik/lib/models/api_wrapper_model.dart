class ApiWrapper {
  final bool success;
  final int status;
  final String message;
  final dynamic data;
  final String? error;
  final DateTime? timestamp;

  ApiWrapper({
    required this.success,
    required this.status,
    required this.message,
    this.data,
    this.error,
    this.timestamp,
  });

  factory ApiWrapper.fromJson(Map<String, dynamic> json) {
    return ApiWrapper(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
      error: json['error'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
    );
  }

  T getData<T>(T Function(dynamic) fromJson) {
    if (data == null) throw Exception('No data in response');
    return fromJson(data);
  }

  List<T> getDataList<T>(T Function(Map<String, dynamic>) fromJson) {
    if (data == null || data is! List) return [];
    return (data as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
