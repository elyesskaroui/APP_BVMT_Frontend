import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Widget réutilisable — Carte de portefeuille avec montant et variation
class PortfolioSummaryCard extends StatelessWidget {
  final String userName;
  final String portfolioAmount;
  final String currency;
  final String changePercent;
  final bool isPositive;
  final List<double> sparklineData;

  const PortfolioSummaryCard({
    super.key,
    required this.userName,
    required this.portfolioAmount,
    this.currency = 'TND',
    required this.changePercent,
    required this.isPositive,
    this.sparklineData = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
      padding: const EdgeInsets.all(AppDimens.paddingLG),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar et nom ──
          Row(
            children: [
              CircleAvatar(
                radius: AppDimens.avatarSM / 2,
                backgroundColor: AppColors.textOnPrimary.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textOnPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimens.paddingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue 👋',
                      style: TextStyle(
                        color: AppColors.textOnPrimaryMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Icône visibilité
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSM),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.textOnPrimary,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.paddingLG),

          // ── Montant du portefeuille ──
          Text(
            'Montant du Portefeuille',
            style: TextStyle(
              color: AppColors.textOnPrimaryMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                portfolioAmount,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  currency,
                  style: TextStyle(
                    color: AppColors.textOnPrimaryMuted,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              // Badge variation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.bullGreen : AppColors.bearRed)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: isPositive
                          ? AppColors.bullGreen
                          : AppColors.bearRed,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      changePercent,
                      style: TextStyle(
                        color: isPositive
                            ? AppColors.bullGreen
                            : AppColors.bearRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.paddingMD),

          // ── Mini Sparkline ──
          if (sparklineData.isNotEmpty)
            SizedBox(
              height: 50,
              child: CustomPaint(
                size: const Size(double.infinity, 50),
                painter: _SparklinePainter(
                  data: sparklineData,
                  isPositive: isPositive,
                ),
              ),
            ),

          const SizedBox(height: AppDimens.paddingSM),

          // ── Mois (axe X) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Jan', 'Mar', 'Mai', 'Jul', 'Sep', 'Nov']
                .map((m) => Text(
                      m,
                      style: TextStyle(
                        color: AppColors.textOnPrimaryMuted,
                        fontSize: 10,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Painter personnalisé pour la mini sparkline dans la carte portfolio
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final bool isPositive;

  _SparklinePainter({required this.data, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = isPositive
          ? AppColors.bullGreen.withValues(alpha: 0.8)
          : AppColors.bearRed.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isPositive ? AppColors.bullGreen : AppColors.bearRed)
              .withValues(alpha: 0.3),
          (isPositive ? AppColors.bullGreen : AppColors.bearRed)
              .withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height -
          ((data[i] - minValue) / (range == 0 ? 1 : range)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
