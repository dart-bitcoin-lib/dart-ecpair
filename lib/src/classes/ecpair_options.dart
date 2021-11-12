import 'dart:typed_data';

import '../networks.dart';

/// ECPair Options
class ECPairOptions {
  /// Is compressed ?
  bool compressed;

  /// Network
  Network? network;

  /// Byte generator
  Uint8List Function(int arg0)? rng;

  ECPairOptions({this.compressed = true, this.network, this.rng});
}
