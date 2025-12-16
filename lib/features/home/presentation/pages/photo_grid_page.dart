import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/review_model.dart';
import '../../../../core/utils/image_utils.dart'; // ImageUtils import
import 'review_detail_page.dart';
// import '../widgets/review_card.dart'; // 더 이상 사용 안 함

import '../../../../core/theme/app_text_styles.dart';

class PhotoGridPage extends StatelessWidget {
  final List<Review> reviews;

  const PhotoGridPage({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    // 모든 사진 추출 및 매핑 (사진 -> 리뷰)
    final List<Map<String, dynamic>> allPhotos = [];
    for (var review in reviews) {
      for (var image in review.images) {
        allPhotos.add({
          'image': image,
          'review': review,
        });
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
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
          '사진 모아보기',
          style: AppTextStyles.large.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: allPhotos.isEmpty
          ? Center(
              child: Text(
                '사진이 없습니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.fs(16),
                ),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(context.w(2)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: context.w(2),
                mainAxisSpacing: context.w(2),
                childAspectRatio: 1.0,
              ),
              itemCount: allPhotos.length,
              itemBuilder: (context, index) {
                final photoData = allPhotos[index];
                final imagePath = photoData['image'] as String;
                final review = photoData['review'] as Review;

                return GestureDetector(
                  onTap: () {
                    // 사진 클릭 시 리뷰 상세 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewDetailPage(review: review),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero, // 그리드이므로 둥근 모서리 없음 (필요시 추가)
                    child: _buildReviewImage(imagePath),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildReviewImage(String imagePath) {
    return ImageUtils.buildImage(imagePath);
  }
}
