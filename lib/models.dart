class Pokemon {
  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
    required this.cry,
    required this.speciesUrl,
  });
  final int id, height, weight;
  final String name, speciesUrl;
  final String? cry;
  final List<String> types, abilities;
  final Map<String, int> stats;
  String get title => name[0].toUpperCase() + name.substring(1);
  int get generation => id <= 151
      ? 1
      : id <= 251
      ? 2
      : id <= 386
      ? 3
      : id <= 493
      ? 4
      : id <= 649
      ? 5
      : id <= 721
      ? 6
      : id <= 809
      ? 7
      : id <= 905
      ? 8
      : 9;
  String sprite({bool shiny = false}) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${shiny ? 'shiny/' : ''}$id.png';
  String get artwork =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  factory Pokemon.fromJson(Map<String, dynamic> j) => Pokemon(
    id: j['id'],
    name: j['name'],
    types: (j['types'] as List)
        .map((e) => e['type']['name'] as String)
        .toList(),
    height: j['height'],
    weight: j['weight'],
    abilities: (j['abilities'] as List)
        .map((e) => e['ability']['name'] as String)
        .toList(),
    stats: {
      for (final e in j['stats'] as List)
        e['stat']['name'] as String: e['base_stat'] as int,
    },
    cry: j['cries']?['latest'],
    speciesUrl: j['species']['url'],
  );
}

class Team {
  Team({required this.name, required this.members});
  String name;
  final List<int> members;
  Map<String, dynamic> toJson() => {'name': name, 'members': members};
  factory Team.fromJson(Map<String, dynamic> j) =>
      Team(name: j['name'], members: List<int>.from(j['members']));
}
