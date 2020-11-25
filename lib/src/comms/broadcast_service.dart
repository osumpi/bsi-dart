import '../../bsi_dart.dart';

/// The Broadcast [Service] for every BSI applications.
///
/// This class presents functionalities
class BroadcastService extends Service {
  /// Private generative constructor for singleton implementation.
  BroadcastService._();

  /// The singleton instance of BroadcastService.
  static final instance = BroadcastService._();

  /// Factory constructor that redirects to the [instance].
  factory BroadcastService() => instance;

  /// The [ServiceReference] of the Broadcast service.
  ///
  /// Broadcast service reference always points to: `bakecode/broadcast`.
  @override
  ServiceReference get reference =>
      ServiceReference.fromString('bakecode/broadcast');

  /// The broadcast stream which can be listened to, to get all public service
  /// announcements.
  Stream<ServiceMessage> get publicServiceAnnouncement =>
      onReceive.asBroadcastStream();
}
