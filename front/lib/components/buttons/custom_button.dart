import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.enabled = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    _controller.forward();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) async {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    if (!_controller.isCompleted) {
      await _controller.forward();
    }
    await _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() async {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    if (!_controller.isCompleted) {
      await _controller.forward();
    }
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            gradient: widget.enabled
                ? LinearGradient(
                    colors: _isPressed
                        ? [
                            const Color.fromRGBO(0, 204, 153, 0.5),
                            const Color.fromRGBO(0, 204, 153, 0.3),
                          ]
                        : [
                            const Color.fromRGBO(0, 204, 153, 0.9),
                            const Color.fromRGBO(0, 204, 153, 0.7),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey[400]!, Colors.grey[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color:
                          const Color.fromRGBO(0, 204, 153, 1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.enabled ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
