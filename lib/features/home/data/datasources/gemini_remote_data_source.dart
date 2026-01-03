// Gọi API AI để lấy gợi ý, tóm tắt thời tiết, chat và OOTD.

import '../../../../../core/services/ai_service.dart';

abstract class GeminiRemoteDataSource {
  Future<String?> getRecommendations(String weatherData);
  Future<String?> getWeatherSummary(String weatherData);
  Future<String?> chatWithWeatherContext(String message, String weatherContext);
  Future<String?> getOOTDAdvice(String weatherData); // New method
}

class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final GeminiService _geminiService;

  GeminiRemoteDataSourceImpl(this._geminiService);

  @override
  Future<String?> getRecommendations(String weatherData) async {
    final prompt =
        '''
Dựa trên dữ liệu thời tiết sau đây: $weatherData
Hãy đóng vai một trợ lý thời tiết thân thiện và đưa ra danh sách các khuyến nghị hữu ích cho người dùng.
Trả lời CHỈ bằng một mảng JSON thuần túy (không có markdown block, không có lời dẫn), tuân thủ schema sau:
[
  {
    "category": "Trang phục" | "Hoạt động" | "Cảnh báo",
    "title": "Tiêu đề ngắn gọn",
    "icon": "Emoji tương ứng",
    "description": "Mô tả chi tiết hơn",
    "isAlert": true/false
  }
]
Cực kỳ quan trọng: KHÔNG bao bọc kết quả trong ```json hoặc ```, chỉ trả về chuỗi JSON thô.
Đảm bảo JSON hợp lệ.
''';
    return await _geminiService.generateContent(prompt);
  }

  @override
  Future<String?> getWeatherSummary(String weatherData) async {
    final prompt =
        '''
Đóng vai biên tập viên thời tiết vui tính. Dựa vào dữ liệu: $weatherData. 
Hãy viết đoạn tóm tắt ngắn (dưới 70 từ) cho ngày hôm nay bằng tiếng Việt, giọng điệu thân thiện, cảnh báo nếu có mưa/nắng gắt.
''';
    return await _geminiService.generateContent(prompt);
  }

  @override
  Future<String?> chatWithWeatherContext(
    String message,
    String weatherContext,
  ) async {
    final prompt =
        '''
System: Dữ liệu thời tiết hiện tại: $weatherContext
User: $message
Hãy trả lời câu hỏi của người dùng dựa trên dữ liệu thời tiết được cung cấp. 
Nếu câu hỏi không liên quan đến thời tiết, hãy trả lời một cách lịch sự và cố gắng lái về chủ đề thời tiết nếu có thể.
Giữ giọng điệu hữu ích và ngắn gọn.
''';
    return await _geminiService.generateContent(prompt);
  }

  @override
  Future<String?> getOOTDAdvice(String weatherData) async {
    final prompt =
        '''
Dựa vào dữ liệu thời tiết: $weatherData.
Hãy gợi ý 1 set đồ cụ thể (OOTD - Outfit of the Day) phù hợp cho cả nam và nữ (hoặc trung tính).
Format trả về:
**Trang phục:** [Mô tả set đồ]
**Phụ kiện:** [Kính, ô, mũ, khăn...]
**Lưu ý:** [Lời khuyên ngắn gọn về UV/Mưa/Gió]
Giữ câu trả lời ngắn gọn, súc tích, dưới 100 từ.
''';
    return await _geminiService.generateContent(prompt);
  }
}
