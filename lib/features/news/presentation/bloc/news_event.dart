import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();
  @override
  List<Object?> get props => [];
}

class NewsLoadRequested extends NewsEvent {
  const NewsLoadRequested();
}

class NewsCategoryChanged extends NewsEvent {
  final String category;
  const NewsCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class NewsRefreshRequested extends NewsEvent {
  const NewsRefreshRequested();
}
