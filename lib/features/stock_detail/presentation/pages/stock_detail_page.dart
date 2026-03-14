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
class StockDetailPage extends StatelessWidget {
  final String symbol;

  const StockDetailPage({super.key, required this.symbol});

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
      child: LineChart(
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
