part of bakecode.core;

enum ServiceActivityStatus { active, inactive }

abstract class Service extends BSI {
  Service(this.configFile);

  final File configFile;

  @override
  late final ServiceConfig config;

  @nonVirtual
  @override
  late final address = _getAddress();

  Address _getAddress() {
    // Change camel case to snake case
    var value = '$runtimeType'
        .replaceAllMapped(RegExp('(?<=[a-z])[A-Z]'), (m) => '_${m.group(0)}')
        .toLowerCase();

    if (config.location.value.isNotEmpty) {
      value = '${config.location}/$value';
    }

    if (!config.isSingleton) {
      value = '$value-${config.id}';
    }

    return Address(value);
  }

  @override
  Future<bool> initialize() async {
    if (!await configFile.exists()) {
      throw Exception('$configFile does not exist.');
    }

    config = ServiceConfig.loadFromYaml(await configFile.readAsString());

    return super.initialize();
  }

  @override
  late final isActive = state<ServiceActivityStatus>('active');

  late final id = state<UuidValue>('id');

  late final name = state<String>('name');

  late final description = state<String>('description');

  late final isSingleton = state<bool>('singleton');

  @override
  void initState() {
    super.initState();

    id.set(config.id);
    name.set(config.name);
    description.set(config.description);
    isSingleton.set(config.isSingleton);
    isActive.set(ServiceActivityStatus.active);
  }

  @mustCallSuper
  @override
  void onMessageReceived(ServiceMessage message) {
    // TODO: handle core stuffs.
  }

  State<T> state<T>(String key) {
    return State<T>._(key: key, of: this);
  }
}
