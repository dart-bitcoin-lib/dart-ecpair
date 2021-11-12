import 'package:dart_bip32/dart_bip32.dart';

/// Network information
class Network {
  ///Message Prefix
  String messagePrefix;

  ///Bech32 Address Prefix
  String bech32;

  /// Bip32 Public and Private Key information
  Bip32Type bip32;

  /// Public Key Hash
  int pubKeyHash;

  /// Script Hash
  int scriptHash;

  /// WIF
  int wif;

  Network(
      {required this.messagePrefix,
      required this.bech32,
      required this.bip32,
      required this.pubKeyHash,
      required this.scriptHash,
      required this.wif});
}

/// Network List
class _NetworkList {
  /// Mainnet network
  final bitcoin = Network(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  );

  /// Regtest network
  final regtest = Network(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bcrt',
    bip32: Bip32Type(
      public: 0x043587cf,
      private: 0x04358394,
    ),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  );

  /// Testnet network
  final testnet = Network(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32: Bip32Type(
      public: 0x043587cf,
      private: 0x04358394,
    ),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  );

  /// Get Network From Version
  Network? getFromVersion(int version) {
    if (version == networks.bitcoin.wif) {
      return networks.bitcoin;
    }
    if (version == networks.regtest.wif) {
      return networks.regtest;
    }
    if (version == networks.testnet.wif) {
      return networks.testnet;
    }
    return null;
  }

  /// Get Network From Name
  Network? getFromName(String name) {
    switch (name) {
      case 'bitcoin':
      case 'mainnet':
        return bitcoin;
      case 'regtest':
        return regtest;
      case 'testnet':
        return testnet;
    }
  }

  List<Network> toList() {
    return [bitcoin, testnet, regtest];
  }
}

/// Networks
final networks = _NetworkList();
