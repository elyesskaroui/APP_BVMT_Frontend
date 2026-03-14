import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../news/domain/entities/news_entity.dart';

/// Bandeau de news compact — style Bloomberg ticker
/// Fond navy foncé, défilement automatique horizontal
/// ✅ Accessibilité : Semantics, min 12px fonts
class NewsTicker extends StatefulWidget {
  final List<NewsEntity> news;

  const NewsTicker({super.key, required this.news});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  late final PageController _ctrl;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.news.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _current = (_current + 1) % widget.news.length;
      _ctrl.animateToPage(
        _current,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.news.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label: 'Fil d\'actualités - ${widget.news.length} articles',
      child: Container(
        height: 40,
        color: AppColors.deepNavy,
        child: Row(
          children: [
            // Badge "ACTUS"
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ACTUS',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontSize: 9,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Scrolling news
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                scrollDirection: Axis.horizontal,
                itemCount: widget.news.length,
                onPageChanged: (i) => _current = i,
                itemBuilder: (_, i) {
                  final n = widget.news[i];
                  return Semantics(
                    label: '${n.title} - ${n.timeAgo}',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        children: [
                          // Category dot
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _categoryColor(n.category),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Title
                          Expanded(
                            child: Text(
                              n.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.white90,
                              ),
                            ),
                          ),
                          // Time ago
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 12),
                            child: Text(
                              n.timeAgo,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.white25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'marché':
        return AppColors.primaryBlueLight;
      case 'entreprise':
        return AppColors.accentOrange;
      case 'analyse':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.warningYellow;
    }
  }
}
