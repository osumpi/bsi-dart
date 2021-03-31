part of bsi;

/// State of a Service.
class State {
  /// [identifier] string for the state.
  final String identifier;

  final void Function(String value)? onChange;

  /// Create a [State] with an identifier as string.
  State(this.identifier, {this.onChange});

  /// The value of the state.
  String? _value;

  @protected
  set value(String value) {
    if (value == _value) return;

    onChange?.call(_value = value);
  }

  /// The value of the state.
  @nonVirtual
  String get value => '$_value';

  @override
  String toString() => value;
}
