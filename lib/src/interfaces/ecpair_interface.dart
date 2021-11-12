import 'dart:typed_data';

import 'package:dart_ecpair/src/interfaces/signer_interface.dart';
import 'package:dart_ecpair/src/networks.dart';

/// ECPair Interface Abstract
abstract class ECPairInterface extends Signer {
  /// Is compressed
  abstract bool compressed;

  /// Network
  @override
  abstract Network network;

  /// Private Key
  Uint8List? get privateKey;

  /// ECPair to WIF String
  String toWIF();

  /// Verify Signature
  bool verify(Uint8List hash, Uint8List signature);
}
