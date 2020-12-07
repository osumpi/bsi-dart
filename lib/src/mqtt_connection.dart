part of bsi_dart;

// TODO: add certificate propoerty, secure TLS/SSL socket connection.
// TODO: do JsonSerializable

/// This class contains all parameters required for establishing a MQTT
/// connection to the broker.
@immutable
class MqttConnection {
  /// The brokers address.
  ///
  /// *Example:*
  /// ```dart
  /// var broker = "192.168.0.5";
  /// ```
  final String broker;

  /// Broker's listening port number.
  ///
  /// *Example:*
  /// ```dart
  /// var port = 1883;
  /// ```
  final int port;

  /// Broker authentication username.
  ///
  /// *Example:*
  /// ```dart
  /// var authentication_username = "admin";
  /// ```
  final String authentication_username;

  /// Broker authentication password.
  ///
  /// *Example:*
  /// ```dart
  /// var authentication_password = "bakecode is osum!";
  /// ```
  final String authentication_password;

  /// The [service] that attempts to make the connection.
  ///
  /// Used for setting up willMessage and willTopic.
  ///
  /// The generated will [ServiceMessage] shall be in the format:
  /// ```dart
  /// ServiceMessage(
  ///   source: service,
  ///   destinations: [ service, broadcast ],
  ///   message: 'offline'
  /// );
  /// ```
  final ServiceReference service;

  /// Create instance of MqttConnection from specified data.
  ///
  /// * Address of [broker]. eg: `"192.168.0.7"`.
  /// * MQTT broker's [port] number. default: `1883`.
  /// * Authentication credentials can be specified using
  /// [authentication_username] & [authentication_password].
  const MqttConnection.from({
    @required this.service,
    @required this.broker,
    this.port = 1883,
    this.authentication_username = '',
    this.authentication_password = '',
  });

  /// Returns true if authentication credentials are specified.
  bool get hasAuthentication =>
      authentication_username != '' || authentication_password != '';

  @override
  String toString() => """
  {
    "broker": "$broker",
    "port": $port,
    "authentication_username": "$authentication_username",
    "authentication_password": "$authentication_password",
  }""";
}
