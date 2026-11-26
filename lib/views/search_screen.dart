import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/location.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/view_state.dart';
import 'widgets/location_tile.dart';
import 'widgets/section_card.dart';
import 'widgets/state_message.dart';
import 'widgets/weather_icon.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(Location location) {
    context.read<SearchViewModel>().addToHistory(location);
    Navigator.of(context).pop(location);
  }

  Future<void> _toggleFavorite(Location location) async {
    final added = await context.read<FavoriteViewModel>().toggle(location);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(added
            ? '${location.name} disimpan ke favorit'
            : '${location.name} dihapus dari favorit'),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.sheetWhite,
      body: Stack(
        children: [
          SizedBox(
            height: 220 + topPad,
            width: double.infinity,
            child: Image.asset(
              'assets/images/tuscany_landscape.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Column(
            children: [
              SizedBox(height: topPad + 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.back, size: 22, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Cari Lokasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                child: _SearchField(
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {});
                    vm.onQueryChanged(value);
                  },
                  onSubmitted: (_) => vm.search(),
                  onClear: () {
                    _controller.clear();
                    setState(() {});
                    vm.onQueryChanged('');
                  },
                ),
              ),
              Expanded(
                child: ClipPath(
                  clipper: const SaddleSheetClipper(dip: 14, shoulderRadius: 32),
                  child: Container(
                    color: AppColors.sheetWhite,
                    padding: const EdgeInsets.only(top: 18),
                    child: _buildContent(vm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SearchViewModel vm) {
    switch (vm.state) {
      case ViewState.initial:
        return _SavedLocations(
          onSelect: _select,
          onToggleFavorite: _toggleFavorite,
        );
      case ViewState.loading:
        return const LoadingView(message: 'Mencari lokasi...');
      case ViewState.empty:
        return StateMessage(
          icon: CupertinoIcons.search,
          title: 'Kota tidak ditemukan',
          message: 'Tidak ada hasil untuk "${vm.query}". Periksa kembali ejaan nama kota.',
        );
      case ViewState.error:
        return StateMessage(
          icon: CupertinoIcons.wifi_exclamationmark,
          title: 'Pencarian gagal',
          message: vm.errorMessage ?? 'Terjadi kesalahan.',
          actionLabel: 'Coba lagi',
          onAction: vm.search,
        );
      case ViewState.success:
        return _SearchResults(
          results: vm.results,
          onSelect: _select,
          onToggleFavorite: _toggleFavorite,
        );
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.words,
      cursorColor: AppColors.skyTop,
      style: const TextStyle(color: AppColors.ink, fontSize: 15),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Cari nama kota...',
        prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppColors.skyTop),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(CupertinoIcons.clear_circled_solid, size: 18, color: AppColors.inkSecondary),
                onPressed: onClear,
              ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.results,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  final List<Location> results;
  final ValueChanged<Location> onSelect;
  final ValueChanged<Location> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteViewModel>();

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SectionHeader('Hasil Pencarian (${results.length})'),
        LocationGroup(
          children: [
            for (final location in results)
              LocationTile(
                location: location,
                onTap: () => onSelect(location),
                trailing: _StarButton(
                  active: favorites.isFavorite(location),
                  onPressed: () => onToggleFavorite(location),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SavedLocations extends StatelessWidget {
  const _SavedLocations({required this.onSelect, required this.onToggleFavorite});

  final ValueChanged<Location> onSelect;
  final ValueChanged<Location> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteViewModel>().favorites;
    final searchVm = context.watch<SearchViewModel>();
    final history = searchVm.history;

    if (favorites.isEmpty && history.isEmpty) {
      return const StateMessage(
        icon: CupertinoIcons.location_north_line,
        title: 'Cari Lokasi Cuaca',
        message: 'Ketik nama kota pada kolom di atas. Kota favorit dan riwayat pencarian akan tersimpan di halaman ini.',
      );
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (favorites.isNotEmpty) ...[
          const SectionHeader('Kota Favorit'),
          LocationGroup(
            children: [
              for (final location in favorites)
                LocationTile(
                  location: location,
                  onTap: () => onSelect(location),
                  trailing: _StarButton(
                    active: true,
                    onPressed: () => onToggleFavorite(location),
                  ),
                ),
            ],
          ),
        ],
        if (history.isNotEmpty) ...[
          SectionHeader(
            'Terakhir Dicari',
            trailing: TextButton(
              onPressed: searchVm.clearHistory,
              child: const Text('Hapus'),
            ),
          ),
          LocationGroup(
            children: [
              for (final location in history)
                LocationTile(
                  location: location,
                  leadingIcon: CupertinoIcons.clock,
                  onTap: () => onSelect(location),
                  trailing: IconButton(
                    tooltip: 'Hapus dari riwayat',
                    icon: const Icon(CupertinoIcons.xmark, size: 14, color: AppColors.inkSecondary),
                    onPressed: () => searchVm.removeFromHistory(location),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: active ? 'Hapus dari favorit' : 'Simpan ke favorit',
      onPressed: onPressed,
      icon: Icon(
        active ? CupertinoIcons.star_fill : CupertinoIcons.star,
        size: 19,
        color: active ? AppColors.sunGold : AppColors.inkSecondary,
      ),
    );
  }
}
