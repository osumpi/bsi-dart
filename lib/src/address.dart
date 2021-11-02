part of bakecode.core;

/// A reference to the location of a service in the ecosystem's.
@immutable
@sealed
class Address with EquatableMixin {
  /// Creates a reference to the service from the specified [value].
  ///
  /// [value] must follow MQTT topic guidelines.
  /// * Use only ASCII Characters, and avoid non-printable characters.
  /// * Should not contain spaces.
  /// * Should not use uncommon characters or any special characters.
  /// * Should be relevant to the [Service] layer.
  ///
  /// TODO: write example, and update MQTT guidelines
  /// TODO: add other regex checks too...
  /// TODO: a flag `validate` default to true, else skips checking
  Address(this.value)
      : assert(!value.startsWith('/'), "value must not start with '/'."),
        assert(!value.contains(' '), "value must no contain whitespaces");

  /// Returns the reference to the [service].
  ///
  /// `name` must follow MQTT single-level topic guidelines.
  /// * Should be short and concise.
  /// * Use only ASCII Characters, and avoid non-printable characters.
  /// * Should not contain spaces.
  /// * Should not use uncommon characters or any special characters.
  /// * Should not contain `/`.
  /// * Should be relevant to the [Service] layer.
  ///
  /// TODO: write example, and update above MQTT guidelines.
  factory Address.of(Service service) => service.address;

  /// The address of the service as string. Equivalent to the MQTT topic
  /// associated with the service.
  /// TODO: write example
  final String value;

  late final levels = value.split('/');

  late final parent = !value.contains('/')
      ? null
      : Address(([...levels]..removeLast()).join('/'));

  /// Whether the service of this reference has a parent service or not.
  /// Is true if this is a top-level service or else false.
  ///
  /// TODO: write an example for hasParent
  late final hasParent = parent != null;

  @override
  late final props = [value];

  /// The path to the service as a string. Equivalent to the MQTT topic
  /// associated with the service.
  ///
  /// Is equivalent to value of [value].
  @override
  String toString() => value;

  /// The address where the BakeCode Engine is associated with.
  static final bakecodeEngine = Address('bakecode_engine');
}
