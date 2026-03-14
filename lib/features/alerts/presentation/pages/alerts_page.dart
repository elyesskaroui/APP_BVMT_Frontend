import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../domain/entities/alert_entity.dart';
import '../bloc/alerts_bloc.dart';
import '../bloc/alerts_event.dart';
import '../bloc/alerts_state.dart';

/// Page Alertes — liste des alertes de prix configurées
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        if (state is AlertsLoading) {
          return _buildLoading();
        }
        if (state is AlertsLoaded) {
          return _buildLoaded(context, state);
        }
        if (state is AlertsError) {
          return _buildError(context, state.message);
        }
        return _buildLoading();
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, AlertsLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.headerGradient),
              ),
            ),
            title: const Text(
              'Alertes',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.textOnPrimary),
                onPressed: () => _showAddAlertDialog(context),
              ),
            ],
          ),

          if (state.alerts.isEmpty)
            const SliverFillRemaining(
              child: _EmptyAlertsWidget(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppDimens.paddingMD),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _AlertTile(
                    alert: state.alerts[index],
                    onToggle: () {
                      context.read<AlertsBloc>().add(AlertToggled(state.alerts[index].id));
                    },
                    onDelete: () {
                      context.read<AlertsBloc>().add(AlertDeleted(state.alerts[index].id));
                    },
                  ),
                  childCount: state.alerts.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showAddAlertDialog(BuildContext context) {
    final symbolController = TextEditingController();
    final priceController = TextEditingController();
    String condition = 'above';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stfContext, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(stfContext).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingLG),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Handle ──
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Nouvelle Alerte',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Symbole ──
                    TextField(
                      controller: symbolController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Symbole (ex: BIAT)',
                        hintText: 'Entrez le symbole',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Prix cible ──
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Prix cible (TND)',
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Condition ──
                    const Text(
                      'Condition',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => condition = 'above'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: condition == 'above'
                                    ? AppColors.bullGreen.withValues(alpha: 0.15)
                                    : AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(AppDimens.radiusSM),
                                border: Border.all(
                                  color: condition == 'above'
                                      ? AppColors.bullGreen
                                      : AppColors.divider,
                                  width: condition == 'above' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_upward,
                                      color: condition == 'above'
                                          ? AppColors.bullGreen
                                          : AppColors.textSecondary,
                                      size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Au-dessus',
                                    style: TextStyle(
                                      color: condition == 'above'
                                          ? AppColors.bullGreen
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => condition = 'below'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: condition == 'below'
                                    ? AppColors.bearRed.withValues(alpha: 0.15)
                                    : AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(AppDimens.radiusSM),
                                border: Border.all(
                                  color: condition == 'below'
                                      ? AppColors.bearRed
                                      : AppColors.divider,
                                  width: condition == 'below' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_downward,
                                      color: condition == 'below'
                                          ? AppColors.bearRed
                                          : AppColors.textSecondary,
                                      size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    'En-dessous',
                                    style: TextStyle(
                                      color: condition == 'below'
                                          ? AppColors.bearRed
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Bouton créer ──
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final symbol = symbolController.text.trim().toUpperCase();
                          final price = double.tryParse(priceController.text.trim());
                          if (symbol.isEmpty || price == null || price <= 0) {
                            ScaffoldMessenger.of(stfContext).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez remplir tous les champs correctement'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          context.read<AlertsBloc>().add(AlertCreated(
                                symbol: symbol,
                                targetPrice: price,
                                condition: condition,
                              ));
                          Navigator.pop(stfContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Alerte créée pour $symbol à ${price.toStringAsFixed(2)} TND'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.bullGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                          ),
                        ),
                        child: const Text(
                          'Créer l\'alerte',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.bearRed, size: 64),
              const SizedBox(height: AppDimens.paddingMD),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: AppDimens.paddingLG),
              ElevatedButton(
                onPressed: () {
                  context.read<AlertsBloc>().add(const AlertsLoadRequested());
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

class _EmptyAlertsWidget extends StatelessWidget {
  const _EmptyAlertsWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: AppDimens.paddingMD),
          const Text(
            'Aucune alerte configurée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez des alertes pour être notifié\nlorsqu\'un prix atteint votre cible',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: AppDimens.paddingLG),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle alerte'),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _AlertTile({
    required this.alert,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingSM),
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
          // ── Icône condition ──
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (alert.isAbove ? AppColors.bullGreen : AppColors.bearRed)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusSM),
            ),
            alignment: Alignment.center,
            child: Icon(
              alert.isAbove ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: alert.isAbove ? AppColors.bullGreen : AppColors.bearRed,
              size: 22,
            ),
          ),

          const SizedBox(width: AppDimens.paddingSM + 4),

          // ── Infos ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${alert.conditionText} ${alert.formattedPrice}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ── Toggle ──
          Switch(
            value: alert.isActive,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primaryBlue,
          ),

          // ── Delete ──
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
