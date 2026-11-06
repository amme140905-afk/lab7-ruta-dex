import 'package:flutter_test/flutter_test.dart';
import 'package:lab7_ruta_dex/main.dart';
import 'package:lab7_ruta_dex/trainer_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('app construible', () => expect(const RutaDexApp(), isNotNull));

  test('favoritos y equipos notifican cambios inmediatamente', () async {
    SharedPreferences.setMockInitialValues({});
    final store = TrainerStore();
    var notifications = 0;
    store.addListener(() => notifications++);

    store.toggle(25);
    expect(store.favorites, contains(25));
    expect(notifications, 1);

    store.addTeam('Kanto');
    expect(store.teams.single.name, 'Kanto');
    expect(notifications, 2);

    expect(store.addMember(0, 25), isTrue);
    expect(store.teams.single.members, [25]);
    expect(notifications, 3);

    await Future<void>.delayed(Duration.zero);
  });
}
