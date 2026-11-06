import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class PokeApi {
  static const base = 'https://pokeapi.co/api/v2';
  final cache = <int, Pokemon>{};
  Future<Pokemon> get(Object key) async {
    final id = int.tryParse('$key');
    if (id != null && cache[id] != null) return cache[id]!;
    final r = await http
        .get(Uri.parse('$base/pokemon/${'$key'.toLowerCase().trim()}'))
        .timeout(const Duration(seconds: 18));
    if (r.statusCode != 200) throw Exception('No encontrado');
    final p = Pokemon.fromJson(jsonDecode(r.body));
    cache[p.id] = p;
    return p;
  }

  Future<List<Pokemon>> page(int offset) async {
    final r = await http
        .get(Uri.parse('$base/pokemon?limit=24&offset=$offset'))
        .timeout(const Duration(seconds: 18));
    if (r.statusCode != 200) throw Exception('Sin conexión');
    return Future.wait(
      (jsonDecode(r.body)['results'] as List).map((e) => get(e['name'])),
    );
  }

  Future<List<String>> evolution(Pokemon p) async {
    final s = await http.get(Uri.parse(p.speciesUrl));
    if (s.statusCode != 200) return [p.name];
    final url = jsonDecode(s.body)['evolution_chain']['url'];
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) return [p.name];
    final out = <String>[];
    void walk(Map<String, dynamic> n) {
      out.add(n['species']['name']);
      for (final c in n['evolves_to']) {
        walk(Map<String, dynamic>.from(c));
      }
    }

    walk(Map<String, dynamic>.from(jsonDecode(r.body)['chain']));
    return out;
  }
}
