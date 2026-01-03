// Mô tả: BLoC quản lý state màn hình chat với AI.
// Xử lý gửi tin nhắn, hiển thị typing indicator và cập nhật danh sách tin nhắn.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/resources/data_state.dart';
import '../../../home/presentation/bloc/weather_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_chat.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendChatUseCase _sendChatUseCase;
  final WeatherBloc _weatherBloc;

  ChatBloc(this._sendChatUseCase, {required WeatherBloc weatherBloc})
    : _weatherBloc = weatherBloc,
      super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final currentMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage);

    emit(ChatUpdated(messages: currentMessages, isTyping: true));

    // Lấy ngữ cảnh thời tiết hiện tại
    final weatherState = _weatherBloc.state;
    final weather = weatherState.weather;

    // Gọi AI
    final result = await _sendChatUseCase(event.message, weather);

    String aiResponseText = "Xin lỗi, tôi không thể trả lời ngay lúc này.";
    if (result is DataSuccess && result.data != null) {
      aiResponseText = result.data!;
    } else if (result is DataFailed) {
      aiResponseText =
          "Đã xảy ra lỗi khi kết nối với AI. Vui lòng thử lại sau.";
    }

    final aiMessage = ChatMessage(
      id: const Uuid().v4(),
      text: aiResponseText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(currentMessages)
      ..add(aiMessage);

    emit(ChatUpdated(messages: updatedMessages, isTyping: false));
  }
}
