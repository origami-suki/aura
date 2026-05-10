import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../viewmodels/weather_view_model.dart';
import 'weather_effects.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({super.key});

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeatherViewModel>().clearCitySearch();
    });
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    final viewModel = context.read<WeatherViewModel>();
    viewModel.clearCitySearch();
    if (value.trim().isEmpty) return;

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      viewModel.searchCities(value);
    });
  }

  Future<void> _selectCity(
    WeatherViewModel viewModel,
    CitySearchResult result,
  ) async {
    if (_isSelecting) return;

    setState(() => _isSelecting = true);
    try {
      await viewModel.selectCity(result);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save this city. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSelecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: EdgeInsets.only(
        top: AuraSpacing.sm,
        left: AuraSpacing.md,
        right: AuraSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AuraSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surfaceContainerLow, colorScheme.surface],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AuraRadii.sheet),
        ),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
        ),
      ),
      child: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.uiState;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: AuraSpacing.xxs,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha(102),
                    borderRadius: BorderRadius.circular(AuraRadii.full),
                  ),
                ),
              ),
              const SizedBox(height: AuraSpacing.lg),
              Text(
                'Choose location',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AuraSpacing.md),
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search city name...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: state.isSearchingCities
                      ? const Padding(
                          padding: EdgeInsets.all(AuraSpacing.sm),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AuraRadii.card),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AuraRadii.card),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withAlpha(136),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AuraRadii.card),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.4,
                    ),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchChanged,
              ),
              const SizedBox(height: AuraSpacing.lg),
              Flexible(child: _buildSearchBody(context, viewModel)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBody(BuildContext context, WeatherViewModel viewModel) {
    final state = viewModel.uiState;
    final query = _searchController.text.trim();

    if (state.citySearchError != null) {
      return _MessageState(
        icon: Icons.error_outline,
        title: state.citySearchError!,
        subtitle: 'Check the city name or your connection, then try again.',
      );
    }

    if (state.isSearchingCities) {
      return const _MessageState(
        icon: Icons.travel_explore,
        title: 'Searching cities...',
        subtitle: 'Matching your query with backend city results.',
      );
    }

    if (query.isEmpty) {
      return const _MessageState(
        icon: Icons.location_city_outlined,
        title: 'Start with a city name',
        subtitle: 'Try Beijing, London, Mountain View, or your current city.',
      );
    }

    if (state.citySearchResults.isEmpty) {
      return _MessageState(
        icon: Icons.search_off,
        title: 'No cities found',
        subtitle: 'No backend results matched “$query”.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: state.citySearchResults.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AuraSpacing.sm),
      itemBuilder: (context, index) {
        final result = state.citySearchResults[index];
        return _CityResultTile(
          result: result,
          isSelecting: _isSelecting,
          onTap: () => _selectCity(viewModel, result),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}

class _CityResultTile extends StatelessWidget {
  final CitySearchResult result;
  final bool isSelecting;
  final VoidCallback onTap;

  const _CityResultTile({
    required this.result,
    required this.isSelecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isSelecting ? null : onTap,
      borderRadius: BorderRadius.circular(AuraRadii.tile),
      child: WeatherSurfaceCard(
        padding: const EdgeInsets.all(AuraSpacing.md),
        borderRadius: AuraRadii.tile,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AuraRadii.icon),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AuraSpacing.xxs),
                  Text(
                    result.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            if (isSelecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WeatherSurfaceCard(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AuraSpacing.xl,
        vertical: AuraSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: colorScheme.primary),
          const SizedBox(height: AuraSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
