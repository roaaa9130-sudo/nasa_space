import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planet_mission.dart';
import '../providers/game_state_provider.dart';

class LandingSiteCard extends ConsumerWidget {
  final LandingSite site;
  final bool isSelected;
  final VoidCallback onSelect;

  const LandingSiteCard({
    super.key,
    required this.site,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final strings = ref.watch(stringsProvider);
    final isAr = state.language.isArabic;
    final isMars = site.planet == PlanetType.mars;
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);

    Color hazardColor = const Color(0xFF10B981);
    if (site.hazardRating > 0.6) {
      hazardColor = const Color(0xFFEF4444);
    } else if (site.hazardRating > 0.35) {
      hazardColor = const Color(0xFFF59E0B);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF0F172A).withValues(alpha: 0.95)
            : const Color(0xFF080F1E).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryColor : const Color(0xFF1E293B),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name & Target Locked Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isAr ? site.nameArabic : site.name,
                      style: TextStyle(
                        color: isSelected ? primaryColor : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: primaryColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.gps_fixed, color: primaryColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            strings.lockTarget,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Coordinates and Elevation Pills
              Row(
                children: [
                  _buildTag(
                    icon: Icons.location_on_outlined,
                    label: site.coordinateString,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    icon: Icons.terrain_outlined,
                    label: '${site.elevationKm > 0 ? '+' : ''}${site.elevationKm.toStringAsFixed(1)} km',
                    color: const Color(0xFF38BDF8),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                isAr ? site.descriptionArabic : site.description,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Hazard Progress Bar
              Row(
                children: [
                  Text(
                    strings.hazardRating,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
                  ),
                  const Spacer(),
                  Text(
                    '${(site.hazardRating * 100).toInt()}%',
                    style: TextStyle(
                      color: hazardColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: site.hazardRating,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation<Color>(hazardColor),
                  minHeight: 4,
                ),
              ),

              const SizedBox(height: 10),

              // Scientific Goals Tags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (isAr ? site.scientificGoalsArabic : site.scientificGoals).map((goal) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '• $goal',
                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10.5, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
