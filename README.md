# BakeCode Services Interconnect Layer (dart API)

BSI can be used to interact w/ a BakeCode Ecosystem.
    
    Copyright (C) 2020  BakeCode Authors

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

### To use BSI dart API

#### 1. Add submodule
Add the repo as submodule to your dart project's directory.
```sh
$ git submodule add https://github.com/crysalisdevs/bsi-dart.git
```

#### 2. Depend on it
Add this to your project's pubspec.yaml file:
```yaml
dependencies:
  bsi_dart:
    path: bsi-dart/
```
#### 3. Install it
```sh
$ pub get
```


### Usage

```dart
void main() async {

  // Get the config from bakecode.yaml as map and read the 'MQTT' map.
  var config = getConnectionConfig();

  // Initialize the BSI layer using the config
  await BSI.instance.init(config);

  // BSI shall now be ready for use.
}
```
