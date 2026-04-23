import 'package:flutter/material.dart';
import '../models/indices.dart';

class AqiSection extends StatelessWidget {
  final AqiNow? aqiNow;

  const AqiSection({super.key, this.aqiNow});

  @override
  Widget build(BuildContext context) {
    if (aqiNow == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Air Quality",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        _buildAqiCard(context, aqiNow!),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAqiCard(BuildContext context, AqiNow aqi) {
    Color getAqiColor(int aqiValue) {
      if (aqiValue <= 50) return Colors.green;
      if (aqiValue <= 100) return Colors.yellow.shade700;
      if (aqiValue <= 150) return Colors.orange;
      if (aqiValue <= 200) return Colors.red;
      return Colors.purple;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, size: 20),
              const SizedBox(width: 8),
              Text("AQI Now", style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${aqi.aqi}",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: getAqiColor(aqi.aqi).withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: getAqiColor(aqi.aqi),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      aqi.category,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: getAqiColor(aqi.aqi),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
