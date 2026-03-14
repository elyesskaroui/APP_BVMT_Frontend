import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';

/// Page de passage d'ordre — Acheter / Vendre une action
class OrderPage extends StatefulWidget {
  final String symbol;
  final double currentPrice;
  final String orderType; // 'buy' or 'sell'

  const OrderPage({
    super.key,
    required this.symbol,
    required this.currentPrice,
    required this.orderType,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  String _orderMode = 'market'; // 'market' or 'limit'
  bool _isSubmitting = false;

  bool get isBuy => widget.orderType == 'buy';

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.currentPrice.toStringAsFixed(3);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _quantity => double.tryParse(_quantityController.text) ?? 0;
  double get _price => _orderMode == 'market'
      ? widget.currentPrice
      : (double.tryParse(_priceController.text) ?? widget.currentPrice);
  double get _total => _quantity * _price;
  double get _commission => _total * 0.001; // 0.1% commission BVMT
  double get _grandTotal => _total + _commission;

  @override
  Widget build(BuildContext context) {
    final accentColor = isBuy ? AppColors.bullGreen : AppColors.bearRed;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: Text(
          '${isBuy ? 'Acheter' : 'Vendre'} ${widget.symbol}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Prix actuel ──
            _PriceHeader(
              symbol: widget.symbol,
              currentPrice: widget.currentPrice,
              accentColor: accentColor,
            ),
            const SizedBox(height: 24),

            // ── Type d'ordre ──
            const Text('Type d\'ordre',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                _OrderModeChip(
                  label: 'Au marché',
                  isSelected: _orderMode == 'market',
                  onTap: () => setState(() => _orderMode = 'market'),
                  color: accentColor,
                ),
                const SizedBox(width: 10),
                _OrderModeChip(
                  label: 'Limite',
                  isSelected: _orderMode == 'limit',
                  onTap: () => setState(() => _orderMode = 'limit'),
                  color: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Prix limite (si mode limite) ──
            if (_orderMode == 'limit') ...[
              const Text('Prix limite (TND)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Quantité ──
            const Text('Quantité',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _QuantityButton(
                  icon: Icons.remove,
                  onTap: () {
                    final q = (_quantity - 1).clamp(1, 99999).toInt();
                    _quantityController.text = q.toString();
                    setState(() {});
                  },
                  color: accentColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                        borderSide: BorderSide(color: accentColor, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _QuantityButton(
                  icon: Icons.add,
                  onTap: () {
                    final q = (_quantity + 1).clamp(1, 99999).toInt();
                    _quantityController.text = q.toString();
                    setState(() {});
                  },
                  color: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Raccourcis quantité
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [10, 50, 100, 500].map((q) {
                return ActionChip(
                  label: Text('$q', style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    _quantityController.text = q.toString();
                    setState(() {});
                  },
                  backgroundColor: AppColors.scaffoldBackground,
                  side: BorderSide(color: AppColors.divider),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Récapitulatif ──
            Container(
              padding: const EdgeInsets.all(AppDimens.paddingMD),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                border: Border.all(color: accentColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _SummaryRow('Prix unitaire', '${_price.toStringAsFixed(3)} TND'),
                  _SummaryRow('Quantité', '${_quantity.toInt()} actions'),
                  _SummaryRow('Montant brut', '${_total.toStringAsFixed(3)} TND'),
                  _SummaryRow('Commission (0.1%)', '${_commission.toStringAsFixed(3)} TND'),
                  const Divider(height: 16),
                  _SummaryRow(
                    'Total',
                    '${_grandTotal.toStringAsFixed(3)} TND',
                    isBold: true,
                    color: accentColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Bouton confirmer ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Confirmer ${isBuy ? "l'achat" : "la vente"}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Avertissement ──
            Container(
              padding: const EdgeInsets.all(AppDimens.paddingSM),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimens.radiusSM),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.accentOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'L\'investissement en bourse comporte des risques de perte en capital.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accentOrange.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (_quantity <= 0) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.bullGreen, size: 28),
            const SizedBox(width: 8),
            const Text('Ordre envoyé'),
          ],
        ),
        content: Text(
          '${isBuy ? "Achat" : "Vente"} de ${_quantity.toInt()} '
          '${widget.symbol} à ${_price.toStringAsFixed(3)} TND\n'
          'Total : ${_grandTotal.toStringAsFixed(3)} TND',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to detail
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ── Sous-widgets ──

class _PriceHeader extends StatelessWidget {
  final String symbol;
  final double currentPrice;
  final Color accentColor;

  const _PriceHeader({
    required this.symbol,
    required this.currentPrice,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              symbol.substring(0, symbol.length >= 2 ? 2 : symbol.length),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Cours actuel',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${currentPrice.toStringAsFixed(3)} TND',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _OrderModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusSM),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimens.radiusSM),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _SummaryRow(this.label, this.value, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? (color ?? AppColors.textPrimary) : AppColors.textSecondary,
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? (color ?? AppColors.textPrimary) : AppColors.textPrimary,
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
