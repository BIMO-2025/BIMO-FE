import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_text_styles.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: _buildContentByContent(),
      ),
    );
  }

  Widget _buildContentByContent() {
    switch (airport.type) {
      case SearchResultType.COUNTRY:
        return Text(
          airport.cityName, // 국가명
          style: AppTextStyles.bigBody.copyWith(
            color: Colors.white,
          ),
        );
      
      case SearchResultType.CITY:
        return Row(
          children: [
            // City: Indent + Location Icon
             SvgPicture.asset(
              'assets/images/myflight/location.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              airport.cityName, // 도시명
              style: AppTextStyles.body.copyWith(
                 color: Colors.white,
                 fontWeight: FontWeight.w600, // Cities often clearer if slightly bolder than airport list, but user said body. 
                                              // bigBody=SemiBold, Body=Regular.
                                              // To distinguish City header from Airport item, maybe keep SemiBold or standard Body?
                                              // User said "지역은 body". I'll use body.
              ),
            ),
            if (airport.cityCode.isNotEmpty)
              Text(
                ' (${airport.cityCode})',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[400],
                ),
              ),
          ],
        );

      case SearchResultType.AIRPORT:
      default:
        // Airport: Indent + L Icon + Plane Icon
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            const SizedBox(width: 6), 
            
            // L-shaped connector
            SvgPicture.asset(
              'assets/images/myflight/L icon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            
            // Plane Icon
            Image.asset(
              'assets/images/myflight/airport.png',
               width: 18,
               height: 18,
            ),
             const SizedBox(width: 8),
             
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    airport.airportName, // 공항명
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                   // Code • Airport (Small Body)
                  Text(
                     airport.airportCode.isNotEmpty 
                        ? '${airport.airportCode} · 공항' 
                        : '공항',
                    style: AppTextStyles.smallBody.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
