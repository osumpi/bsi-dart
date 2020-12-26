part of bsi;

/// **BakeCode Services Interconnect Layer**
///
/// This singleton presents a set of methods to interact with the *BakeCode
/// Ecosystem* using MQTT as the L7 Application Layer Protocol.
@sealed
class BSI {
  /// Private generative constructor for singleton implementation.
  ///
  /// Sets up the [outbox]'s [StreamController] and hook's listener to Mqtt's
  /// connection state.
  BSI._() {
    var subscription = _outgoingMessageController.stream.listen(_send)..pause();

    Mqtt().connectionState.listen((connectionState) {
      if (connectionState == MqttConnectionState.connected) {
        subscription.resume();
        log("Outbox resumed as connection state changed to $connectionState");
      } else {
        subscription.pause();
        log("Outbox paused as connection state changed to: $connectionState");
      }
    });
  }

  /// Initialize the BSI instance with the provided [config].
  ///
  /// Future completes after initializing and returns the current
  /// [MqttClientConnectionStatus].
  Future<MqttClientConnectionStatus> initialize(
    BSIConfiguration config,
  ) async =>
      await Mqtt.instance.initialize(using: config);

  /// The singleton instance of BakeCode Services Interconnect Layer.
  static final instance = BSI._();

  /// Redirecting factory constructor to the singleton instance.
  factory BSI() => instance;

  /// StreamController for outgoing messages.
  ///
  /// Services can add [ServiceMessages] to the [outbox] and the listener of
  /// this stream shall send the messages when connection is available.
  final _outgoingMessageController = StreamController<_OutgoingMessage>();

  /// The outbox for messages to be sent.
  ///
  /// Messages will be sent immediatley if connection to broker is available,
  /// else will be haulted.
  ///
  /// On reconnect, previous messages may be discarded depending on the setting
  /// specified in the configuration file.
  /// Configuration: `BSI::drain outbox on reconnect`.
  Sink<_OutgoingMessage> get outbox => _outgoingMessageController.sink;

  /// Sends [message] to the corresponding destinations specified in packet.
  void _send(_OutgoingMessage message) =>
      message.destinations.forEach((destination) => Mqtt.instance.publish(
            '$message',
            topic: '$destination',
            shouldRetain: message.options.retain,
          ));

  final hookedServices = <String, StreamSink<String>>{};

  void hook(ServiceReference reference, {@required StreamSink<String> sink}) =>
      hookedServices.putIfAbsent('$reference', () {
        Mqtt.instance.subscribe('$reference');
        return sink;
      });

  void unhook(Service service) =>
      hookedServices.remove(service.reference)?.close();

  void onReceiveCallback(String topic, String message) {
    hookedServices[topic]?.add(message);

    print("demo $topic $message");
  }
}
