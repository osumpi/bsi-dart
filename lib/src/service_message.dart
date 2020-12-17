part of bsi;

// TODO: handle reply...

/// The send options for a message to be sent.
///
/// Allows special options to be applied to a message before being sent by the
/// BSI.
///
/// *Note:* SendOptions on a receiving message does not play any role, and
/// cannot be from a message.
///
/// Options include [_retain]. See [_retain].
class SendOptions {
  /// Retains the message on the topic, so that when a new client subscribes to
  /// the topic, the message is retained. Note that previous retained message
  /// on that topic will no longer be retained if any.
  bool _retain = false;
}

/// The ServiceMessage interpretable by every BakeCode Service using BSI.
///
/// Packets are represented in Json format. This class helps to envelope a
/// message before being passed to the BSI layer.
@immutable
abstract class ServiceMessage {
  /// The source of the message as [ServiceReference].
  ServiceReference get source;

  /// The recipients of the message as an Iterable of [ServiceReference].
  Iterable<ServiceReference> get destinations;

  /// The message itself (nullable).
  String get message;

  /// The send options for a message to be sent.
  ///
  /// Allows special options to be applied to a message before being sent by the
  /// BSI.
  ///
  /// *Note:* SendOptions on a receiving message does not play any role, and
  /// cannot be from a message.
  ///
  /// See [SendOptions].
  final sendOptions = SendOptions();

  @nonVirtual
  Map<String, dynamic> toJson() => {
        'source': source,
        'destinations': destinations,
        'type': '$runtimeType',
        'message': message,
      };

  @override
  @nonVirtual
  String toString() => jsonEncode(toJson());

  static ServiceMessage fromJson(String json) {
    Map<String, dynamic> packet = jsonDecode(json);

    var source = ServiceReference._fromString(packet['source'] as String);

    var destinations = (packet['destinations'] as Iterable)
        ?.cast<String>()
        ?.map(ServiceReference._fromString)
        ?.toList();

    var type = packet['type'] as String;

    var message = packet['message'] as String;

    switch (type) {
      case '_BSIWillMessage':
        return _BSIWillMessage(source, destinations);

      case 'Ping':
        return Ping(source, destinations);

      case 'Pong':
        return Pong(source, destinations);

      case 'CustomMessage':
      default:
        return CustomMessage(source, destinations, message);
    }
  }
}

class _BSIWillMessage extends ServiceMessage {
  final source;

  final destinations;

  @override
  String get message => 'offline';

  _BSIWillMessage(this.source, this.destinations);
}

class CustomMessage extends ServiceMessage {
  final source, destinations, message;

  CustomMessage(
    this.source,
    this.destinations,
    this.message,
  );
}

class Ping extends ServiceMessage {
  final source, destinations;

  @override
  String get message => "ping from $source";

  Ping(this.source, this.destinations);
}

class Pong extends ServiceMessage {
  final source, destinations;

  @override
  String get message => "ping reply from $source";

  Pong(this.source, this.destinations);
}
