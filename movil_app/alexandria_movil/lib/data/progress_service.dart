import 'package:alexandria_movil/data/api_client.dart';

class ProgressPayload {
  ProgressPayload({
    required this.userId,
    required this.courseId,
    required this.currentUnit,
    required this.currentConcept,
    required this.currentQuestion,
    required this.completionPercentage,
  });

  final int userId;
  final int courseId;
  final int currentUnit;
  final int currentConcept;
  final int currentQuestion;
  final double completionPercentage;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'course_id': courseId,
        'current_unit': currentUnit,
        'current_concept': currentConcept,
        'current_question': currentQuestion,
        'completion_percentage': completionPercentage,
      };

  factory ProgressPayload.fromJson(Map<String, dynamic> json) {
    return ProgressPayload(
      userId: json['user_id'] as int,
      courseId: json['course_id'] as int,
      currentUnit: int.tryParse(json['current_unit'].toString()) ?? 0,
      currentConcept: int.tryParse(json['current_concept'].toString()) ?? 0,
      currentQuestion: int.tryParse(json['current_question'].toString()) ?? 0,
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Cliente para /progress (store y fetch de progreso).
class ProgressService {
  ProgressService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<ProgressPayload> saveProgress(ProgressPayload payload) async {
    final json = await _client.post('/progress/', body: payload.toJson());
    return ProgressPayload.fromJson(json);
  }

  Future<ProgressPayload> fetchProgress({
    required int userId,
    required int courseId,
  }) async {
    final json = await _client.get('/progress/?user_id=$userId&course_id=$courseId');
    return ProgressPayload.fromJson(json);
  }
}
