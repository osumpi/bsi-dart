part of bsi_dart;

/// This class represents a ServiceMessage packet interpretable by BakeCode
/// Services by the BakeCode Services Interconnect Layer.
///
/// Packets are represented in Json format. This class helps to envelope a
/// message before being passed to the BSI layer, and also helps to decode
/// messages from a ServiceMessage packet.
@immutable
class ServiceMessage {
  /// The reference of the source service of the message.
  final ServiceReference source;

  /// Recipient service references of the message.
  final Iterable<ServiceReference> destinations;

  /// The type of [ServiceMessage].
  ///
  /// TODO: add references to this doc.
  final type = 'serviceMessage';

  /// The message as string.
  final String message;

  /// Creates a new ServiceMessage packet.
  ///
  /// Note that this does not send the message. [ServiceMessage] is only
  /// intended to represent a BSI packet.
  ///
  /// Destination is multi-cast by default. However for uni-cast specify the
  /// target destination as a single element in the destinations list.
  ///
  /// *Example:*
  /// ```dart
  /// var src = this.reference;
  /// var dest = getDestination();
  /// var msg = getMessage();
  ///
  /// ServiceMessage(source: src, destinations: [dest], message: msg);
  /// ```
  ///
  /// For broadcast messages, use [ServiceMessage.broadcast].
  ///
  /// *Example:*
  /// ```dart
  /// var src = this.reference;
  /// var msg = getMessage();
  ///
  /// ServiceMessage.asBroadcast(source: this, message: msg);
  /// ```
  const ServiceMessage({
    @required this.source,
    @required this.destinations,
    @required this.message,
  })  : assert(source != null),
        assert(destinations != null),
        assert(message != null);

  /// Creates a new ServiceMessage packet with destination as `broadcast`.
  ///
  /// Note that this does not send the message. [ServiceMessage] is only
  /// intended to represent a BSI packet.
  ///
  /// Every bakecode node is capable of receiving broadcast messages.
  /// Avoid manually specifying destination using ServiceMessage constructor
  /// for broadcast purposes, as using ServiceMessage.broadcast uses broadcast
  /// functionality implemented in the BSI layer.
  ///
  /// *Example:*
  /// ```dart
  /// var src = this.reference;
  /// var msg = getMessage();
  ///
  /// ServiceMessage.asBroadcast(source: this, message: msg);
  /// ```
  factory ServiceMessage.asBroadcast({
    @required ServiceReference source,
    @required String message,
  }) =>
      ServiceMessage(
        source: source,
        destinations: [Services.Broadcast],
        message: message,
      );

  /// Creates a ServiceMessage packet from the string representation of
  /// the [packet] ServiceMessage.
  ///
  /// Note that this does not send the message. [ServiceMessage] is only
  /// intended to represent a BSI packet.
  ///
  /// Shall be used by BSI layer to decode packets.
  /// Packet follows json format:
  /// ```json
  /// {
  ///   "source": "$source",
  ///   "destinations": $destinations,
  ///   "message": "$message",
  /// }
  /// ```
  /// `message` may or may not be a JSON object, however from the view of
  /// [ServiceMessage] it is represented as String.
  factory ServiceMessage.fromJson(String packet) {
    try {
      var p = jsonDecode(packet);
      return ServiceMessage(
        source: ServiceReference.fromString(p['source']),
        destinations: (p['destinations'] as Iterable)
            .map((d) => ServiceReference.fromString('$d')),
        message: p['message'].toString(),
      );
    } catch (e) {
      log.e("""
        unable to jsonDecode received packet:
        $packet

        Reason:
        $e

        Action:
        Ignored the packet.""");
      return null;
    }
  }

  /// JSON representation of the ServiceMessage packet.
  ///
  /// *Example:*
  /// ```json
  /// {
  ///   "source": "<source>",
  ///   "destinations": ["<dest0>", "<dest1>", ...],
  ///   "message": "<message>",
  /// }
  /// ```
  String toJson() => JsonEncoder.withIndent('  ').convert({
        "source": '$source',
        "destinations": destinations.map<String>((d) => '$d').toList(),
        "message": message,
      });

  /// The string representation of [ServiceMessage] is the Json representation.
  /// Equivalent to [toJson].
  ///
  /// *Example:*
  /// ```json
  /// {
  ///   "source": "<source>",
  ///   "destinations": ["<dest0>", "<dest1>", ...],
  ///   "message": "<message>",
  /// }
  /// ```
  @override
  String toString() => toJson();

  ServiceMessage constructReplyMessage({
    @required ServiceReference as,
    @required String message,
  }) =>
      ServiceMessage(source: as, destinations: [source], message: message);
}
