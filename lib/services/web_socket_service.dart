import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Logger logger = Logger();

  /// Initialize the WebSocket connection
  void connect(String url) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      logger.e('Error connecting to WebSocket: $e');
    }
  }

  /// Expose the stream to listen for incoming data
  Stream? get stream {
    if (_channel != null) {
      return _channel?.stream;
    } else {
      logger.w('WebSocket is not initialized yet.');
      return null;
    }
  }

  /// Send data to the server (optional, if needed)
  void send(dynamic data) {
    if (_channel != null) {
      _channel?.sink.add(data);
    } else {
      logger.w('WebSocket is not connected.');
    }
  }

  /// Close the WebSocket connection
  void disconnect() {
    if (_channel != null) {
      _channel?.sink.close();
      logger.i('WebSocket disconnected.');
    } else {
      logger.w('WebSocket is not initialized.');
    }
  }
}
