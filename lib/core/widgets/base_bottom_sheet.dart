import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/responsive_extensions.dart';

class BaseBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBackTap;

  const BaseBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1), // FFFFFF 10%
            offset: const Offset(0, -1), // X: 0, Y: -1
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.w(24)),
          topRight: Radius.circular(context.w(24)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            width: context.w(375),
            height: context.h(750),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.w(24)),
                topRight: Radius.circular(context.w(24)),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  width: context.w(375),
                  height: context.h(82),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                  ),
                  child: Stack(
                    children: [
                      // Content
                      Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(19), // Large style
                            fontWeight: FontWeight.w700, // Bold
                            height: 1.2, // 120%
                            letterSpacing: -context.fs(0.38), // -2% of 19
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      // Back button
                      Positioned(
                        left: context.w(20),
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: onBackTap ?? () => Navigator.pop(context),
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
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
