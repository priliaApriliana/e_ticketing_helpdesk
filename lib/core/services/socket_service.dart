import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:e_ticketing_helpdesk/core/constants/api_constants.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;

  bool get isConnected => _socket != null && _socket!.connected;

  void connect() {
    try {
      String baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
      
      print('>>> Menghubungkan ke Socket Server: $baseUrl');
      
      _socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionDelay': 2000,
        'reconnectionAttempts': 10,
      });

      _socket!.onConnect((_) => print('>>> Socket Terhubung Berhasil'));
      _socket!.onDisconnect((_) => print('>>> Socket Terputus'));
      _socket!.onConnectError((err) => print('>>> Socket Connect Error: $err'));
      _socket!.onError((err) => print('>>> Socket Error: $err'));
    } catch (e) {
      print('>>> Socket Exception: $e');
    }
  }

  void on(String event, Function(dynamic) handler) {
    if (_socket != null) {
      _socket!.on(event, (data) {
        print('>>> Event Socket Diterima: $event');
        handler(data);
      });
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
