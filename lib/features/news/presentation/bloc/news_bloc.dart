import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/news_mock_datasource.dart';
import '../../domain/entities/news_entity.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsMockDataSource dataSource;

  NewsBloc({required this.dataSource}) : super(const NewsInitial()) {
    on<NewsLoadRequested>(_onLoad);
    on<NewsCategoryChanged>(_onCategoryChanged);
    on<NewsRefreshRequested>(_onRefresh);
  }

  static const _categories = ['Tout', 'marché', 'entreprise', 'analyse', 'économie'];

  Future<void> _onLoad(NewsLoadRequested event, Emitter<NewsState> emit) async {
    emit(const NewsLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final allNews = dataSource.getAllNews();
      emit(NewsLoaded(
        allNews: allNews,
        filteredNews: allNews,
        selectedCategory: 'Tout',
        categories: _categories,
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  void _onCategoryChanged(NewsCategoryChanged event, Emitter<NewsState> emit) {
    if (state is! NewsLoaded) return;
    final current = state as NewsLoaded;
    List<NewsEntity> filtered;
    if (event.category == 'Tout') {
      filtered = current.allNews;
    } else {
      filtered = current.allNews.where((n) => n.category == event.category).toList();
    }
    emit(NewsLoaded(
      allNews: current.allNews,
      filteredNews: filtered,
      selectedCategory: event.category,
      categories: current.categories,
    ));
  }

  Future<void> _onRefresh(NewsRefreshRequested event, Emitter<NewsState> emit) async {
    final allNews = dataSource.getAllNews();
    final category = (state is NewsLoaded) ? (state as NewsLoaded).selectedCategory : 'Tout';
    List<NewsEntity> filtered;
    if (category == 'Tout') {
      filtered = allNews;
    } else {
      filtered = allNews.where((n) => n.category == category).toList();
    }
    emit(NewsLoaded(
      allNews: allNews,
      filteredNews: filtered,
      selectedCategory: category,
      categories: _categories,
    ));
  }
}
