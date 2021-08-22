part of bakecode.core;

abstract class BSI {
  BSI() {
    // Hook the outbox to publish messages to MQTT.
    _outboxSubscription = outboxController.stream.listen(
      (message) {
        final builder = MqttClientPayloadBuilder()
          ..addString(jsonEncode(message));

        _client.publishMessage(
            message.destination.value, qos, builder.payload!);
      },
    );

    // Pause the subscription initially
    _outboxSubscription.pause();
  }

  Address get address;

  @mustCallSuper
  @protected
  void onMessageReceived(ServiceMessage message);

  State<ServiceActivityStatus> get isActive;

  @mustCallSuper
  @protected
  void initState() {
    _mySubscriptions.forEach(_subscribe);
    _client.updates!.listen((e) => _onMqttMessageReceived(e[0]));

    if (address != Address.bakecodeEngine) {
      final instantiationMessage = ServiceMessage([
        'instantiated',
        'service',
        '--name',
        config.name,
        '--id',
        config.id.uuid,
        '--address',
        address.value,
      ]);

      send(instantiationMessage.to(Address.bakecodeEngine));
    }
  }

  ServiceConfig get config;

  late final MqttServerClient _client;

  Future<bool> initialize() async {
    _log('Initializing $runtimeType#${config.id}');

    // TODO: add onExit disconnect

    // intialize mqtt client.
    _client = MqttServerClient.withPort(
      config.useWebSocket ? 'ws://${config.server}' : config.server,
      '${config.id}',
      config.port,
    )
      // The maximum seconds the client can stay idle.
      ..keepAlivePeriod = 20

      // Whether to use WebSockets protocol to connect to the server.
      ..useWebSocket = config.useWebSocket
      // Allows the client to auto-reconnect to the server.
      ..autoReconnect = true

      // Callback when the client attempts to auto-reconnect.
      ..onAutoReconnect = () {
        _log(
          'Auto-reconnecting to MQTT Server (${config.server}:${config.port})',
        );
      }

      // Callback when the client auto-reconnects to the server.
      ..onAutoReconnected = () {
        _log(
          'Auto-reconnected to MQTT Server (${config.server}:${config.port})',
        );
      }

      // Callback when the client connects to the server.
      ..onConnected = () {
        _log(
          'Connected to MQTT Server (${config.server}:${config.port})',
        );

        if (_firstTime) {
          initState();
          _firstTime = false;
        }

        _outboxSubscription.resume();
      }

      // Callback when the client disconnects from the server.
      ..onDisconnected = () {
        _log('Disconnected from MQTT Server (${config.server}:${config.port})');

        _outboxSubscription.pause();
      }

      // Callback to handle bad certificate.
      ..onBadCertificate = (cert) {
        _log('bad certificate: $cert');
        return false;
      }

      // Callback when client fails to subscribe to a topic.
      ..onSubscribeFail = (topic) {
        _log('Failed to subscribe "$topic".');
      }

      // Disables logging.
      ..logging(on: false)

      // Constructs the connection message.
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(config.id.uuid)
          .withWillTopic(isActive.address.value)
          .withWillMessage('${ServiceActivityStatus.inactive}')
          .withWillQos(qos)
          .withWillRetain()
          .authenticateAs(config.username, config.password);

    try {
      // Attempt to connect the client to the server.
      await _client.connect();
    } on NoConnectionException catch (e) {
      _log('$e');

      _client.disconnect();
      exit(1);
    } on SocketException catch (e) {
      _log('$e');

      _client.disconnect();
      exit(e.osError?.errorCode ?? 1);
    }

    _subscribeToAncestorsRecursively();

    return true;
  }

  static bool _firstTime = true;

  MqttConnectionState get connectionState => _client.connectionStatus!.state;

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
  int _publish({
    required String topic,
    required String message,
    bool shouldRetain = false,
    MqttQos qos = MqttQos.atLeastOnce,
  }) =>
      _client.publishMessage(
        topic,
        qos,
        (MqttClientPayloadBuilder()..addString(message)).payload!,
        retain: shouldRetain,
      );

  /// StreamController for outgoing messages.
  ///
  /// Services can add [ServiceMessages] to the [_outbox] and the listener of
  /// this stream shall send the messages when connection is available.
  @protected
  final outboxController = StreamController<_OutgoingMessage>();

  /// Send a message through BSI.
  ///
  /// Example:
  /// ```dart
  /// final msg = ServiceMessage(['set', 'mode', 'default']);
  /// final destination = Address('some_service');
  ///
  /// send(msg.to(destination))
  /// ```
  void send(_OutgoingMessage message) => outboxController.add(message);

  /// Recursively hooks the service to associate this child service with it's
  /// ancestors.
  void _subscribeToAncestorsRecursively([Address? address]) {
    address ??= this.address;

    _subscribe(address.value);

    final parent = address.parent;

    if (parent != null) {
      _subscribeToAncestorsRecursively(parent);
    }
  }

  /// Received messages are passed to the BSI layer.
  void _onMqttMessageReceived(MqttReceivedMessage<MqttMessage> packet) {
    final message = ServiceMessage.decode(
      MqttPublishPayload.bytesToStringAsString(
        (packet.payload as MqttPublishMessage).payload.message,
      ),
    );

    onMessageReceived(message);
  }

  /// Enqueue failed subscription topics which shall be dequeued onConnect;
  final _mySubscriptions = <String>{};

  /// Subscribe to a topic.
  void _subscribe(String topic) {
    try {
      if (_client.subscribe(topic, qos) != null) {
        _mySubscriptions.add(topic);
      }
    } catch (exception, stackTrace) {
      _log('$exception', stackTrace: stackTrace);
    }
  }

  // Unsubscribe from a topic.
  void _unsubscribe(String topic) {
    try {
      _client.unsubscribe(topic);
    } catch (exception, stackTrace) {
      _log(exception.toString(), stackTrace: stackTrace);
    } finally {
      _mySubscriptions.remove(topic);
    }
  }

  /// QOS to be used for all messages.
  static const MqttQos qos = MqttQos.exactlyOnce;

  late StreamSubscription<ServiceMessage> _outboxSubscription;
}

void _log(String message, {Object? error, StackTrace? stackTrace}) =>
    developer.log(
      message,
      time: DateTime.now(),
      name: "BSI",
      error: error,
      stackTrace: stackTrace,
    );
