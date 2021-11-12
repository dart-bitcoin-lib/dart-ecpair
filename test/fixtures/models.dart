class Fixtures {
  List<Valid>? valid;
  Invalid? invalid;

  Fixtures.fromJson(Map<String, dynamic> json)
      : valid = json['valid'] != null
            ? json['valid']
                .map((e) => Valid.fromJson(e))
                .cast<Valid>()
                .toList()!
            : null,
        invalid =
            json['invalid'] != null ? Invalid.fromJson(json['invalid']) : null;
}

class Valid {
  String d;
  String q;
  bool compressed;
  String network;
  String address;
  String wif;

  Valid.fromJson(Map<String, dynamic> json)
      : d = json['d'],
        q = json['Q'],
        compressed = json['compressed'],
        network = json['network'],
        address = json['address'],
        wif = json['WIF'];
}

class Invalid {
  List<FromPrivateKey>? fromPrivateKey;
  List<FromPublicKey>? fromPublicKey;
  List<FromWIF>? fromWIF;

  Invalid.fromJson(Map<String, dynamic> json)
      : fromPrivateKey = json['fromPrivateKey'] != null
            ? json['fromPrivateKey']
                .map((e) => FromPrivateKey.fromJson(e))
                .cast<FromPrivateKey>()
                .toList()!
            : null,
        fromPublicKey = json['fromPublicKey'] != null
            ? json['fromPublicKey']
                .map((e) => FromPublicKey.fromJson(e))
                .cast<FromPublicKey>()
                .toList()!
            : null,
        fromWIF = json['fromWIF'] != null
            ? json['fromWIF']
                .map((e) => FromWIF.fromJson(e))
                .cast<FromWIF>()
                .toList()!
            : null;
}

class FromPrivateKey {
  String exception;
  String d;

  FromPrivateKey.fromJson(Map<String, dynamic> json)
      : exception = json['exception'],
        d = json['d'];
}

class FromPublicKey {
  String exception;
  String q;
  String? description;

  FromPublicKey.fromJson(Map<String, dynamic> json)
      : exception = json['exception'],
        q = json['Q'],
        description = json['description'];
}

class FromWIF {
  String exception;
  String? network;
  String wif;

  FromWIF.fromJson(Map<String, dynamic> json)
      : exception = json['exception'],
        network = json['network'],
        wif = json['WIF'];
}
