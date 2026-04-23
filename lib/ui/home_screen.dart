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
                        if (state.weatherNow != null)
                          DetailsStaggeredGrid(weather: state.weatherNow!),
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
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: Colors.transparent,
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
    return Column(
      children: [
        Text(
          '\${now.temp}°',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 96,
            fontWeight: FontWeight.w400,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Feels like \${now.feelsLike}°',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'High \${today.tempMax}° · Low \${today.tempMin}°',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
