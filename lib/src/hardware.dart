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

  HardwareInstance() {
    hardware._instances.add(this);
  }

  void initialize({
    @required T hardware,
    @required String id,
  }) {
    this._hardware = hardware;
    this.uuid = id;
  }

  @override
  void initState() {
    // super.initState();
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
}

// abstract class HardwareEndPoint {}

// class SCARA extends Hardware {
//   @override
//   String get name => 'Dispenser';

//   @override
//   String get description =>
//       "Dispense dispensable entities to a dispensable container";

//   @override
//   _SCARAInstance createInstance() => _SCARAInstance();
// }

// class _SCARAInstance extends HardwareInstance<SCARA> {
//   final isOnline = State('isOnline');

//   _SCARAInstance() {}

// }
