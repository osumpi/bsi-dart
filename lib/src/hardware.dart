part of bsi;

abstract class Hardware extends Service {
  String get name;
  String get description;

  @override
  ServiceReference get reference => Services.Hardwares[name];

  final _instances = <HardwareInstance>[];

  Iterable<HardwareInstance> get instances => _instances;

  HardwareInstance createInstance();

  @override
  void initState() {
    super.initState();
    set({
      State('desc'): description,
    });
  }

  @override
  void handleServiceMessage(String message) {
    super.handleServiceMessage(message);
  }
}

abstract class HardwareInstance<T extends Hardware> extends Service {
  T get hardware => _hardware;
  T _hardware;

  String uuid;

  ServiceReference get endPoint => Services.Devices[uuid];

  HardwareInstance() {
    hardware._instances.add(this);
  }

  void initialize({
    @required T hardware,
    @required String uuid,
  }) {
    this._hardware = hardware;
    this.uuid = uuid;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  ServiceReference get reference => hardware.reference[uuid];
  // TODO: add uuid

  @override
  void handleServiceMessage(String message) {
    super.handleServiceMessage(message);
  }
}

class Device extends Service {
  ServiceReference get reference => Services.Devices.child(uuid);

  final String uuid;

  Device(this.uuid);

  @override
  void handleServiceMessage(String message) {
    super.handleServiceMessage(message);

    // try {
    //   var map = jsonDecode(message);

    //   if (map is Map) {
    //     if (map.containsKey('type')) {
    //       if (map['type'] == 'RPC') {
    //         // TODO: RPC
    //       }
    //     }
    //   }
    // } catch (e) {}

    // RPC.create('move', {'px': 32, 'py': 44});

    // TODO: register RPC, from device.
    // TODO: support RPC as ServiceMessage and dispatch on receive.
  }
}
