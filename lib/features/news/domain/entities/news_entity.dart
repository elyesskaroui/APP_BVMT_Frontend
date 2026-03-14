import 'package:equatable/equatable.dart';

/// Entité représentant un article d'actualité financière
class NewsEntity extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String source;
  final String category; // 'marché', 'entreprise', 'analyse', 'économie'
  final DateTime publishedAt;
  final String? imageUrl;
  final String? relatedSymbol;

  const NewsEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.category,
    required this.publishedAt,
    this.imageUrl,
    this.relatedSymbol,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }

  @override
  List<Object?> get props => [id, title, source, publishedAt];
}
