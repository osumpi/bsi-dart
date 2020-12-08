part of bsi;

abstract class Service {
  /// Default constructor for [Service].
  ///
  /// Registers onMessage stream controller's sink for listening to messages
  /// related to [context].
  Service() {
    BSI.instance.hook(this, sink: _onReceiveSink);
  }

  /// Provides a handle for BakeCode services.
  ///
  /// Path makes every [Service]s to be identifiable.
  ServiceReference get reference;

  /// Exposes all incoming messages for this service.
  ///
  /// Listen to messages that is addressed to this service.
  Stream<ServiceMessage> get onReceive => _onReceiveController.stream;

  /// Sends the message to the destinations specified in the message.
  ///
  /// Sends by adding the message to the [BSI.instance]'s outbox.
  @nonVirtual
  void send(ServiceMessage message) => BSI.instance.outbox.add(message);

  /// Sink of [_onReceiveController].
  StreamSink<ServiceMessage> get _onReceiveSink => _onReceiveController.sink;

  /// Stream controller for on message events.
  final _onReceiveController = StreamController<ServiceMessage>();
}

abstract class StatefulService extends Service {
  /// [ServiceReference] of the state of this service.
  ///
  /// All [StateService] associated w/ a [Service] resides here.
  ServiceReference get state => reference.child('state');

  State createState();
}

abstract class State<T extends StatefulService> {
  @protected
  final Map<String, Object> state = {};

  @mustCallSuper
  @protected
  void initState() {}

  @protected
  @nonVirtual
  FutureOr setState(FutureOr Function() fn) async => await fn();
}

class BakeCode extends StatefulService {
  get reference => ServiceReference.root('bae');

  createState() => _BakeCodeState();
}

class _BakeCodeState extends State<BakeCode> {}
