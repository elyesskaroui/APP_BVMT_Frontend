import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../home/domain/entities/portfolio_entity.dart';

/// Widget — Carte résumé du portefeuille en haut de page
class PortfolioHeaderCard extends StatelessWidget {
  final PortfolioEntity summary;

  const PortfolioHeaderCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimens.paddingMD),
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
          const Text(
            'Valeur Totale',
            style: TextStyle(
              color: AppColors.textOnPrimaryMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                summary.formattedValue,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 34,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  summary.currency,
                  style: const TextStyle(
                    color: AppColors.textOnPrimaryMuted,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: (summary.isPositive ? AppColors.bullGreen : AppColors.bearRed)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      summary.isPositive ? Icons.trending_up : Icons.trending_down,
                      color: summary.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      summary.formattedChange,
                      style: TextStyle(
                        color: summary.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Ce mois',
                style: TextStyle(
                  color: AppColors.textOnPrimaryMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // ── Mini Sparkline ──
          if (summary.sparklineData.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: CustomPaint(
                size: const Size(double.infinity, 50),
                painter: _PortfolioSparklinePainter(
                  data: summary.sparklineData,
                  isPositive: summary.isPositive,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PortfolioSparklinePainter extends CustomPainter {
  final List<double> data;
  final bool isPositive;

  _PortfolioSparklinePainter({required this.data, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = (isPositive ? AppColors.bullGreen : AppColors.bearRed)
          .withValues(alpha: 0.8)
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

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y =
          size.height - ((data[i] - minVal) / (range == 0 ? 1 : range)) * size.height;

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
