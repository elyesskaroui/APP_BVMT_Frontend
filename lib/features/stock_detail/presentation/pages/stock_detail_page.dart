import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../home/domain/entities/stock_entity.dart';
import '../../../order/presentation/pages/order_page.dart';
import '../bloc/stock_detail_bloc.dart';
import '../bloc/stock_detail_event.dart';
import '../bloc/stock_detail_state.dart';

/// Page détail d'une action — graphique FL Chart + infos complètes
class StockDetailPage extends StatefulWidget {
  final String symbol;

  const StockDetailPage({super.key, required this.symbol});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  String get symbol => widget.symbol;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockDetailBloc, StockDetailState>(
      builder: (context, state) {
        if (state is StockDetailLoading) {
          return _buildLoading();
        }
        if (state is StockDetailLoaded) {
          return _buildLoaded(context, state);
        }
        if (state is StockDetailError) {
          return _buildError(context, state.message);
        }
        return _buildLoading();
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(symbol),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, StockDetailLoaded state) {
    final stock = state.stock;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stock.symbol,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            Text(stock.companyName,
                style: TextStyle(
                    fontSize: 12, color: AppColors.textOnPrimaryMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: AppColors.textOnPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textOnPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Prix principal ──
            _buildPriceHeader(stock),

            // ── Graphique ──
            _buildChart(state),

            // ── Périodes ──
            _buildPeriodSelector(context, state.selectedPeriod),

            // ── Détails ──
            _buildDetailsCard(stock),

            // ── Boutons Acheter / Vendre ──
            _buildActionButtons(context, stock),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceHeader(StockEntity stock) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingLG),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stock.formattedPrice} TND',
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (stock.isPositive ? AppColors.bullGreen : AppColors.bearRed)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stock.isPositive ? Icons.trending_up : Icons.trending_down,
                      color: stock.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stock.formattedChange,
                      style: TextStyle(
                        color: stock.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dernière mise à jour aujourd\'hui',
            style: TextStyle(
              color: AppColors.textOnPrimaryMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(StockDetailLoaded state) {
    final data = state.chartData;
    final isPositive = state.stock.isPositive;
    final color = isPositive ? AppColors.bullGreen : AppColors.bearRed;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      margin: const EdgeInsets.all(AppDimens.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Flash animator overlay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _flashController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _CurveFlashPainter(
                      data: data,
                      progress: _flashController.value,
                      color: color,
                      leftPadding: 50,
                      topPadding: 0,
                      bottomPadding: 0,
                      rightPadding: 0,
                    ),
                  );
                },
              ),
            ),
          ),
          // Main chart
          LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getInterval(data),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.divider.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((s) => LineTooltipItem(
                      s.y.toStringAsFixed(2),
                      TextStyle(color: color, fontWeight: FontWeight.w700),
                    )).toList();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getInterval(List<double> data) {
    if (data.isEmpty) return 1;
    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    final range = max - min;
    if (range == 0) return 1;
    return range / 4;
  }

  Widget _buildPeriodSelector(BuildContext context, String selected) {
    final periods = ['1J', '1S', '1M', '3M', '6M', '1A'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: periods.map((p) {
          final isActive = p == selected;
          return GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
              ),
              child: Text(
                p,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailsCard(StockEntity stock) {
    return Container(
      margin: const EdgeInsets.all(AppDimens.paddingMD),
      padding: const EdgeInsets.all(AppDimens.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow('Ouverture', '${stock.openPrice > 0 ? stock.openPrice.toStringAsFixed(2) : stock.lastPrice.toStringAsFixed(2)} TND'),
          _detailRow('Plus haut', '${stock.highPrice > 0 ? stock.highPrice.toStringAsFixed(2) : (stock.lastPrice * 1.02).toStringAsFixed(2)} TND'),
          _detailRow('Plus bas', '${stock.lowPrice > 0 ? stock.lowPrice.toStringAsFixed(2) : (stock.lastPrice * 0.98).toStringAsFixed(2)} TND'),
          _detailRow('Clôture préc.', '${stock.closePrice > 0 ? stock.closePrice.toStringAsFixed(2) : (stock.lastPrice * 0.99).toStringAsFixed(2)} TND'),
          _detailRow('Volume', _formatVolume(stock.volume)),
          _detailRow('Variation', stock.formattedChange, valueColor: stock.isPositive ? AppColors.bullGreen : AppColors.bearRed),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? AppColors.textPrimary,
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, StockEntity stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => OrderPage(
                    symbol: symbol,
                    currentPrice: stock.lastPrice,
                    orderType: 'buy',
                  ),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bullGreen,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                ),
              ),
              child: const Text('Acheter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => OrderPage(
                    symbol: symbol,
                    currentPrice: stock.lastPrice,
                    orderType: 'sell',
                  ),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bearRed,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                ),
              ),
              child: const Text('Vendre', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000) return '${(volume / 1000000).toStringAsFixed(1)}M';
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}K';
    return volume.toString();
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(symbol),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.bearRed, size: 64),
              const SizedBox(height: AppDimens.paddingMD),
              Text(message, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: AppDimens.paddingLG),
              ElevatedButton(
                onPressed: () {
                  context.read<StockDetailBloc>().add(StockDetailLoadRequested(symbol));
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// _CurveFlashPainter — Premium comet with trail & sparkles
// ══════════════════════════════════════════════════════════════════
class _CurveFlashPainter extends CustomPainter {
  final List<double> data;
  final double progress; // 0.0 → 1.0
  final Color color;
  final double leftPadding;
  final double topPadding;
  final double bottomPadding;
  final double rightPadding;

  _CurveFlashPainter({
    required this.data,
    required this.progress,
    required this.color,
    this.leftPadding = 50,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.rightPadding = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final minY = data.reduce(math.min) * 0.998;
    final maxY = data.reduce(math.max) * 1.002;
    final rangeY = maxY - minY;
    if (rangeY <= 0) return;

    // Build points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + (i / (data.length - 1)) * chartWidth;
      final y = topPadding + (1 - (data[i] - minY) / rangeY) * chartHeight;
      points.add(Offset(x, y));
    }

    // Build smooth cubic bezier path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];
      const smoothness = 0.3;
      final cp1x = p1.dx + (p2.dx - p0.dx) * smoothness;
      final cp1y = p1.dy + (p2.dy - p0.dy) * smoothness;
      final cp2x = p2.dx - (p3.dx - p1.dx) * smoothness;
      final cp2y = p2.dy - (p3.dy - p1.dy) * smoothness;
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;
    final metric = pathMetrics.first;
    final totalLen = metric.length;
    final flashPos = progress * totalLen;

    final tangent = metric.getTangentForOffset(flashPos);
    if (tangent == null) return;
    final fp = tangent.position;

    // Breathing pulse
    final pulse = 0.85 + 0.15 * math.sin(progress * math.pi * 12);

    // ── 1) Long gradient trail (20%) ──
    final trailLen = totalLen * 0.20;
    final trailStart = (flashPos - trailLen).clamp(0.0, totalLen);
    if (flashPos > trailStart) {
      final trailPath = metric.extractPath(trailStart, flashPos);
      // Wide soft trail
      canvas.drawPath(
        trailPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            fp,
            Offset(
              fp.dx - tangent.vector.dx * trailLen * 0.3,
              fp.dy - tangent.vector.dy * trailLen * 0.3,
            ),
            [
              color.withValues(alpha: 0.3 * pulse),
              color.withValues(alpha: 0.0),
            ],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Thin bright core trail
      canvas.drawPath(
        trailPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            fp,
            Offset(
              fp.dx - tangent.vector.dx * trailLen * 0.3,
              fp.dy - tangent.vector.dy * trailLen * 0.3,
            ),
            [
              Colors.white.withValues(alpha: 0.6 * pulse),
              color.withValues(alpha: 0.0),
            ],
          ),
      );
    }

    // ── 2) Large outer halo ──
    canvas.drawCircle(
      fp,
      32 * pulse,
      Paint()
        ..shader = ui.Gradient.radial(
          fp,
          32 * pulse,
          [
            color.withValues(alpha: 0.2 * pulse),
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.0),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // ── 3) Medium glow ring ──
    canvas.drawCircle(
      fp,
      14 * pulse,
      Paint()
        ..shader = ui.Gradient.radial(
          fp,
          14 * pulse,
          [
            color.withValues(alpha: 0.5 * pulse),
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.0),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // ── 4) White hot center ──
    canvas.drawCircle(
      fp,
      4.5 * pulse,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(fp, 2.5, Paint()..color = Colors.white);

    // ── 5) Sparkle particles ──
    final rng = math.Random((progress * 10000).toInt());
    for (int i = 0; i < 5; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final dist = 8.0 + rng.nextDouble() * 16;
      final sparkleAlpha = (0.3 + rng.nextDouble() * 0.4) * pulse;
      final sparkleSize = 1.0 + rng.nextDouble() * 1.5;
      final sp = Offset(
        fp.dx + math.cos(angle) * dist,
        fp.dy + math.sin(angle) * dist,
      );
      canvas.drawCircle(
        sp,
        sparkleSize,
        Paint()
          ..color = Colors.white.withValues(alpha: sparkleAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CurveFlashPainter old) {
    return old.progress != progress;
  }
}
