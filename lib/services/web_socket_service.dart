import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  /// Initialize the WebSocket connection
  void connect(String url) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  /// Expose the stream to listen for incoming data
  Stream? get stream {
    if (_channel != null) {
      return _channel?.stream;
    } else {
      print('WebSocket is not initialized yet.');
      return null;
    }
  }

  /// Send data to the server (optional, if needed)
  void send(dynamic data) {
    if (_channel != null) {
      _channel?.sink.add(data);
    } else {
      print('WebSocket is not connected.');
    }
  }

  /// Close the WebSocket connection
  void disconnect() {
    if (_channel != null) {
      _channel?.sink.close();
      print('WebSocket disconnected.');
    } else {
      print('WebSocket is not initialized.');
    }
  }
}
