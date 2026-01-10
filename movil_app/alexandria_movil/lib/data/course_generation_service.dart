import 'package:alexandria_movil/data/api_client.dart';

/// Modela la solicitud de generacion de curso.
class CourseGenerationRequest {
  CourseGenerationRequest({required this.prompt});

  final String prompt;

  Map<String, dynamic> toJson() => {'prompt': prompt};
}

/// Respuesta cuando se encola/genera un curso y se persiste.
class CourseGenerationJobResponse {
  CourseGenerationJobResponse({
    required this.courseId,
    required this.status,
  });

  final int courseId;
  final String status;

  factory CourseGenerationJobResponse.fromJson(Map<String, dynamic> json) {
    return CourseGenerationJobResponse(
      courseId: json['course_id'] as int,
      status: json['status'] as String,
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
/// - POST /ai/generate-course          -> genera y persiste curso, devuelve course_id
/// - GET  /ai/generate-course/{id}     -> recupera el curso almacenado
class CourseGenerationService {
  CourseGenerationService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<CourseGenerationJobResponse> generateCourse(String prompt) async {
    final payload = CourseGenerationRequest(prompt: prompt);
    final json = await _client.post('/ai/generate-course', body: payload.toJson());
    return CourseGenerationJobResponse.fromJson(json);
  }

  Future<CourseGenerationStoredResponse> fetchCourse(int courseId) async {
    final json = await _client.get('/ai/generate-course/$courseId');
    return CourseGenerationStoredResponse.fromJson(json);
  }
}
