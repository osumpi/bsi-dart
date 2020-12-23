part of bsi;

/// The send options for a message to be sent.
///
/// Allows special options to be applied to a message before being sent by the
/// BSI.
///
/// *Note:* SendOptions on a receiving message does not play any role, and
/// cannot be from a message.
///
/// Options include [retain]. See [retain].
@immutable
class SendOptions {
  /// If important is set, the message will be queued to be sent on reconnect.
  /// Else, discards the message such that on reconnect, the message will not
  /// be present in queue.
  ///
  /// This option is used for messages that are periodic which requires only
  /// to keep the latest values.
  ///
  /// For example: Reporting no. of devices that are currently online, as this
  /// message being sent on reconnect won't make sense as there will be a huge
  /// time difference.
  ///
  /// TODO: periodic set({}) and nonPeriodic set({}).
  final bool important;

  /// Retains the message on the topic, so that when a new client subscribes to
  /// the topic, the message is retained. Note that previous retained message
  /// on that topic will no longer be retained if any.
  final bool retain;

  const SendOptions({
    this.important = true,
    this.retain = false,
  });
}

class _OutgoingMessage {
  final ServiceReference source;

  final Iterable<ServiceReference> destinations;

  final ServiceMessage message;

  final SendOptions options;

  const _OutgoingMessage(
    this.message, {
    @required this.source,
    @required this.destinations,
    @required this.options,
  });
}
