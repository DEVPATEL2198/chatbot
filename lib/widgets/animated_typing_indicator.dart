import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedTypingIndicator extends StatefulWidget {
  const AnimatedTypingIndicator({super.key});

  @override
  State<AnimatedTypingIndicator> createState() =>
      _AnimatedTypingIndicatorState();
}

class _AnimatedTypingIndicatorState extends State<AnimatedTypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: AppTheme.mediumSpacing, bottom: AppTheme.smallSpacing),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.mediumSpacing,
        vertical: AppTheme.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: AppTheme.botBubbleColor,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.botBubbleBorder, width: 1),
        boxShadow: const [AppTheme.bubbleShadow],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.smart_toy_outlined,
            size: 16,
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(width: AppTheme.smallSpacing),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final animationValue =
                      (_animation.value - delay).clamp(0.0, 1.0);
                  final scale = 0.5 +
                      (0.5 *
                          (1 - (animationValue - 0.5).abs() * 2)
                              .clamp(0.0, 1.0));

                  return Container(
                    margin: EdgeInsets.only(
                      right: index < 2 ? 4 : 0,
                    ),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.secondaryTextColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StreamingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const StreamingTextWidget({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 50),
  });

  @override
  State<StreamingTextWidget> createState() => _StreamingTextWidgetState();
}

class _StreamingTextWidgetState extends State<StreamingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 30),
      vsync: this,
    );
    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final text = widget.text.substring(0, _characterCount.value);
        return Text(
          text,
          style: widget.style,
        );
      },
    );
  }
}
