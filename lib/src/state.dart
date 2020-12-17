part of bsi;

/// State of a Service.
class State<T> {
  /// [identifier] string for the state.
  final String identifier;

  /// Create a [State] with an identifier as string.
  State(this.identifier);

  /// The value of the state.
  T _value;

  /// The value of the state.
  @nonVirtual
  T get value => _value;

  /// The type of the state's value.
  @nonVirtual
  Type get type => T;
}
