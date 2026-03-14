import 'package:equatable/equatable.dart';
import '../../domain/entities/news_entity.dart';

abstract class NewsState extends Equatable {
  const NewsState();
  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

class NewsLoaded extends NewsState {
  final List<NewsEntity> allNews;
  final List<NewsEntity> filteredNews;
  final String selectedCategory;
  final List<String> categories;

  const NewsLoaded({
    required this.allNews,
    required this.filteredNews,
    required this.selectedCategory,
    required this.categories,
  });

  @override
  List<Object?> get props => [allNews, filteredNews, selectedCategory];
}

class NewsError extends NewsState {
  final String message;
  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
