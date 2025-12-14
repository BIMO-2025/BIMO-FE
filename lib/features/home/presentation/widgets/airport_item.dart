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
            // 도시 이름 (도시 코드)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  airport.cityCode.isNotEmpty
                      ? '${airport.cityName} (${airport.cityCode})'
                      : airport.cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 공항 이름 (수평 스크롤 가능)
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        airport.airportName,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // 공항 코드
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
