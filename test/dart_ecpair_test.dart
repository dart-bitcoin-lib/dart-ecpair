import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_bip32/dart_bip32.dart';
import 'package:dart_ecpair/dart_ecpair.dart';
import 'package:dart_ecpair/src/networks.dart';
import 'package:test/test.dart';

import 'fixtures/fixtures.dart';

final litecoin = NetworkType(
    bip32: Bip32Type(
      public: 0x019da462,
      private: 0x019d9cfe,
    ),
    wif: 0xb0);

Uint8List zero = Uint8List(32);
Uint8List one = hex.decode(
        '0000000000000000000000000000000000000000000000000000000000000001')
    as Uint8List;
Uint8List groupOrder = hex.decode(
        'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141')
    as Uint8List;
Uint8List groupOrderLess1 = hex.decode(
        'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140')
    as Uint8List;

void main() {
  group('ECPair', () {
    test('getPublicKey', () {
      ECPair keyPair = ECPair.fromPrivateKey(one);
      expect(keyPair.publicKeyHex,
          '0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798');
    });
    group('fromPrivateKey', () {
      test('defaults to compressed', () {
        final keyPair = ECPair.fromPrivateKey(one);

        expect(keyPair.compressed, true);
      });
      test('supports the uncompressed option', () {
        final keyPair =
            ECPair.fromPrivateKey(one, ECPairOptions(compressed: false));

        expect(keyPair.compressed, false);
      });
      test('supports the network option', () {
        final keyPair = ECPair.fromPrivateKey(
            one, ECPairOptions(network: networks.testnet));

        expect(keyPair.network, networks.testnet);
      });

      for (Valid f in fixtures.valid!) {
        test('derives public key for ${f.wif}', () {
          Uint8List d = hex.decode(f.d) as Uint8List;
          ECPair keyPair =
              ECPair.fromPrivateKey(d, ECPairOptions(compressed: f.compressed));

          expect(keyPair.publicKeyHex, f.q);
        });
      }
      for (var f in fixtures.invalid!.fromPrivateKey!) {
        test('throws ${f.exception}', () {
          Uint8List d = hex.decode(f.d) as Uint8List;
          try {
            ECPair.fromPrivateKey(d);
          } catch (e) {
            return expect(e.toString(), matches(RegExp(f.exception)));
          }
          throw Exception('It should throw "${f.exception}" exception.');
        });
      }
    });
    group('fromPublicKey', () {
      for (var f in fixtures.invalid!.fromPublicKey!) {
        test('throws ${f.exception}', () {
          final Q = hex.decode(f.q) as Uint8List;
          try {
            ECPair.fromPublicKey(Q);
          } catch (e) {
            return expect(e.toString(), matches(RegExp(f.exception)));
          }
          throw Exception('It should throw "${f.exception}" exception.');
        });
      }
    });
    group('fromWIF', () {
      for (Valid f in fixtures.valid!) {
        test('imports ${f.wif} (${f.network})', () {
          final network = networks.getFromName(f.network);
          final keyPair = ECPair.fromWIF(f.wif, network);

          expect(keyPair.privateKeyHex, equals(f.d));
          expect(keyPair.compressed, equals(f.compressed));
          expect(keyPair.network, equals(network));
        });
      }
      for (Valid f in fixtures.valid!) {
        test('imports ${f.wif} (via list of networks)', () {
          final keyPair = ECPair.fromWIF(f.wif, networks.toList());

          expect(keyPair.privateKeyHex, equals(f.d));
          expect(keyPair.compressed, equals(f.compressed));
          expect(keyPair.network, equals(networks.getFromName(f.network)));
        });
      }
      for (var f in fixtures.invalid!.fromWIF!) {
        test('throws on ${f.wif}', () {
          final _networks = f.network != null
              ? networks.getFromName(f.network!)
              : networks.toList();
          try {
            ECPair.fromWIF(f.wif, _networks);
          } catch (e) {
            expect(e.toString(), matches(RegExp(f.exception)));
            return;
          }
          throw Exception('It should throw "${f.exception}" exception.');
        });
      }
    });
    group('toWIF', () {
      for (Valid f in fixtures.valid!) {
        test('exports ${f.wif}', () {
          final keyPair = ECPair.fromWIF(f.wif, networks.toList());
          final result = keyPair.toWIF();

          expect(result, equals(f.wif));
        });
      }
    });
    group('makeRandom', () {
      final d = Uint8List.fromList(List.filled(32, 4));
      final exWIF = 'KwMWvwRJeFqxYyhZgNwYuYjbQENDAPAudQx5VEmKJrUZcq6aL2pv';

      group('uses randomBytes RNG', () {
        test('generates a ECPair', () {
          final options = ECPairOptions(rng: (int arg0) => d);

          final keyPair = ECPair.makeRandom(options);
          expect(keyPair.toWIF(), equals(exWIF));
        });
      });
      test('allows a custom RNG to be used', () {
        final keyPair = ECPair.makeRandom(
            ECPairOptions(rng: (int size) => d.sublist(0, size)));

        expect(keyPair.toWIF(), equals(exWIF));
      });
      test('retains the same defaults as ECPair constructor', () {
        final keyPair = ECPair.makeRandom();

        expect(keyPair.compressed, equals(true));
        expect(keyPair.network, equals(networks.bitcoin));
      });
      test('supports the options parameter', () {
        final keyPair = ECPair.makeRandom(
            ECPairOptions(compressed: false, network: networks.testnet));

        expect(keyPair.compressed, equals(false));
        expect(keyPair.network, equals(networks.testnet));
      });
      test('throws if d is bad length', () {
        Uint8List rng(int arg0) {
          return Uint8List(28);
        }

        try {
          ECPair.makeRandom(ECPairOptions(rng: rng));
        } catch (e) {
          return expect(
              e.toString(), matches(RegExp(r'Returned value must be 32')));
        }
        throw Exception(
            'It should throw "Returned value must be 32" exception.');
      });
    });
    group('.network', () {
      for (Valid f in fixtures.valid!) {
        test('returns ${f.network} for ${f.wif}', () {
          final network = networks.getFromName(f.network);
          final keyPair = ECPair.fromWIF(f.wif, networks.toList());

          expect(keyPair.network, network);
        });
      }
    });
  });
}

void verify() {}
