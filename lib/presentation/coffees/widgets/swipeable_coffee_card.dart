import 'dart:math';
import 'package:flutter/material.dart';
import '../../../domain/entities/coffee.dart';

class SwipeableCoffeeCard extends StatefulWidget {
  final Coffee coffee;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool isTopCard;

  const SwipeableCoffeeCard({
    super.key,
    required this.coffee,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.isTopCard = false,
  });

  @override
  State<SwipeableCoffeeCard> createState() => _SwipeableCoffeeCardState();
}

class _SwipeableCoffeeCardState extends State<SwipeableCoffeeCard>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.4;

    if (_position.dx.abs() > threshold) {
      // Swipe detected
      final endPosition = Offset(
        _position.dx > 0 ? screenWidth * 2 : -screenWidth * 2,
        _position.dy,
      );

      _animation = Tween<Offset>(
        begin: _position,
        end: endPosition,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      );

      _animationController.forward().then((_) {
        if (_position.dx > 0) {
          widget.onSwipeRight();
        } else {
          widget.onSwipeLeft();
        }
        _resetPosition();
      });
    } else {
      // Return to center
      _animation = Tween<Offset>(
        begin: _position,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
      );

      _animationController.forward().then((_) {
        _resetPosition();
      });
    }
  }

  void _resetPosition() {
    setState(() {
      _position = Offset.zero;
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final angle = _position.dx / screenSize.width * 0.4;
    final swipeProgress = (_position.dx.abs() / screenSize.width).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final currentPosition =
            _animationController.isAnimating ? _animation.value : _position;

        return Transform.translate(
          offset: currentPosition,
          child: Transform.rotate(
            angle: angle,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onPanStart: widget.isTopCard ? _onPanStart : null,
        onPanUpdate: widget.isTopCard ? _onPanUpdate : null,
        onPanEnd: widget.isTopCard ? _onPanEnd : null,
        child: Stack(
          children: [
            // Main card
            Container(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Coffee image
                    Image.network(
                      widget.coffee.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                        );
                      },
                    ),
                    // Swipe indicators
                    if (_isDragging && swipeProgress > 0.1)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _position.dx > 0
                                  ? [
                                      Colors.amber.withOpacity(swipeProgress * 0.5),
                                      Colors.transparent,
                                    ]
                                  : [
                                      Colors.red.withOpacity(swipeProgress * 0.5),
                                      Colors.transparent,
                                    ],
                              begin: _position.dx > 0
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              end: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    if (_isDragging && swipeProgress > 0.1)
                      Positioned(
                        top: 40,
                        left: _position.dx > 0 ? 40 : null,
                        right: _position.dx > 0 ? null : 40,
                        child: Transform.rotate(
                          angle: _position.dx > 0 ? -0.3 : 0.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _position.dx > 0
                                    ? Colors.amber
                                    : Colors.red,
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _position.dx > 0 ? 'FAVORITE' : 'SKIP',
                              style: TextStyle(
                                color: _position.dx > 0
                                    ? Colors.amber
                                    : Colors.red,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
