import 'dart:typed_data';

import 'package:dart_ecpair/src/networks.dart';

abstract class SignerAsync {
  /// Public Key
  abstract Uint8List publicKey;

  /// Network
  abstract Network network;

  /// Sign
  Future<Uint8List> sign(Uint8List hash);

  /// Get Public Key
  Uint8List getPublicKey();
}
