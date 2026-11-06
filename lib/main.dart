import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'poke_api.dart';
import 'trainer_store.dart';

void main() => runApp(const RutaDexApp());
final api = PokeApi();
final trainer = TrainerStore()..load();
const audioChannel = MethodChannel('ruta_dex/audio');
const colors = <String, Color>{
  'normal': Color(0xff9c9b82),
  'fire': Color(0xffef6b3a),
  'water': Color(0xff4d8fd8),
  'electric': Color(0xffffc928),
  'grass': Color(0xff67b957),
  'ice': Color(0xff74c9c7),
  'fighting': Color(0xffb4493c),
  'poison': Color(0xff9b55a1),
  'ground': Color(0xffc99d52),
  'flying': Color(0xff8895d6),
  'psychic': Color(0xffe85c89),
  'bug': Color(0xff93aa2c),
  'rock': Color(0xffaa9145),
  'ghost': Color(0xff655b8c),
  'dragon': Color(0xff6650be),
  'dark': Color(0xff66554a),
  'steel': Color(0xff9da3b4),
  'fairy': Color(0xffdc88ad),
};

class RutaDexApp extends StatelessWidget {
  const RutaDexApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'RutaDex',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff49a25a)),
      scaffoldBackgroundColor: const Color(0xffe9f5cf),
      fontFamily: 'sans-serif',
      useMaterial3: true,
    ),
    home: const Home(),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: trainer,
    builder: (_, __) => Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: RouteBackdrop()),
          SafeArea(
            child: IndexedStack(
              index: tab,
              children: const [
                DexPage(),
                SearchPage(),
                TeamsPage(),
                FavoritesPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xff3c5a45),
          border: Border(top: BorderSide(color: Color(0xff263c30), width: 4)),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 12)],
        ),
        child: NavigationBar(
          height: 72,
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          backgroundColor: const Color(0xfff7edc8),
          indicatorColor: const Color(0xff8fc865),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontWeight: FontWeight.w900,
              color: states.contains(WidgetState.selected)
                  ? const Color(0xff244432)
                  : const Color(0xff685f48),
            ),
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'RutaDex',
            ),
            NavigationDestination(
              icon: Icon(Icons.travel_explore),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Icons.backpack_outlined),
              label: 'Equipos',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_border),
              selectedIcon: Icon(Icons.star),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    ),
  );
}

class RouteBackdrop extends StatelessWidget {
  const RouteBackdrop({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RoutePainter());
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.drawColor(const Color(0xffdff1b7), BlendMode.src);
    final water = Paint()..color = const Color(0xff83c8cf);
    c.drawRect(Rect.fromLTWH(0, 0, 42, s.height), water);
    final wave = Paint()..color = const Color(0xffb9e4dd);
    for (double y = 18; y < s.height; y += 34) {
      c.drawRect(Rect.fromLTWH(6, y, 25, 4), wave);
    }
    final g = Paint()..color = const Color(0xff9ccc67);
    for (double y = 36; y < s.height; y += 72) {
      for (double x = (y ~/ 72).isEven ? 8 : 42; x < s.width; x += 86) {
        c.drawRect(Rect.fromLTWH(x, y, 18, 7), g);
        c.drawRect(Rect.fromLTWH(x + 5, y - 6, 5, 13), g);
      }
    }
    final r = Paint()..color = const Color(0x33c79a58);
    final p = Path()
      ..moveTo(s.width * .35, 0)
      ..cubicTo(
        s.width * .75,
        s.height * .3,
        s.width * .1,
        s.height * .65,
        s.width * .62,
        s.height,
      )
      ..lineTo(s.width * .9, s.height)
      ..cubicTo(
        s.width * .4,
        s.height * .65,
        s.width,
        s.height * .3,
        s.width * .62,
        0,
      )
      ..close();
    c.drawPath(p, r);
    final treeDark = Paint()..color = const Color(0xff39734a);
    final treeLight = Paint()..color = const Color(0xff5f9f55);
    for (double y = 105; y < s.height; y += 155) {
      for (final x in [54.0, s.width - 34]) {
        c.drawRect(Rect.fromLTWH(x - 8, y + 15, 16, 16), treeDark);
        c.drawCircle(Offset(x, y), 20, treeDark);
        c.drawCircle(Offset(x - 7, y - 5), 12, treeLight);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, this.subtitle, {super.key, this.trailing});
  final String title, subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 12, 14, 10),
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: BoxDecoration(
      color: const Color(0xfffff4c9),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xff71583b), width: 3),
      boxShadow: const [
        BoxShadow(color: Color(0xff49643e), offset: Offset(0, 5)),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xffff755d), Color(0xffcc3f38)],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xff783c32), width: 3),
          ),
          child: const Icon(Icons.catching_pokemon, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff294936),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xff52705c),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class DexPage extends StatefulWidget {
  const DexPage({super.key});
  @override
  State<DexPage> createState() => _DexPageState();
}

