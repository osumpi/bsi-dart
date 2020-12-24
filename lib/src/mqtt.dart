part of bsi;

@sealed
class Mqtt {
  /// Private generic empty constructor for singleton implementation.
  Mqtt._();

  /// The singleton instance.
  static final instance = Mqtt._();

  /// Redirecting factory constructor to the singleton instance.
  factory Mqtt() => instance;

  /// Instance of [MqttServerClient].
  final MqttServerClient client = MqttServerClient('0.0.0.0', 'bakecode');

  /// QOS to be used for all messages.
  static const MqttQos qos = MqttQos.exactlyOnce;

  /// Initialize the MQTT layer by specifying [using] with the [BSIConfiguration]
  /// specifications.
  Future<MqttClientConnectionStatus> initialize({
    @required BSIConfiguration using,
  }) async {
    assert(using != null);

    print("Initializing MQTT layer using: $using");

    client
      ..server = using.broker
      ..port = using.port
      ..keepAlivePeriod = 20
      ..autoReconnect = true
      ..onAutoReconnect = (() => print('auto-reconnecting...'))
      ..onAutoReconnected = (() => print('auto-reconnected'))
      ..onConnected = onConnected
      ..onDisconnected = (() => print('disconnected'))
      ..onBadCertificate = onBadCertificate
      ..onSubscribeFail = ((topic) => print('subscription failed'))
      ..onSubscribed = ((topic) => print('$topic subscribed'))
      ..onUnsubscribed = ((topic) => print('$topic unsubscribed'))
      // ..pongCallback = (() => log.v('pong at ${DateTime.now()}'))
      ..published
      ..updates
      ..logging(on: false)
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier('${using.representingService}')
          .keepAliveFor(client.keepAlivePeriod)
          .withWillQos(qos)
          .withWillRetain()
          // TODO: enable will conditionally.
          // .withWillMessage(
          //   '${ServiceMessage(
          //     '${using.representingService}',
          //   )..destination = Services.Broadcast}',
          // )
          // .withWillTopic('${using.representingService}')
          .authenticateAs(using.auth_username, using.auth_password);

    return await connect();
  }

  /// Connects the [client] to the broker.
  Future<MqttClientConnectionStatus> connect() async {
    try {
      return await client.connect();
    } on NoConnectionException catch (e) {
      print(e);
      client.disconnect();
    } on SocketException catch (e) {
      print(e);
      client.disconnect();
    }
    return client.connectionStatus;
  }

  /// Received messages are passed to the BSI layer.
  void onReceive(MqttReceivedMessage<MqttMessage> packet) =>
      BSI().onReceiveCallback(
        packet.topic,
        MqttPublishPayload.bytesToStringAsString(
            (packet.payload as MqttPublishMessage).payload.message),
      );

  /// Enqueue failed subscription topics which shall be dequeued onConnect;
  final pendingSubscriptions = <String>[];

  /// Subscribe to a topic.
  void subscribe(String topic) {
    try {
      client.subscribe(topic, qos);
    } catch (e) {
      print(e);
      pendingSubscriptions.add(topic);
    }
  }

  // Unsubscribe from a topic.
  void unsubscribe(String topic) {
    try {
      client.unsubscribe(topic);
    } catch (e) {
      print(e);
    }
  }

  /// Subscribes failed subscriptions and listen for updates.
  void onConnected() {
    pendingSubscriptions.forEach(subscribe);

    client.updates.listen((e) => onReceive(e[0]));

    updateConnectionState();
  }

  bool onBadCertificate(X509Certificate certificate) {
    print('bad certificate');
    return false;
  }

  /// Publish a message.
  ///
  /// Publishes the [message] to the specified [topic]. [topic] should follow
  /// MQTT Topic Guidelines.
  ///
  /// The default QOS that shall be used is [MqttQos.atLeastOnce].
  /// However this can be overriden by specifying the [qos].
  ///
  /// Set [shouldRetain] option to `true` (default: `false`), to retain the
  /// [message] when a client subscribes to the [topic].
  int publish(
    String message, {
    @required String topic,
    bool shouldRetain = false,
    MqttQos qos = MqttQos.atLeastOnce,
  }) =>
      client.publishMessage(
        topic,
        qos,
        (MqttClientPayloadBuilder()..addString(message)).payload,
        retain: shouldRetain,
      );

  /// Updates the `_connectionStateStreamController` w/ latest state.
  void updateConnectionState() =>
      _connectionStateStreamController.sink.add(client.connectionStatus.state);

  /// `StreamController` for `client`'s connection state.
  final _connectionStateStreamController =
      StreamController<MqttConnectionState>();

  /// Broadcast stream for client's connection state.
  Stream<MqttConnectionState> get connectionState =>
      _connectionStateStreamController.stream.asBroadcastStream();
}
