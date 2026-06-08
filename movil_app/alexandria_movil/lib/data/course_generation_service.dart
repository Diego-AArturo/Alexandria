import 'package:alexandria_movil/data/api_client.dart';


/// Modela la solicitud de generacion de curso.
class CourseGenerationRequest {
  CourseGenerationRequest({required this.prompt, this.userId});

  final String prompt;
  final int? userId;

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        if (userId != null) 'user_id': userId,
      };
}

/// Respuesta cuando se encola/genera un curso y se persiste.
class CourseGenerationJobResponse {
  CourseGenerationJobResponse({
    required this.status,
    required this.jobId,
    this.progress,
    this.courseId,
    this.error,
  });

  final String status;
  final int jobId;
  final double? progress;
  final int? courseId;
  final String? error;

  factory CourseGenerationJobResponse.fromJson(Map<String, dynamic> json) {
    return CourseGenerationJobResponse(
      status: json['status'] as String,
      jobId: json['job_id'] as int,
      progress: (json['progress'] as num?)?.toDouble(),
      courseId: json['course_id'] as int?,
      error: json['error'] as String?,
    );
  }
}

/// Payload completo de un curso ya almacenado.
class CourseGenerationStoredResponse {
  CourseGenerationStoredResponse({
    required this.courseId,
    required this.createdAt,
    required this.courseData,
  });

  final int courseId;
  final DateTime? createdAt;
  final CourseGenerationResponse courseData;

  factory CourseGenerationStoredResponse.fromJson(Map<String, dynamic> json) {
    return CourseGenerationStoredResponse(
      courseId: json['course_id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      courseData: CourseGenerationResponse.fromJson(
        json['course_data'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Resumen de cursos por usuario (endpoint /ai/generate-courselist/{user_id}).
class CourseListItem {
  CourseListItem({
    required this.courseId,
    required this.learningTopic,
    required this.completionPercentage,
  });

  final int courseId;
  final String learningTopic;
  final double completionPercentage;

  factory CourseListItem.fromJson(Map<String, dynamic> json) {
    return CourseListItem(
      courseId: json['course_id'] as int,
      learningTopic: json['learning_topic'] as String,
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Datos del curso devueltos por el backend.
class CourseGenerationResponse {
  CourseGenerationResponse({
    required this.topic,
    required this.units,
    required this.concepts,
    required this.questions,
  });

  final Map<String, dynamic> topic;
  final Map<String, dynamic> units;
  final List<Map<String, dynamic>> concepts;
  final List<Map<String, dynamic>> questions;

  factory CourseGenerationResponse.fromJson(Map<String, dynamic> json) {
    return CourseGenerationResponse(
      topic: Map<String, dynamic>.from(json['topic'] as Map),
      units: Map<String, dynamic>.from(json['units'] as Map),
      concepts: List<Map<String, dynamic>>.from(
        (json['concepts'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      questions: List<Map<String, dynamic>>.from(
        (json['questions'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
    );
  }
}

/// Servicio que encapsula las llamadas al router de generacion de cursos.
///
/// Endpoints (segun backend FastAPI `src/routers/ai/course_generation.py`):
/// - POST /ai/courses                  -> encola job de generacion, devuelve job_id
/// - GET  /ai/courses/status/{job_id}  -> estado del job y course_id cuando finaliza
/// - GET  /ai/courses/{course_id}      -> recupera el curso almacenado
/// - GET  /ai/generate-courselist/{user_id} -> lista cursos de un usuario y su progreso
class CourseGenerationService {
  CourseGenerationService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<CourseGenerationJobResponse> generateCourse(String prompt, {int? userId}) async {
    final payload = CourseGenerationRequest(prompt: prompt, userId: userId);
    final json = await _client.post('/ai/courses', body: payload.toJson());
    return CourseGenerationJobResponse.fromJson(json);
  }

  Future<CourseGenerationJobResponse> getJobStatus(int jobId) async {
    final json = await _client.get('/ai/courses/status/$jobId');
    return CourseGenerationJobResponse.fromJson(json);
  }

  /// Espera hasta que el job termine o falle. Lanza excepcion si expira o falla.
  Future<int> waitForCourseReady(
    int jobId, {
    Duration pollInterval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 10),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = await getJobStatus(jobId);
      if (status.status == 'completed' && status.courseId != null) {
        return status.courseId!;
      }
      if (status.status == 'failed') {
        throw Exception(status.error ?? 'Course generation failed');
      }
      await Future.delayed(pollInterval);
    }
    throw Exception('Timed out waiting for course generation');
  }

  Future<CourseGenerationStoredResponse> fetchCourse(int courseId) async {
    final json = await _client.get('/ai/courses/$courseId');
    return CourseGenerationStoredResponse.fromJson(json);
  }

  Future<List<CourseListItem>> fetchUserCourses(int userId) async {
    final json = await _client.get('/ai/generate-courselist/$userId');
    final courses = json['courses'] as List<dynamic>? ?? <dynamic>[];
    return courses
        .map((e) => CourseListItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
