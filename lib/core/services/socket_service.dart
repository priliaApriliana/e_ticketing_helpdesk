import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:e_ticketing_helpdesk/core/constants/api_constants.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;

  // Getter untuk mengecek apakah socket sudah siap
  bool get isInitialized => _socket != null;

  void connect() {
    try {
      // Get the base URL from ApiConstants, removing /api if necessary
      String baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
      
      _socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket!.onConnect((_) {
        print('Connected to socket server');
      });

      _socket!.onDisconnect((_) {
        print('Disconnected from socket server');
      });

      _socket!.onConnectError((err) => print('Connect Error: $err'));
      _socket!.onError((err) => print('Error: $err'));
    } catch (e) {
      print('Socket connection error: $e');
    }
  }

  void on(String event, Function(dynamic) handler) {
    if (_socket != null) {
      _socket!.on(event, handler);
    } else {
      print('Warning: Attempted to listen to event "$event" before socket was initialized.');
    }
  }

  void emit(String event, dynamic data) {
    if (_socket != null) {
      _socket!.emit(event, data);
    }
  }

  @override
  void onClose() {
    _socket?.dispose();
    super.onClose();
  }
}
