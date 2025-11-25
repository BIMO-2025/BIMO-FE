import 'package:flutter/material.dart';
import '../../domain/models/airport.dart';

class AirportItem extends StatelessWidget {
  final Airport airport;
  final VoidCallback onTap;

  const AirportItem({
    super.key,
    required this.airport,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City name with location icon
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  airport.cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Airport code and location type
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                '${airport.airportCode} · ${airport.locationType}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Airport name with airplane icon
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Row(
                children: [
                  Icon(
                    Icons.flight,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      airport.airportName,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Airport code again
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Text(
                '${airport.airportCode} · 공항',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
