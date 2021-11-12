import 'dart:typed_data';

import 'package:dart_ecpair/src/networks.dart';

abstract class Signer {
  /// Public Key
  Uint8List get publicKey;

  /// Network
  abstract Network network;

  /// Sign
  Uint8List sign(Uint8List hash);
}
