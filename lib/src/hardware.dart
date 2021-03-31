part of bsi;

abstract class DeviceType extends Service {
  String get name;
  String get description;

  @override
  ServiceReference get reference => Services.Hardwares[name];

  final _instances = <Device>[];

  Iterable<Device> get instances => _instances;

  Device createInstance();

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

abstract class Device<T extends DeviceType> extends Service {
  T? get deviceType => _deviceType;
  T? _deviceType;

  late String uuid;

  ServiceReference get endPoint => Services.Devices[uuid];

  Device() {
    deviceType!._instances.add(this);
  }

  void initialize({
    required T hardware,
    required String uuid,
  }) {
    this._deviceType = hardware;
    this.uuid = uuid;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  ServiceReference get reference => deviceType!.reference[uuid];

  @override
  void handleServiceMessage(String message) {
    super.handleServiceMessage(message);
  }
}

class EndPointDevice extends Service {
  ServiceReference get reference => Services.Devices.child(uuid);

  final String uuid;

  EndPointDevice(this.uuid);

  Future<void> endPointMoveForward(int steps) async {
    send(
      'moving forward $steps steps',
      destinations: [Services.BakeCode],
    );

    await Future.delayed(Duration(seconds: steps));

    send(
      "move forward $steps steps completed.",
      destinations: [Services.BakeCode],
    );
  }

  /// Handles Example Message of structure:
  ///
  /// in JSON
  /// ```json
  /// {
  ///   "RPC_EVENT": {
  ///     "command": "mv_fd",
  ///     "args": {
  ///       "steps": 10
  ///     },
  ///   },
  /// }
  /// ```
  ///
  /// in YAML
  /// ```yaml
  /// RPC_EVENT:
  ///   command: mv_fd
  ///   args:
  ///     steps: 10
  /// ```
  ///
  @override
  void handleServiceMessage(String message) {
    super.handleServiceMessage(message);

    var event = jsonDecode(message) as Map<String, dynamic>;

    if (event['RPC_EVENT'] != null) {
      var rpcEvent = jsonDecode(event['RPC_EVENT']) as Map<String, dynamic>;

      var command = rpcEvent['command'];
      var args = rpcEvent['args'] as Map<String, dynamic>?;

      if (command == "mv_fd") {
        endPointMoveForward(args!['steps']);
      }
    }

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

    // TODO: support for dynamic RPC based on JSON_RPC guide
  }

  void moveForward({required int steps}) {
    send("""
  RPC_EVENT:
    command: mv_fd
    args:
      steps: 10""", destinations: [Services.BakeCode]);

    var event = RPC.create(
      command: 'mv_fd',
      args: {
        "steps": 10,
      },
    );

    send('$event', destinations: [Services.BakeCode]);
  }
}

class RPC {
  RPC.create({
    required String command,
    required Map<String, dynamic> args,
  });
}