class _DexPageState extends State<DexPage> {
  final scroll = ScrollController();
  final items = <Pokemon>[];
  bool loading = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
    scroll.addListener(() {
      if (scroll.position.pixels > scroll.position.maxScrollExtent - 500)
        load();
    });
  }

  Future<void> load() async {
    if (loading) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final next = await api.page(items.length);
      if (mounted) setState(() => items.addAll(next));
    } catch (_) {
      if (mounted)
        setState(() => error = 'La ruta está nublada. Revisa tu conexión.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const PageTitle('RutaDex', 'Explora, descubre y arma tu equipo'),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
            items.clear();
            await load();
          },
          child: GridView.builder(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .82,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: items.length + 1,
            itemBuilder: (_, i) {
              if (i < items.length) return PokemonCard(items[i]);
              if (error != null)
                return Center(
                  child: FilledButton.tonal(
                    onPressed: load,
                    child: const Text('Reintentar'),
                  ),
                );
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    ],
  );
}

class PokemonCard extends StatelessWidget {
  const PokemonCard(this.pokemon, {super.key});
  final Pokemon pokemon;
  @override
  Widget build(BuildContext context) {
    final color = colors[pokemon.types.first] ?? Colors.grey;
    final dark = Color.lerp(color, Colors.black, .27)!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(pokemon)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(color, Colors.white, .05)!,
              Color.lerp(color, Colors.black, .12)!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark, width: 3),
          boxShadow: [
            BoxShadow(color: dark, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CardPattern(color: dark)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dark,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: Text(
                          '#${pokemon.id.toString().padLeft(4, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: trainer,
                        builder: (_, __) => GestureDetector(
                          onTap: () => trainer.toggle(pokemon.id),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xfffff3b0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: dark, width: 2),
                            ),
                            child: Icon(
                              trainer.favorites.contains(pokemon.id)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xffe89d21),
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final spriteSize = constraints.biggest.shortestSide
                            .clamp(112.0, 190.0);
                        return Center(
                          child: Hero(
                            tag: 'poke-${pokemon.id}',
                            child: SizedBox.square(
                              dimension: spriteSize,
                              child: Image.network(
                                pokemon.sprite(),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.none,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.help_outline, size: 70),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                    decoration: BoxDecoration(
                      color: const Color(0xfffff5d7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dark, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pokemon.title,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xff2d3f32),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 5,
                          children: pokemon.types
                              .map((t) => TypePill(t, dark: true))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPattern extends CustomPainter {
  const _CardPattern({required this.color});
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color.withValues(alpha: .14);
    c.drawCircle(Offset(s.width - 32, 76), 47, p);
    c.drawCircle(
      Offset(s.width - 32, 76),
      14,
      Paint()..color = Colors.white.withValues(alpha: .22),
    );
    c.drawRect(Rect.fromLTWH(0, s.height * .53, s.width, 5), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TypePill extends StatelessWidget {
  const TypePill(this.type, {super.key, this.dark = false});
  final String type;
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: dark
          ? (colors[type] ?? Colors.grey)
          : Colors.white.withValues(alpha: .28),
      borderRadius: BorderRadius.circular(20),
      border: dark ? Border.all(color: Colors.white, width: 1) : null,
    ),
    child: Text(
      type.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final input = TextEditingController();
  Pokemon? result;
  bool loading = false;
  String? message;
  String type = 'todos';
  int gen = 0;
  Future<void> search() async {
    if (input.text.trim().isEmpty) return;
    setState(() {
      loading = true;
      message = null;
      result = null;
    });
    try {
      final p = await api.get(input.text);
      if ((type != 'todos' && !p.types.contains(type)) ||
          (gen != 0 && p.generation != gen)) {
        message = 'Lo encontramos, pero no coincide con tus filtros.';
      } else {
        result = p;
      }
    } catch (_) {
      message = 'No apareció ninguno. Prueba nombre o número.';
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      const PageTitle('Puesto de rastreo', 'Busca por nombre o número'),
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xfffff4cf),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xff735a3d), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0xff4f7049), offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: input,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                hintText: 'Ej. treecko o 252',
                prefixIcon: const Icon(Icons.radar),
                suffixIcon: IconButton(
                  onPressed: search,
                  icon: const Icon(Icons.search),
                ),
                filled: true,
                fillColor: const Color(0xfffff9dd),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.tune, size: 18),
                SizedBox(width: 6),
                Text(
                  'FILTROS DE ENCUENTRO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      filled: true,
                    ),
                    items: ['todos', ...colors.keys]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => type = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: gen,
                    decoration: const InputDecoration(
                      labelText: 'Generación',
                      filled: true,
                    ),
                    items: List.generate(
                      10,
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(i == 0 ? 'Todas' : 'Gen $i'),
                      ),
                    ),
                    onChanged: (v) => setState(() => gen = v!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      if (loading) const Center(child: CircularProgressIndicator()),
      if (message != null)
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      if (result != null)
        Center(
          child: SizedBox(width: 210, height: 260, child: PokemonCard(result!)),
        ),
    ],
  );
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final ids = trainer.favorites.toList()..sort();
    return Column(
      children: [
        const PageTitle('Álbum brillante', 'Tus encuentros favoritos'),
        Expanded(
          child: ids.isEmpty
              ? const EmptyCamp('Marca estrellas para llenar tu álbum')
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .82,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: ids.length,
                  itemBuilder: (_, i) => FutureBuilder<Pokemon>(
                    future: api.get(ids[i]),
                    builder: (_, s) => s.hasData
                        ? PokemonCard(s.data!)
                        : const Card(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                  ),
                ),
        ),
      ],
    );
  }
}

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});
  Future<void> teamDialog(BuildContext context, {int? edit}) async {
    final c = TextEditingController(
      text: edit == null ? '' : trainer.teams[edit].name,
    );
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(edit == null ? 'Nuevo equipo' : 'Renombrar equipo'),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLength: 24,
          decoration: const InputDecoration(labelText: 'Nombre del equipo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    edit == null ? trainer.addTeam(name) : trainer.rename(edit, name);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      PageTitle(
        'Campamento',
        'Hasta 6 compañeros por equipo',
        trailing: IconButton.filled(
          onPressed: () => teamDialog(context),
          icon: const Icon(Icons.add),
        ),
      ),
      Expanded(
        child: trainer.teams.isEmpty
            ? const EmptyCamp('Crea tu primer equipo de aventura')
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: trainer.teams.length,
                itemBuilder: (_, i) {
                  final t = trainer.teams[i];
                  return Card(
                    color: const Color(0xfffff6cf),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: const BorderSide(
                        color: Color(0xff8eb660),
                        width: 3,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text('${t.members.length}/6'),
                              IconButton(
                                onPressed: () => teamDialog(context, edit: i),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => trainer.delete(i),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 76,
                            child: Row(
                              children: List.generate(6, (slot) {
                                final filled = slot < t.members.length;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: InkWell(
                                      onLongPress: filled
                                          ? () => trainer.removeMember(
                                              i,
                                              t.members[slot],
                                            )
                                          : null,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: filled
                                              ? const Color(0xffdbeeb7)
                                              : const Color(0xffeadfb8),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xff8b7750),
                                            width: 2,
                                          ),
                                        ),
                                        child: filled
                                            ? Image.network(
                                                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${t.members[slot]}.png',
                                              )
                                            : const Icon(
                                                Icons.catching_pokemon,
                                                color: Color(0xffb5a67c),
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          if (t.members.isNotEmpty)
                            const Text(
                              'Mantén presionado para retirar',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    ],
  );
}

class EmptyCamp extends StatelessWidget {
  const EmptyCamp(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.all(28),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xfffff4cf),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xff6d593e), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xff4e7148), offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.park, size: 74, color: Color(0xff699b55)),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

class DetailPage extends StatefulWidget {
  const DetailPage(this.pokemon, {super.key});
  final Pokemon pokemon;
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _EncounterPainter extends CustomPainter {
  const _EncounterPainter(this.color);
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    c.drawColor(color, BlendMode.src);
    final light = Paint()..color = Colors.white.withValues(alpha: .14);
    final dark = Paint()..color = Colors.black.withValues(alpha: .12);
    for (double x = -30; x < s.width + 50; x += 64) {
      c.drawRect(Rect.fromLTWH(x, 0, 30, s.height), light);
    }
    c.drawCircle(Offset(s.width * .72, s.height * .48), 118, light);
    c.drawCircle(Offset(s.width * .72, s.height * .48), 38, dark);
    c.drawRect(Rect.fromLTWH(0, s.height - 46, s.width, 46), dark);
    final grass = Paint()..color = Colors.white.withValues(alpha: .16);
    for (double x = 12; x < s.width; x += 34) {
      c.drawRect(Rect.fromLTWH(x, s.height - 58, 18, 6), grass);
      c.drawRect(Rect.fromLTWH(x + 6, s.height - 65, 5, 13), grass);
    }
  }

  @override
  bool shouldRepaint(covariant _EncounterPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  bool shiny = false;
  late final TabController tabs;
  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 3, vsync: this);
    final cry = widget.pokemon.cry;
    if (cry != null && !kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        audioChannel.invokeMethod('play', {'url': cry});
      });
    }
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  Future<void> addToTeam() async {
    if (trainer.teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea un equipo en Campamento')),
      );
      return;
    }
    final team = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                '¿A qué equipo se unirá?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(
              trainer.teams.length,
              (i) => ListTile(
                leading: const Icon(Icons.backpack),
                title: Text(trainer.teams[i].name),
                trailing: Text('${trainer.teams[i].members.length}/6'),
                onTap: () => Navigator.pop(context, i),
              ),
            ),
          ],
        ),
      ),
    );
    if (team == null) return;
    final ok = trainer.addMember(team, widget.pokemon.id);
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? '¡Se unió al equipo!' : 'Está lleno o ya lo incluye',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pokemon;
    final color = colors[p.types.first] ?? Colors.grey;
    return Scaffold(
      backgroundColor: Color.lerp(color, Colors.white, .84),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addToTeam,
        icon: const Icon(Icons.add),
        label: const Text('Al equipo'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: color,
            actions: [
              IconButton(
                onPressed: () => setState(() => shiny = !shiny),
                tooltip: 'Versión shiny',
                icon: Icon(
                  shiny ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                ),
              ),
              AnimatedBuilder(
                animation: trainer,
                builder: (_, __) => IconButton(
                  onPressed: () => trainer.toggle(p.id),
                  icon: Icon(
                    trainer.favorites.contains(p.id)
                        ? Icons.star
                        : Icons.star_border,
                    color: const Color(0xffffdf5d),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _EncounterPainter(color)),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(50, 68, 50, 15),
                      child: Hero(
                        tag: 'poke-${p.id}',
                        child: Image.network(
                          shiny ? p.sprite(shiny: true) : p.artwork,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              Image.network(p.sprite(shiny: shiny)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 13,
                    child: Text(
                      '#${p.id.toString().padLeft(4, '0')}  ${p.title}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Colors.black45, offset: Offset(1, 2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  color: color,
                  child: TabBar(
                    controller: tabs,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: const Color(0xffffe46e),
                    tabs: const [
                      Tab(text: 'ACERCA DE'),
                      Tab(text: 'STATS'),
                      Tab(text: 'EVOLUCIÓN'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 390,
                  child: TabBarView(
                    controller: tabs,
                    children: [
                      About(p: p, color: color),
                      Stats(p: p, color: color),
                      Evolution(p: p),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class About extends StatelessWidget {
  const About({super.key, required this.p, required this.color});
  final Pokemon p;
  final Color color;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      Wrap(
        spacing: 8,
        children: p.types
            .map(
              (e) => Chip(
                backgroundColor: colors[e],
                label: Text(
                  e.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 15),
      Row(
        children: [
          Expanded(
            child: Fact(
              icon: Icons.height,
              label: 'Altura',
              value: '${(p.height / 10).toStringAsFixed(1)} m',
            ),
          ),
          Expanded(
            child: Fact(
              icon: Icons.monitor_weight_outlined,
              label: 'Peso',
              value: '${(p.weight / 10).toStringAsFixed(1)} kg',
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      const Text(
        'Habilidades',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      Text(
        p.abilities.map((e) => e.replaceAll('-', ' ')).join('  •  '),
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}

class Fact extends StatelessWidget {
  const Fact({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 30),
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
      Text(label),
    ],
  );
}

class Stats extends StatelessWidget {
  const Stats({super.key, required this.p, required this.color});
  final Pokemon p;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xfffff9df),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color.lerp(color, Colors.black, .25)!,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(color, Colors.black, .25)!,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'PERFIL DE COMBATE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: Color(0xff314637),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: _RadarPainter(stats: p.stats, color: color),
              child: const SizedBox.expand(),
            ),
          ),
          const Text(
            'Escala de estadísticas base',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xff5a6c60),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.stats, required this.color});
  final Map<String, int> stats;
  final Color color;
  static const keys = [
    'hp',
    'attack',
    'defense',
    'special-attack',
    'special-defense',
    'speed',
  ];
  static const labels = [
    'PS',
    'ATAQUE',
    'DEFENSA',
    'ATQ. ESP.',
    'DEF. ESP.',
    'VELOCIDAD',
  ];

  Offset point(Offset center, double radius, int i) {
    final angle = -math.pi / 2 + i * math.pi / 3;
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  Path polygon(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final p = point(center, radius, i);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 4);
    final radius = math.min(size.width, size.height) * .31;
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xff9cad91);
    for (final scale in [.25, .5, .75, 1.0])
      canvas.drawPath(polygon(center, radius * scale), grid);
    for (var i = 0; i < 6; i++)
      canvas.drawLine(center, point(center, radius, i), grid);
    final data = Path();
    for (var i = 0; i < 6; i++) {
      final factor = math.min((stats[keys[i]] ?? 0) / 150, 1.0);
      final p = point(center, radius * factor, i);
      i == 0 ? data.moveTo(p.dx, p.dy) : data.lineTo(p.dx, p.dy);
    }
    data.close();
    canvas.drawPath(data, Paint()..color = color.withValues(alpha: .36));
    canvas.drawPath(
      data,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Color.lerp(color, Colors.black, .12)!,
    );
    for (var i = 0; i < 6; i++) {
      final anchor = point(center, radius + 28, i);
      final value = stats[keys[i]] ?? 0;
      final painter = TextPainter(
        text: TextSpan(
          text: '${labels[i]}\n$value',
          style: const TextStyle(
            color: Color(0xff263c30),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 70);
      painter.paint(
        canvas,
        Offset(anchor.dx - painter.width / 2, anchor.dy - painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.stats != stats || oldDelegate.color != color;
}

class Evolution extends StatelessWidget {
  const Evolution({super.key, required this.p});
  final Pokemon p;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
    future: api.evolution(p),
    builder: (_, s) {
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      return ListView.separated(
        padding: const EdgeInsets.all(22),
        itemCount: s.data!.length,
        separatorBuilder: (_, __) => const Icon(
          Icons.keyboard_double_arrow_down,
          color: Color(0xff699b55),
        ),
        itemBuilder: (_, i) {
          final name = s.data![i];
          return FutureBuilder<Pokemon>(
            future: api.get(name),
            builder: (_, snap) => ListTile(
              tileColor: const Color(0xfffff9dd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              leading: snap.hasData
                  ? Image.network(snap.data!.sprite())
                  : const CircularProgressIndicator(),
              title: Text(
                name[0].toUpperCase() + name.substring(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              onTap: snap.hasData
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailPage(snap.data!)),
                    )
                  : null,
            ),
          );
        },
      );
    },
  );
}
