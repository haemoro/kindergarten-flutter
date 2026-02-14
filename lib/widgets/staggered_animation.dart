import 'package:flutter/material.dart';

class StaggeredListItem extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const StaggeredListItem({
    super.key,
    required this.animation,
    required this.child,
  });

  static Animation<double> createAnimation({
    required AnimationController controller,
    required int index,
    required int totalCount,
  }) {
    final begin = index / totalCount * 0.3;
    final end = begin + 0.7;
    
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: this.child,
          ),
        );
      },
    );
  }
}