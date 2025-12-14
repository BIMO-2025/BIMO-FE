import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/airline.dart';
import 'airline_review_page.dart';

class AirlineDetailPage extends StatelessWidget {
  final Airline airline;

  const AirlineDetailPage({
    super.key,
    required this.airline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: context.w(60),
        leading: Padding(
          padding: EdgeInsets.only(left: context.w(20)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: context.w(40),
              height: context.h(40),
              child: Image.asset(
                'assets/images/search/back_arrow_icon.png',
                width: context.w(40),
                height: context.h(40),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: Text(
          airline.name,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: context.fs(17),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.h(24)),
            // 1. Airline Image
            Container(
              width: double.infinity,
              height: context.h(110),
              margin: EdgeInsets.symmetric(horizontal: context.w(20)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.w(16)),
                image: DecorationImage(
                  image: AssetImage(airline.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            SizedBox(height: context.h(20)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Tags
                  Row(
                    children: airline.tags.map((tag) {
                      final isSkyTeam = tag == 'SkyTeam';
                      final isFSC = tag == 'FSC';
                      Color bgColor = const Color(0xFF333333);
                      Color textColor = Colors.white;

                      if (isFSC) {
                        bgColor = const Color(0xFF0080FF); // Blue1
                      }

                      return Container(
                        margin: EdgeInsets.only(right: context.w(6)),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(10),
                          vertical: context.h(6),
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(context.w(8)),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(12),
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: context.h(12)),

                  // 3. Airline Name
                  Text(
                    airline.name,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(24),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    airline.englishName,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(14),
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: context.h(12)),

                  // 4. Rating Row
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AirlineReviewPage(airline: airline),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: context.w(16)),
                        SizedBox(width: context.w(4)),
                        Text(
                          '${airline.rating}',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(13),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '/5.0',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(13),
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(width: context.w(8)),
                        Text(
                          '(${_formatNumber(airline.reviewCount)})',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(14),
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white, size: context.w(20)),
                      ],
                    ),
                  ),

                  SizedBox(height: context.h(24)),

                  // 5. Detail Ratings
                  _buildDetailRatingRow(context, '좌석 편안함', airline.detailRating.seatComfort),
                  _buildDetailRatingRow(context, '기내식 및 음료', airline.detailRating.foodAndBeverage),
                  _buildDetailRatingRow(context, '서비스', airline.detailRating.service),
                  _buildDetailRatingRow(context, '청결도', airline.detailRating.cleanliness),
                  _buildDetailRatingRow(context, '시간 준수도 및 수속', airline.detailRating.punctuality),

                  SizedBox(height: context.h(32)),

                  // 6. BIMO Summary
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff, color: Colors.white, size: context.w(20)), // Placeholder icon
                      SizedBox(width: context.w(8)),
                      Text(
                        'BIMO 요약',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(17),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: context.w(8)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(4)),
                        decoration: BoxDecoration(
                          color: AppColors.yellow1,
                          borderRadius: BorderRadius.circular(context.w(8)),
                        ),
                        child: Text(
                          'AI 리뷰 분석',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(11),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(12)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.w(20)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(context.w(16)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(15),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: context.h(12)),
                              ...airline.reviewSummary.goodPoints.map((point) => Padding(
                                padding: EdgeInsets.only(bottom: context.h(4)),
                                child: Text(
                                  point,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: context.fs(13),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFCCCCCC),
                                    height: 1.4,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                        SizedBox(width: context.w(20)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bad',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(15),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: context.h(12)),
                              ...airline.reviewSummary.badPoints.map((point) => Padding(
                                padding: EdgeInsets.only(bottom: context.h(4)),
                                child: Text(
                                  point,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: context.fs(13),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFCCCCCC),
                                    height: 1.4,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.h(32)),

                  // 7. Basic Info
                  Text(
                    '기본 정보',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(17),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.h(12)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.w(20)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(context.w(16)),
                    ),
                    child: Column(
                      children: [
                        _buildBasicInfoRow(context, '본사 위치', airline.basicInfo.headquarters),
                        SizedBox(height: context.h(12)),
                        _buildBasicInfoRow(context, '허브 공항', airline.basicInfo.hubAirport),
                        SizedBox(height: context.h(12)),
                        _buildBasicInfoRow(context, '항공 동맹', airline.basicInfo.alliance),
                        SizedBox(height: context.h(12)),
                        _buildBasicInfoRow(context, '운항 클래스', airline.basicInfo.classes),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: context.h(40)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRatingRow(BuildContext context, String label, double rating) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(12)),
      child: Row(
        children: [
          SizedBox(
            width: context.w(120),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: context.fs(14),
                fontWeight: FontWeight.w400,
                color: const Color(0xFFCCCCCC),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: context.h(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(context.w(3)),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: rating / 5.0,
                  child: Container(
                    height: context.h(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(context.w(3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.w(12)),
          SizedBox(
            width: context.w(30),
            child: Text(
              rating.toStringAsFixed(1),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: context.fs(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.w(80),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(14),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(14),
              fontWeight: FontWeight.w400,
              color: const Color(0xFFCCCCCC),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
