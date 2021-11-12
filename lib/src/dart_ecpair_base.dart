import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_bip32/src/utils/ecurve.dart' as ecc;
import 'package:dart_ecpair/src/classes/ecpair_options.dart';
import 'package:dart_ecpair/src/interfaces/ecpair_interface.dart';
import 'package:dart_ecpair/src/networks.dart';
import 'package:dart_wif/dart_wif.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/export.dart';

import './utils/random_bytes.dart';

export 'classes/api.dart';
export 'interfaces/api.dart';

final eccParam = ECCurve_secp256k1();

class ECPair extends ECPairInterface {
  /// Is Compressed ?
  @override
  late bool compressed;

  /// Network
  @override
  late Network network;

  /// Get Private Key
  @override
  Uint8List? get privateKey {
    return D;
  }

  /// Get Public Key
  @override
  Uint8List get publicKey {
    if (Q != null) return Q!;
    if (D == null) throw Exception('Missing private key');
    Q ??= ecc.pointFromScalar(D!, options.compressed);
    return Q!;
  }

  /// Get Private Key Hex String
  String? get privateKeyHex {
    if (privateKey == null) {
      return null;
    }
    return hex.encode(privateKey!);
  }

  /// Get Public Key Hex String
  String get publicKeyHex {
    return hex.encode(publicKey);
  }

  /// ECPoint (D)
  Uint8List? D;

  /// ECPoint (Q)
  Uint8List? Q;

  /// Options
  ECPairOptions options = ECPairOptions();

  ECPair({this.D, this.Q, ECPairOptions? options}) {
    if (options != null) {
      this.options = options;
    }
    compressed = this.options.compressed;
    network = this.options.network ?? networks.bitcoin;

    if (Q != null) {
      if (Q!.length < 128) {
        final point = eccParam.curve.decodePoint(publicKey);
        if (point == null) throw ArgumentError('Invalid Public Key');
        Q = point.getEncoded(this.options.compressed);
      } else {
        final x = BigInt.parse(hex.encode(Q!).substring(0, 64), radix: 16);
        final y = BigInt.parse(hex.encode(Q!).substring(64), radix: 16);
        Q = eccParam.curve
            .createPoint(x, y)
            .getEncoded(this.options.compressed);
      }
    }
  }

  /// Get ECPair instance from public key
  factory ECPair.fromPublicKey(Uint8List publicKey, [ECPairOptions? options]) {
    if (!ecc.isPoint(publicKey)) {
      throw Exception('Invalid Public Key');
    }

    return ECPair(Q: publicKey, options: options);
  }

  /// Get ECPair instance from private key
  factory ECPair.fromPrivateKey(Uint8List privateKey,
      [ECPairOptions? options]) {
    if (!ecc.isPrivate(privateKey)) {
      throw Exception('Invalid Private Key');
    }

    return ECPair(D: privateKey, options: options);
  }

  /// Get ECPair instance from WIF
  factory ECPair.fromWIF(String privateKey, [dynamic network]) {
    final decoded = wif.decode(privateKey);
    final int version = decoded.version;

    if (network != null) {
      if (network is List<Network>) {
        final find = network.where((x) => x.wif == version).toList();
        if (find.isEmpty) {
          throw Exception('Unknown network version');
        }
        network = find.first;
      } else if (network is! Network) {
        throw ArgumentError(
            'Argument should be List<Network> or Network.', 'network');
      }
    }

    network ??= networks.bitcoin;
    if (version != network.wif) {
      throw Exception('Invalid network version');
    }

    return ECPair.fromPrivateKey(decoded.privateKey,
        ECPairOptions(compressed: decoded.compressed, network: network));
  }

  /// Make Random Pair
  factory ECPair.makeRandom([ECPairOptions? options]) {
    options ??= ECPairOptions();
    final rng = options.rng ?? (int arg0) => randomBytes(arg0, secure: true);
    Uint8List d;
    do {
      d = rng(32);
      if (d.length != 32) {
        throw RangeError.value(d.length, 'rng', 'Returned value must be 32');
      }
    } while (!ecc.isPrivate(d));

    return ECPair.fromPrivateKey(d, options);
  }

  /// Sign
  @override
  Uint8List sign(Uint8List hash) {
    return ecc.sign(hash, privateKey!);
  }

  /// ECPair to WIF String
  @override
  String toWIF() {
    if (D == null) throw Exception('Missing private key');
    final decoded = WIF(
        version: network.wif, privateKey: D!, compressed: options.compressed);
    return wif.encode(decoded);
  }

  /// Verify Signature
  @override
  bool verify(Uint8List hash, Uint8List signature) {
    return ecc.verify(hash, publicKey, signature);
  }
}
