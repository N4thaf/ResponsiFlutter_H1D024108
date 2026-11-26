import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:responsi_cuaca/main.dart' as app;
import 'package:responsi_cuaca/views/widgets/location_tile.dart';

Future<void> waitFor(WidgetTester t, Finder f, {int seconds = 25}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await t.pump();
    if (f.evaluate().isNotEmpty) return;
  }
  throw Exception('timeout $f');
}

Future<void> settle(WidgetTester t, [int ms = 1200]) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await t.pump();
  }
}

Future<void> shot(WidgetTester t, String name) async {
  await settle(t, 900);
  debugPrint('SHOT:$name');
  await settle(t, 3000);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshots', (t) async {
    app.main();
    await waitFor(t, find.text('Cuaca Hari Ini'));
    await shot(t, 'home');

    if (find.byIcon(CupertinoIcons.star).evaluate().isNotEmpty) {
      await t.tap(find.byTooltip('Favorit'));
    }
    await settle(t, 2500);

    await t.tap(find.byTooltip('Cari kota'));
    await settle(t);
    await t.enterText(find.byType(TextField), 'Surabaya');
    await waitFor(t, find.byType(LocationTile));
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(t);
    await t.tap(find.byTooltip('Simpan ke favorit').first);
    await settle(t, 2200);
    await t.tap(find.byType(LocationTile).first);
    await waitFor(t, find.text('Cuaca Hari Ini'));
    await settle(t, 1000);

    await t.tap(find.byTooltip('Cari kota'));
    await settle(t);
    await t.enterText(find.byType(TextField), 'Ban');
    await waitFor(t, find.text('Kota Bandung'));
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(t);
    final bandungTile = find.ancestor(
      of: find.text('Kota Bandung'),
      matching: find.byType(LocationTile),
    );
    final bandungStar = find.descendant(
      of: bandungTile,
      matching: find.byTooltip('Simpan ke favorit'),
    );
    await t.tap(bandungStar);
    await settle(t, 2600);
    await shot(t, 'search_results');

    await t.tap(find.text('Kota Bandung'));
    await waitFor(t, find.text('Cuaca Hari Ini'));
    await shot(t, 'home_favorites');

    await t.drag(find.byType(CustomScrollView), const Offset(0, -820));
    await shot(t, 'home_scroll');
    await t.drag(find.byType(CustomScrollView), const Offset(0, 1400));
    await settle(t);

    await t.tap(find.byTooltip('Cari kota'));
    await settle(t);
    FocusManager.instance.primaryFocus?.unfocus();
    await shot(t, 'search_saved');

    await t.enterText(find.byType(TextField), 'Qwertyzzx');
    await waitFor(t, find.text('Kota tidak ditemukan'));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot(t, 'search_empty');

    await t.tap(find.byIcon(CupertinoIcons.back));
    await settle(t);
    await t.tap(find.text('Purwokerto').last);
    await waitFor(t, find.text('Cuaca Hari Ini'));
    await shot(t, 'home_final');
  });
}
