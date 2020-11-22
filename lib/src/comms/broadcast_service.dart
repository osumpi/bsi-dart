import '../../bsi_dart.dart';

class BroadcastService extends Service {
  BroadcastService._();

  static final instance = BroadcastService._();

  factory BroadcastService() => instance;

  @override
  ServiceReference get reference =>
      ServiceReference.fromString('bakecode/broadcast');

  Stream<ServiceMessage> get publicServiceAnnouncement =>
      onReceive.asBroadcastStream();
}
