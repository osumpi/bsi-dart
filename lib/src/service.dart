part of bsi;

abstract class BakeCodeService {
  /// Default constructor for [BakeCodeService].
  ///
  /// Registers onMessage stream controller's sink for listening to messages
  /// related to [context].
  BakeCodeService() {
    BSI.instance.hook(this, sink: _onReceiveSink);
  }

  /// Provides a handle for BakeCode services.
  ///
  /// Path makes every [BakeCodeService]s to be identifiable.
  ServiceReference get reference;

  /// [ServiceReference] of the state of this service.
  ///
  /// All [StateService] associated w/ a [BakeCodeService] resides here.
  ServiceReference get state => reference.child('state');

  /// Exposes all incoming messages for this service.
  ///
  /// Listen to messages that is addressed to this service.
  Stream<ServiceMessage> get onReceive => _onReceiveController.stream;

  /// Sends a broadcast message.
  ///
  /// All nodes in the bakecode ecosystem may listen to the broadcast messages.
  @mustCallSuper
  void broadcast(String message) => BSI.instance.outbox
      .add(ServiceMessage.asBroadcast(source: reference, message: message));

  /// Sends the [message] [to] the service.
  @nonVirtual
  void notify(ServiceReference to, {@required String message}) =>
      BSI.instance.outbox.add(ServiceMessage(
          source: reference, destinations: [to], message: message));

  /// Sends the [message] to every service specified in [to].
  void notifyAll(Iterable<ServiceReference> to, {@required String message}) =>
      BSI.instance.outbox.add(ServiceMessage(
          source: reference, destinations: to, message: message));

  /// Sink of [_onReceiveController].
  StreamSink<ServiceMessage> get _onReceiveSink => _onReceiveController.sink;

  /// Stream controller for on message events.
  final _onReceiveController = StreamController<ServiceMessage>();
}
