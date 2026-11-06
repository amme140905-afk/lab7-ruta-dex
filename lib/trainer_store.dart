import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class TrainerStore extends ChangeNotifier {
  final favorites = <int>{};
  final teams = <Team>[];
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    favorites.addAll(p.getStringList('favorites')?.map(int.parse) ?? []);
    final raw = p.getString('teams');
    if (raw != null)
      teams.addAll(
        (jsonDecode(raw) as List).map(
          (e) => Team.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('favorites', favorites.map((e) => '$e').toList());
    await p.setString(
      'teams',
      jsonEncode(teams.map((e) => e.toJson()).toList()),
    );
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  void toggle(int id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    _changed();
  }

  void addTeam(String name) {
    teams.add(Team(name: name, members: []));
    _changed();
  }

  void rename(int i, String name) {
    teams[i].name = name;
    _changed();
  }

  void delete(int i) {
    teams.removeAt(i);
    _changed();
  }

  bool addMember(int i, int id) {
    if (teams[i].members.length >= 6 || teams[i].members.contains(id))
      return false;
    teams[i].members.add(id);
    _changed();
    return true;
  }

  void removeMember(int i, int id) {
    teams[i].members.remove(id);
    _changed();
  }
}
