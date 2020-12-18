part of bsi;

/// State of a Service.
class State {
  /// [identifier] string for the state.
  final String identifier;

  /// Create a [State] with an identifier as string.
  State(this.identifier);

  /// The value of the state.
  String _value;

  /// The value of the state.
  @nonVirtual
  String get value => '$_value';

  @override
  String toString() => value;
}
