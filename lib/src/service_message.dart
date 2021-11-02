part of bakecode.core;

class ServiceMessage {
  final List<String> arguments;

  const ServiceMessage(this.arguments);

  factory ServiceMessage.decode(final String source) {
    final args = jsonDecode(source) as List;

    return ServiceMessage(
      args.map((e) => '$e').toList(),
    );
  }

  List<String> toJson() => arguments;

  @override
  String toString() => jsonEncode(arguments);

  _OutgoingMessage to(Address destination) =>
      _OutgoingMessage(destination: destination, arguments: arguments);
}

class _OutgoingMessage extends ServiceMessage {
  final Address destination;

  const _OutgoingMessage({
    required this.destination,
    required List<String> arguments,
  }) : super(arguments);
}
