part of bsi;

// TODO: handle reply...

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

    var destinations = (packet['destinations'] as Iterable<String>)
        .map(ServiceReference._fromString)
        .toList();

    var type = packet['type'] as String;

    var message = packet['message'] as String;

    switch (type) {
      case '_BSIWillMessage':
        return _BSIWillMessage(source: source, destinations: destinations);

      default:
        return null;
    }
  }
}

class _BSIWillMessage extends ServiceMessage {
  final source;

  final destinations;

  @override
  String get message => 'offline';

  _BSIWillMessage({@required this.source, @required this.destinations});
}

class CustomMessage extends ServiceMessage {
  final source;
  final destinations;

  final message;

  CustomMessage({
    @required this.source,
    @required this.destinations,
    @required this.message,
  });
}

class Ping extends ServiceMessage {
  final source, destinations;

  @override
  String get message => "ping from $source";

  Ping({
    @required this.source,
    @required this.destinations,
  });
}

class Pong extends ServiceMessage {
  final source, destinations;

  @override
  String get message => "ping reply from $source";

  Pong({
    @required this.source,
    @required this.destinations,
  });
}
