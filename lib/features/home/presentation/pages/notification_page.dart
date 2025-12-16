import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/notification_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '알림',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: context.fs(18),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: NotificationService().notifications,
        builder: (context, notifications, child) {
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return ListView.separated(
            padding: EdgeInsets.all(context.w(20)),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => SizedBox(height: context.h(16)),
            itemBuilder: (context, index) {
              return _buildNotificationItem(context, notifications[index], index);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: context.w(48),
            color: const Color(0xFF555555),
          ),
          SizedBox(height: context.h(16)),
          Text(
            '새로운 알림이 없습니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(16),
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem item, int index) {
    return GestureDetector(
      onTap: () {
        // 알림 클릭 시 읽음 처리
        NotificationService().markAsRead(index);
      },
      child: Container(
        padding: EdgeInsets.all(context.w(16)),
        decoration: BoxDecoration(
          color: item.isRead ? const Color(0xFF1A1A1A) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(context.w(12)),
          border: Border.all(
            color: item.isRead ? Colors.transparent : AppColors.yellow1.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              padding: EdgeInsets.all(context.w(8)),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              child: item.assetIcon != null
                  ? Image.asset(
                      item.assetIcon!,
                      width: context.w(20),
                      height: context.w(20),
                      color: item.isRead ? const Color(0xFF8E8E93) : AppColors.yellow1,
                    )
                  : Icon(
                      item.icon,
                      size: context.w(20),
                      color: item.isRead ? const Color(0xFF8E8E93) : AppColors.yellow1,
                    ),
            ),
            SizedBox(width: context.w(12)),
            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(12),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFCCCCCC),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
