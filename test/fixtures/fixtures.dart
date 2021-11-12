import 'dart:convert';
import 'dart:io';

import 'models.dart';

export 'models.dart';

String _jsonString = File('test/fixtures/fixture.json').readAsStringSync();
Map<String, dynamic> _json = jsonDecode(_jsonString);

Fixtures fixtures = Fixtures.fromJson(_json);
