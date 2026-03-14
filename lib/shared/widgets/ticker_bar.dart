import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Widget réutilisable — Barre de ticker défilant automatiquement (marquee)
class TickerBar extends StatefulWidget {
  final List<TickerItem> items;
  final double speed;

  const TickerBar({
    super.key,
    required this.items,
    this.speed = 50.0, // pixels par seconde
  });

  @override
  State<TickerBar> createState() => _TickerBarState();
}

class _TickerBarState extends State<TickerBar>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _scrollPosition = 0.0;
  double _contentWidth = 0.0;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateContentWidth();
      _startScrolling();
    });
  }

  void _calculateContentWidth() {
    final RenderBox? renderBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _contentWidth = renderBox.size.width;
    }
  }

  void _startScrolling() {
    if (_contentWidth <= 0) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final totalDistance = _contentWidth + screenWidth;
    final duration = Duration(
      milliseconds: (totalDistance / widget.speed * 1000).round(),
    );

    _animationController.duration = duration;
    _animationController.addListener(_onScroll);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scrollPosition = 0.0;
        _scrollController.jumpTo(0);
        _animationController.reset();
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollPosition = _animationController.value * maxScroll;
      _scrollController.jumpTo(_scrollPosition);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Container(
      height: AppDimens.tickerHeight,
      color: AppColors.deepNavy,
      child: ClipRect(
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            key: _contentKey,
            children: [
              // Contenu original
              ...widget.items.map((item) => _buildTickerItem(item)),
              // Duplication pour créer l'effet de boucle continue
              ...widget.items.map((item) => _buildTickerItem(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTickerItem(TickerItem item) {
    final Color changeColor = item.isNeutral
        ? Colors.white70
        : item.isPositive
            ? AppColors.bullGreen
            : AppColors.bearRed;

    return Semantics(
      label: '${item.symbol}: ${item.price}, variation ${item.change}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.symbol,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              item.price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${item.change})',
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modèle de données pour un élément du ticker
class TickerItem {
  final String symbol;
  final String price;
  final String change;
  final bool isPositive;
  final bool isNeutral;

  const TickerItem({
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
    this.isNeutral = false,
  });
}
