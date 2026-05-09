import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_view_model.dart';
import '../viewmodels/theme_mode_controller.dart';
import '../models/weather_now.dart';
import '../models/weather_daily.dart';
import 'hourly_forecast_card.dart';
import 'daily_forecast_card.dart';
import 'details_grid.dart';
import 'aqi_section.dart';
import 'location_bottom_sheet.dart';
import 'weather_effects.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.uiState;

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => viewModel.loadWeatherData(),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          return WeatherAtmosphere(
            weather: state.weatherNow,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(
                  context,
                  state.location?.cityName ?? "Unknown Location",
                  state.weatherNow,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuraSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AuraSpacing.xxl),
                        if (state.weatherNow != null &&
                            state.dailyForecast.isNotEmpty)
                          _buildHeroSection(
                            context,
                            state.weatherNow!,
                            state.dailyForecast.first,
                          ),
                        const SizedBox(height: AuraSpacing.xxl),
                        HourlyForecastCard(hourlyData: state.hourlyForecast),
                        const SizedBox(height: AuraSpacing.xxl),
                        DailyForecastCard(dailyData: state.dailyForecast),
                        const SizedBox(height: AuraSpacing.xxl),
                        if (state.weatherNow != null &&
                            state.dailyForecast.isNotEmpty)
                          DetailsStaggeredGrid(
                            weather: state.weatherNow!,
                            todayForecast: state.dailyForecast.first,
                          ),
                        const SizedBox(height: AuraSpacing.xxl),
                        AqiSection(aqiNow: state.aqiNow),
                        const SizedBox(height: AuraSpacing.bottomSafe),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    String cityName,
    WeatherNow? weather,
  ) {
    final appBarColor = WeatherAtmosphere.appBarColor(context, weather);

    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: appBarColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _showThemeSheet(context),
      ),
      title: Text(
        cityName,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on_outlined),
          onPressed: () {
            final viewModel = context.read<WeatherViewModel>();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => ChangeNotifierProvider.value(
                value: viewModel,
                child: const LocationBottomSheet(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showThemeSheet(BuildContext context) {
    final themeModeController = context.read<ThemeModeController>();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: themeModeController,
        child: const _ThemeModeBottomSheet(),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    WeatherNow now,
    DailyForecast today,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: AuraMotion.crossFade,
      switchInCurve: AuraMotion.expressive,
      switchOutCurve: AuraMotion.expressive,
      child: SizedBox(
        key: ValueKey(
          '${now.icon}-${now.temp}-${today.tempMax}-${today.tempMin}',
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${now.temp}°',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 160,
                fontWeight: FontWeight.w300,
                letterSpacing: -2,
                height: 1.0,
                color: colorScheme.onSurface,
                shadows: [
                  Shadow(
                    color: colorScheme.shadow.withAlpha(32),
                    offset: const Offset(0, 14),
                    blurRadius: 36,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuraSpacing.xs),
            Text(
              'Feels like ${now.feelsLike}°',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuraSpacing.xxs),
            Text(
              'High ${today.tempMax}° · Low ${today.tempMin}°',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeBottomSheet extends StatelessWidget {
  const _ThemeModeBottomSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.md,
        AuraSpacing.sm,
        AuraSpacing.md,
        AuraSpacing.xl,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: AuraSpacing.lg * 2,
              height: AuraSpacing.xxs,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(102),
                borderRadius: BorderRadius.circular(AuraRadii.full),
              ),
            ),
          ),
          const SizedBox(height: AuraSpacing.lg),
          Row(
            children: [
              Container(
                width: AuraSpacing.xxl + AuraSpacing.sm,
                height: AuraSpacing.xxl + AuraSpacing.sm,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AuraRadii.icon),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: AuraSpacing.xl,
                ),
              ),
              const SizedBox(width: AuraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AuraSpacing.xxs),
                    Text(
                      'Match your device, or keep Aura bright or moonlit.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.lg),
          Consumer<ThemeModeController>(
            builder: (context, controller, child) {
              return SegmentedButton<ThemeMode>(
                selected: {controller.themeMode},
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.comfortable,
                  side: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    return BorderSide(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    );
                  }),
                ),
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.devices_outlined),
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark'),
                  ),
                ],
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  unawaited(controller.setThemeMode(selection.first));
                },
              );
            },
          ),
          const SizedBox(height: AuraSpacing.md),
          Text(
            'Your choice is saved on this device.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
