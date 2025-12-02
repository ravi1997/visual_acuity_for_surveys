import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ScrollableCenteredSvg extends StatefulWidget {
  final Size svgSize;
  final double rotation;

  const ScrollableCenteredSvg({
    super.key,
    required this.svgSize,
    required this.rotation,
  });

  @override
  State<ScrollableCenteredSvg> createState() => _ScrollableCenteredSvgState();
}

class _ScrollableCenteredSvgState extends State<ScrollableCenteredSvg> {
  final _hController = ScrollController();
  final _vController = ScrollController();
  bool _didCenter = false;

  @override
  void dispose() {
    _hController.dispose();
    _vController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = constraints.maxHeight;
        final contentWidth = widget.svgSize.width;
        final contentHeight = widget.svgSize.height;

        // Center only once, after first layout
        if (!_didCenter) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final targetX = (contentWidth - viewportWidth) > 0
                ? (contentWidth - viewportWidth) / 2
                : 0.0;
            final targetY = (contentHeight - viewportHeight) > 0
                ? (contentHeight - viewportHeight) / 2
                : 0.0;

            if (_hController.hasClients) {
              _hController.jumpTo(targetX);
            }
            if (_vController.hasClients) {
              _vController.jumpTo(targetY);
            }
          });
          _didCenter = true;
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: ClipRect(
            child: SingleChildScrollView(
              controller: _hController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SingleChildScrollView(
                controller: _vController,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: contentWidth,
                  height: contentHeight,
                  child: Center(
                    child: Transform.rotate(
                      angle: widget.rotation,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/images/tests/e_optotype.svg',
                        width: contentWidth,
                        height: contentHeight,
                        fit: BoxFit.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
