import 'package:flutter/material.dart';
import '../models/indices.dart';

class AqiAndIndicesSection extends StatelessWidget {
  final AqiNow? aqiNow;
  final List<IndexInfo> indices;

  const AqiAndIndicesSection({super.key, this.aqiNow, required this.indices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (aqiNow != null) ...[
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
        if (indices.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Life Indices",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          _buildIndicesList(context),
        ],
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

  Widget _buildIndicesList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: indices.length,
        separatorBuilder: (context, index) => Divider(
          color: Theme.of(context).colorScheme.outlineVariant,
          height: 1,
          indent: 56,
        ),
        itemBuilder: (context, index) {
          final info = indices[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _getIconForIndexType(info.type),
            title: Row(
              children: [
                Text(info.name, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    info.category,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(info.text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          );
        },
      ),
    );
  }

  Icon _getIconForIndexType(String type) {
    switch (type.toLowerCase()) {
      case 'dressing':
        return const Icon(Icons.checkroom);
      case 'uv':
        return const Icon(Icons.wb_sunny_outlined);
      case 'sports':
        return const Icon(Icons.directions_run);
      default:
        return const Icon(Icons.info_outline);
    }
  }
}
