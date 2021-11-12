# dart_ecpair

A library for managing SECP256k1 keypairs written in Dart.

Inspired by [bitcoinjs/ecpair](https://github.com/bitcoinjs/ecpair)

## Add Dependencies

        dart pub add dart_ecpair

## Example

``` dart
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_bip32/dart_bip32.dart';
import 'package:dart_ecpair/dart_ecpair.dart';
import 'package:dart_ecpair/src/networks.dart';
import 'package:dart_ecpair/src/utils/random_bytes.dart';

void main() {
// From WIF
  final keyPair1 =
      ECPair.fromWIF('KynD8ZKdViVo5W82oyxvE18BbG6nZPVQ8Td8hYbwU94RmyUALUik');
  print(keyPair1.toWIF());
  // => KynD8ZKdViVo5W82oyxvE18BbG6nZPVQ8Td8hYbwU94RmyUALUik
  // Random private key
  final keyPair2 = ECPair.fromPrivateKey(randomBytes(32));
  print(keyPair2.toWIF());
  // => {Random WIF}
  // OR (uses randombytes library, compatible with browser)
  final keyPair3 = ECPair.makeRandom();
  print(keyPair3.toWIF());
  // => {Random WIF}

  final random = Random.secure();
  // OR use your own custom random buffer generator BE CAREFUL!!!!
  Uint8List customRandomBufferFunc(int size) =>
      Uint8List.fromList(List<int>.generate(size, (i) => random.nextInt(256)));

  final keyPair4 =
      ECPair.makeRandom(ECPairOptions(rng: customRandomBufferFunc));
  print(keyPair4.toWIF());
  // => {Random WIF}

  // From pubkey (33 or 65 byte DER format public key)
  final keyPair5 = ECPair.fromPublicKey(keyPair1.publicKey);
  print(keyPair5.publicKeyHex);
  // => 03a2529f752ad3986334ecef119600ffced36fc5853447e1b01ac0c30193b92c02

  // Pass a custom network
  final network = Network(
      messagePrefix: '\x19Litecoin Signed Message:\n',
      bip32: Bip32Type(
        public: 0x019da462,
        private: 0x019d9cfe,
      ),
      pubKeyHash: 0x30,
      scriptHash: 0x32,
      wif: 0xb0,
      bech32: ''); // Your custom network object here
  final networkECPairOptions = ECPairOptions(network: network);
  ECPair.makeRandom(networkECPairOptions);
  ECPair.fromPrivateKey(customRandomBufferFunc(32), networkECPairOptions);
  ECPair.fromPublicKey(keyPair1.publicKey, networkECPairOptions);
  // fromWIF will check the WIF version against the network you pass in
  // pass in multiple networks if you are not sure
  ECPair.fromWIF(
      'cTwJw1TREGFrFLARApkvLrEMNsksgqYWBYNPw6ES1U7yLfeSihjY', networks.testnet);
  ECPair.fromWIF('T6tT4xL9LAUb16xz5w8MGrF3G5DkqHXHKQMNgNV7rGDX6yxjeSGj',
      [networks.bitcoin, networks.testnet, networks.regtest, network]);
}
```

## TODO

- Add lower-r future to signing for sign with entropy.

## LICENSE [MIT](LICENSE)