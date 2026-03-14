import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../domain/entities/news_entity.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';

/// Page Actualités — fil d'actualités financières BVMT
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: BlocBuilder<NewsBloc, NewsState>(
          builder: (context, state) {
            if (state is NewsLoading || state is NewsInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accentOrange),
              );
            }
            if (state is NewsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.textOnPrimary),
                ),
              );
            }
            if (state is NewsLoaded) {
              return _buildContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NewsLoaded state) {
    return RefreshIndicator(
      color: AppColors.accentOrange,
      backgroundColor: AppColors.deepNavy,
      onRefresh: () async {
        context.read<NewsBloc>().add(const NewsRefreshRequested());
      },
      child: CustomScrollView(
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.deepNavy,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Actualités',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.textOnPrimary,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),

          // ── Filtres catégories ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final cat = state.categories[index];
                  final isSelected = cat == state.selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_categoryLabel(cat)),
                      selected: isSelected,
                      onSelected: (_) {
                        context.read<NewsBloc>().add(NewsCategoryChanged(cat));
                      },
                      backgroundColor: AppColors.deepNavy.withValues(alpha: 0.5),
                      selectedColor: AppColors.accentOrange,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textOnPrimaryMuted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.accentOrange : Colors.white24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Articles ──
          if (state.filteredNews.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Aucun article dans cette catégorie',
                  style: TextStyle(color: AppColors.textOnPrimaryMuted),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    // Premier article en grand format
                    return _FeaturedNewsCard(article: state.filteredNews[0]);
                  }
                  return _NewsListTile(article: state.filteredNews[index]);
                },
                childCount: state.filteredNews.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'Tout':
        return 'Tout';
      case 'marché':
        return '📊 Marché';
      case 'entreprise':
        return '🏢 Entreprise';
      case 'analyse':
        return '📈 Analyse';
      case 'économie':
        return '🏦 Économie';
      default:
        return cat;
    }
  }
}

/// ── Article mis en avant (premier) ──
class _FeaturedNewsCard extends StatelessWidget {
  final NewsEntity article;
  const _FeaturedNewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMD,
        vertical: AppDimens.paddingSM,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.3),
            AppColors.deepNavy.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLG),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'À la une',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  article.timeAgo,
                  style: TextStyle(
                    color: AppColors.textOnPrimaryMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              article.title,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              article.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textOnPrimaryMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.newspaper, size: 14, color: AppColors.textOnPrimaryMuted),
                const SizedBox(width: 6),
                Text(
                  article.source,
                  style: TextStyle(
                    color: AppColors.textOnPrimaryMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (article.relatedSymbol != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.relatedSymbol!,
                      style: const TextStyle(
                        color: AppColors.accentOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Article standard ──
class _NewsListTile extends StatelessWidget {
  final NewsEntity article;
  const _NewsListTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMD,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Source + Temps ──
            Row(
              children: [
                _categoryIcon(article.category),
                const SizedBox(width: 6),
                Text(
                  article.source,
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (article.relatedSymbol != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.relatedSymbol!,
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  article.timeAgo,
                  style: TextStyle(
                    color: AppColors.textOnPrimaryMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Titre ──
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // ── Résumé ──
            Text(
              article.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textOnPrimaryMuted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(String category) {
    IconData icon;
    switch (category) {
      case 'marché':
        icon = Icons.show_chart;
        break;
      case 'entreprise':
        icon = Icons.business;
        break;
      case 'analyse':
        icon = Icons.analytics;
        break;
      case 'économie':
        icon = Icons.account_balance;
        break;
      default:
        icon = Icons.article;
    }
    return Icon(icon, size: 14, color: AppColors.textOnPrimaryMuted);
  }
}
