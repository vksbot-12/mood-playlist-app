import 'package:dio/dio.dart';

class RecommendationRepository {
  final Dio dio;

  RecommendationRepository(this.dio);

  Future<Map<String, dynamic>> recommend(String moodText) async {
    final res = await dio.post('/api/v1/recommendations', data: {'moodText': moodText});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchCalendar(int year, int month) async {
    final res = await dio.get('/api/v1/recommendations/calendar', queryParameters: {'year': year, 'month': month});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchShareData(int moodLogId) async {
    final res = await dio.get('/api/v1/recommendations/$moodLogId/share');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchDayDetail(DateTime date) async {
    final isoDate = date.toIso8601String().split('T').first;
    final res = await dio.get('/api/v1/recommendations/calendar/day', queryParameters: {'date': isoDate});
    return res.data as Map<String, dynamic>;
  }
}
