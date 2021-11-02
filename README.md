# BakeCode Services Interconnect (Dart API)

A rich decentralized Service Oriented Architecture (SOA) implementation.

To interact with the BakeCode Ecosystem, BSI shall be used because it
makes sure that the messages sent are structured in the desired way for
easy processing by the receiving entities and also implements many other
functionalities of and for SOA.

## Getting started

This section shall discuss implementing the BSI layer in an application
that requires communicating with a BakeCode Ecosystem.

### 1. Installing

By using BakeCode Services Interconnect Layer, you agree to comply with
it's [LICENSE](https://github.com/crysalisdevs/bsi-dart/blob/main/LICENSE).

#### 1.1 Depend on it

Add the package to your project's pubspec.yaml file:

```yaml
dependencies:
  bsi:
    git: git@github.com:crysalisdevs/bsi-dart.git
```

#### 1.2 Install it

You can install the package from the command line:

```sh
pub get
```

#### 1.3 Import it

Now in your Dart project, you can use:

```dart
import 'package:bsi/bsi.dart`;
```

### 2. Usage

#### 2.1 Creating a Service

BakeCode Services Interconnect Layer, as the name itself suggests,is
an interconnect of services and hence a Service has to be implemented
first, even before we can attempt to initialize the BSI layer.

Services can be created by extending the `Service` class provided by the
BSI package.

As an example:

```dart
import 'package:bsi/bsi.dart';

class MyService extends Service {
  /// It is suggested that every application's top service is a singleton.
  /// However services that may have multiple instances shall not
  /// require the singleton implementation.

  /// The private generative constructor for singleton implementation.
  MyService._();

  /// The singleton instance of MyAppService.
  static final instance = MyService._();

  /// Factory constructor that redirects to the singleton instance.
  factory MyService() => instance;

  /// The name shall follow MQTT topic guidelines, see API docs of
  /// ServiceReference.
  ///
  /// The name shall contain a unique id if the service is not a
  /// singleton. [this.hashCode] may be used however, if the existence
  /// of the service depends on other factors in the ecosystem, it's
  /// id shall be used to prevent mismatch on application restart.
  @override
  ServiceReference get reference => ServiceReference.root('myapp');
}
```

#### 2.2 Initializing the BSI layer

To establish communication with the BakeCode Ecosystem, the ecosystem's
specific configurations must be specified. The BSI uses MQTT as the
application layer protocol.

To initialize the MQTT instance inside the BSI layer with the ecosystem,
the MQTT connection parameters must be specified to initialize.

```dart
import 'package:bsi/bsi.dart';

void main() async {

  // Specify the MQTT connection parameters.
  var connection = MqttConnection.from(
    service: MyService.instance.reference,
    broker: "127.0.0.1",
    port: 1883,
    authentication_username: "ignore_if_no_authentication",
    authentication_password: "k3eP de Cr3DeN7!4L$ s3cr3t",
  );

  // Initialize the MQTT instance with the above conection specifications.
  //
  // The future completes after initializing and attempting to connect
  // with the ecosystem and returns the MqttConnectionStatus.
  var connectionStatus = await Mqtt().initialize(using: connection);

  // The BSI layer is now ready for use if everything goes well.
}
```

#### 2.3 Sending and receiving messages

Every service instance will have `notify`, `notifyAll` and `broadcast`
function, which shall allow the service to send messages to a target
service(s).

Example:

```dart

ServiceReference to = BakeCode.instance.reference;

// (!) [notify] and [notifyAll] invocations shall be done inside the
// service implementation as it's likely that it'll be protected in the
// future.

MyService.notify(to, message: 'hey bakecode, sup!');

Iterable<ServiceReference> toAll = [
  BakeCode.instance,
  DispenserHardware.instance,
].map((s) => s.reference);

MyService.notifyAll(toAll, message: 'hey everyone, sup!');

```

To listen to the messages sent by other services to the service instance,
the `onReceive` gives access to the stream.

The following example prints the received Service Messages.
The stream is of type: `ServiceMessage` and hence `source`, `destination`,
and `message` is preserved.

```dart
MyService.onReceive.listen(print);
```

The above shall print the received messages in the format:

```json
{
  "source": "<the source of the message>",
  "destinations": ["<destination1>", "<destination2>", ... ],
  "message": "<the message sent by the source>",
}
```

## License

  Copyright (C) 2020  BakeCode Authors

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
