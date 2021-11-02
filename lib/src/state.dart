part of bakecode.core;

class State<T> {
  State._({
    required String key,
    required this.of,
  }) : address = Address('${of.address}/$key');

  final Service of;

  final Address address;

  T? _value;

  T? get get => _value;

  void set(T value) {
    if (value == _value) return;

    of._publish(
      topic: address.value,
      message: (_value = value).toString(),
      shouldRetain: true,
    );
  }
}
