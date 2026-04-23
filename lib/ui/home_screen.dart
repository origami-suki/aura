import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_view_model.dart';
import '../models/weather_now.dart';
import '../models/weather_daily.dart';
import 'hourly_forecast_card.dart';
import 'daily_forecast_card.dart';
import 'details_grid.dart';
import 'aqi_indices_section.dart';
import 'location_bottom_sheet.dart';

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
            return Center(child: Text(state.errorMessage!));
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(128),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, state.location?.cityName ?? "Unknown Location"),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        if (state.weatherNow != null && state.dailyForecast.isNotEmpty)
                          _buildHeroSection(context, state.weatherNow!, state.dailyForecast.first),
                        const SizedBox(height: 32),
                        HourlyForecastCard(hourlyData: state.hourlyForecast),
                        const SizedBox(height: 32),
                        DailyForecastCard(dailyData: state.dailyForecast),
                        const SizedBox(height: 32),
                        if (state.weatherNow != null && state.dailyForecast.isNotEmpty)
                          DetailsStaggeredGrid(
                            weather: state.weatherNow!,
                            todayForecast: state.dailyForecast.first,
                          ),
                        const SizedBox(height: 32),
                        AqiAndIndicesSection(
                          aqiNow: state.aqiNow,
                          indices: state.indices,
                        ),
                        const SizedBox(height: 100), // Bottom padding
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

  SliverAppBar _buildAppBar(BuildContext context, String cityName) {
    // When the app bar is scrolled under, give it a solid color that matches the top of the gradient background
    // We blend the primary container color with the surface color to match the Container's gradient start.
    final appBarColor = Color.alphaBlend(
      Theme.of(context).colorScheme.primaryContainer.withAlpha(128),
      Theme.of(context).colorScheme.surface,
    );

    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: appBarColor,
      surfaceTintColor: Colors.transparent, // Prevent material 3 scroll under tint
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {},
      ),
      title: Text(
        cityName,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on_outlined),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => const LocationBottomSheet(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, WeatherNow now, DailyForecast today) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${now.temp}°',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 160,
              fontWeight: FontWeight.w400,
              letterSpacing: -2,
              height: 1.0, // Reduce line height so it doesn't take too much vertical space
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Feels like ${now.feelsLike}°',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'High ${today.tempMax}° · Low ${today.tempMin}°',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
