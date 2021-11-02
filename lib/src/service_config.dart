part of bakecode.core;

class ServiceConfig {
  ServiceConfig({
    required this.name,
    required this.description,
    required this.id,
    required this.isSingleton,
    required this.server,
    required this.port,
    required this.useWebSocket,
    required this.username,
    required this.password,
    required this.location,
  }) : assert(0 < port && port < 65536, 'Invalid port number');

  factory ServiceConfig.loadFromYaml(final String yaml) {
    final map = loadYaml(yaml) as YamlMap;

    final protocol = (map['protocol'] ?? 'websocket') as String;
    assert(protocol == 'websocket' || protocol == 'tcp',
        'Unrecognized protocol: $protocol. Expected "websocket" or "tcp".');

    final useWebSocket = protocol == 'websocket';

    return ServiceConfig(
      name: map['name'] as String,
      description: (map['description'] ?? '') as String,
      id: UuidValue(map['id'] as String),
      isSingleton: map['singleton'] as bool,
      server: map['server'] as String,
      port: map['port'] as int,
      useWebSocket: useWebSocket,
      username: map['username'] as String,
      password: map['password'] as String,
      location: Address(map['location'] as String),
    );
  }

  final String name;
  final String description;

  final UuidValue id;
  final bool isSingleton;
  final String server;
  final int port;
  final bool useWebSocket;

  final String username;
  final String password;

  final Address location;
}
