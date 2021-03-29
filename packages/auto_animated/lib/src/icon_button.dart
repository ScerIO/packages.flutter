import 'package:flutter/material.dart';

/// This file was borrowed from https://github.com/Arjunraj-k/auto_animated_icon
/// Arjunraj Kokkadan is also its copyright holder

enum IconState { first, second }

///Creates an AnimatedIcon which is automatically animated.
///
///The [icon] and [onPressed] are required.
///[icon] cannot be null.
///[duration] is the time taken to animate the transition.
class LiveIconButton extends StatefulWidget {
  LiveIconButton({
    required this.icon,
    required this.onPressed,
    Key? key,
    this.duration = const Duration(milliseconds: 300),
    this.splashColor,
    this.hoverColor,
    this.size = 24,
    this.padding = const EdgeInsets.all(18),
    this.alignment = Alignment.center,
    this.color,
    this.focusColor,
    this.highlightColor,
    this.disabledColor,
    this.focusNode,
    this.semanticLabel,
    this.textDirection,
    this.firstTooltip,
    this.secondTooltip,
  })  : iconState = null,
        super(key: key);

  LiveIconButton.externalState({
    required this.icon,
    required this.onPressed,
    required this.iconState,
    Key? key,
    this.duration = const Duration(milliseconds: 300),
    this.splashColor,
    this.hoverColor,
    this.size = 24,
    this.padding = const EdgeInsets.all(18),
    this.alignment = Alignment.center,
    this.color,
    this.focusColor,
    this.highlightColor,
    this.disabledColor,
    this.focusNode,
    this.semanticLabel,
    this.textDirection,
    this.firstTooltip,
    this.secondTooltip,
  }) : super(key: key);

  final AnimatedIconData icon;
  final Function onPressed;
  final Duration duration;
  final Color? splashColor, hoverColor;
  final String? firstTooltip, secondTooltip, semanticLabel;
  final double size;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final Color? color, focusColor, highlightColor, disabledColor;
  final FocusNode? focusNode;
  final TextDirection? textDirection;
  final IconState? iconState;

  @override
  _LiveIconButtonState createState() => _LiveIconButtonState();
}

class _LiveIconButtonState extends State<LiveIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.iconState == IconState.first) {
      _animationController.reverse();
    } else if (widget.iconState == IconState.second) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LiveIconButton oldWidget) {
    if (oldWidget.iconState != widget.iconState) {
      if (oldWidget.iconState == IconState.first &&
          widget.iconState == IconState.second) {
        _animationController.forward();
      } else if (oldWidget.iconState == IconState.second &&
          widget.iconState == IconState.first) {
        _animationController.reverse();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void _onPressed() {
    if (widget.iconState == null) {
      setState(() {
        _isPressed = !_isPressed;
        !_isPressed
            ? _animationController.reverse()
            : _animationController.forward();
      });
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: _onPressed,
        splashColor: widget.splashColor,
        hoverColor: widget.hoverColor,
        tooltip: !_isPressed ? widget.firstTooltip : widget.secondTooltip,
        iconSize: widget.size,
        padding: widget.padding,
        alignment: widget.alignment,
        color: widget.color,
        focusColor: widget.focusColor,
        highlightColor: widget.highlightColor,
        disabledColor: widget.disabledColor,
        focusNode: widget.focusNode,
        icon: AnimatedIcon(
          icon: widget.icon,
          progress: _animationController,
          semanticLabel: widget.semanticLabel,
          textDirection: widget.textDirection,
        ),
      );
}
