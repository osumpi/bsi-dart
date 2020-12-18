part of bsi;

// TODO: add certificate propoerty, secure TLS/SSL socket connection.
// TODO: do JsonSerializable

/// This class contains all parameters required for establishing a MQTT
/// connection to the broker.
@immutable
class BSIConfiguration {
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
  /// var auth_username = "admin";
  /// ```
  final String auth_username;

  /// Broker authentication password.
  ///
  /// *Example:*
  /// ```dart
  /// var auth_password = "bakecode is osum!";
  /// ```
  final String auth_password;

  /// The [representingService] that attempts to make the connection.
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
  final ServiceReference representingService;

  /// Create instance of MqttConnection from specified data.
  ///
  /// * Address of [broker]. eg: `"192.168.0.7"`.
  /// * MQTT broker's [port] number. default: `1883`.
  /// * Authentication credentials can be specified using
  /// [auth_username] & [auth_password].
  const BSIConfiguration.from({
    @required this.representingService,
    @required this.broker,
    this.port = 1883,
    this.auth_username = '',
    this.auth_password = '',
  });

  /// Returns true if authentication credentials are specified.
  bool get hasAuthentication => auth_username != '' || auth_password != '';

  Map<String, String> toJson() => {
        "broker": broker,
        "port": '$port',
        "auth_username": '$auth_username',
        "auth_password": '$auth_password'
      };

  @override
  String toString() => jsonEncode(toJson());
}
