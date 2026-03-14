import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/onboarding_data.dart';
import '../../../../core/constants/app_colors.dart';
import 'onboarding_state.dart';

/// Cubit pour gérer l'état de l'onboarding
class OnboardingCubit extends Cubit<OnboardingState> {
  final PageController pageController = PageController();
  final VoidCallback? onComplete;

  OnboardingCubit({this.onComplete}) : super(const OnboardingState()) {
    pageController.addListener(_onPageChanged);
  }

  /// Les 3 slides de l'onboarding BVMT
  final List<OnboardingData> slides = [
    OnboardingData(
      title: 'Suivez le Marché\nen Temps Réel',
      description:
          'Accédez aux cours de la BVMT en direct.\nSuivez le TUNINDEX et les tendances du marché.',
      icon: Icons.candlestick_chart_rounded,
      accentColor: AppColors.primaryBlue,
    ),
    OnboardingData(
      title: 'Gérez Votre\nPortefeuille',
      description:
          'Visualisez vos positions et performances.\nSuivez vos gains en temps réel.',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: AppColors.primaryBlueLight,
    ),
    OnboardingData(
      title: 'Alertes &\nNotifications',
      description:
          'Soyez notifié des mouvements importants.\nNe manquez aucune opportunité.',
      icon: Icons.notifications_active_rounded,
      accentColor: AppColors.accentOrange,
    ),
  ];

  void _onPageChanged() {
    final page = pageController.page?.round() ?? 0;
    if (page != state.currentPage) {
      emit(OnboardingState(
        currentPage: page,
        isLastPage: page == slides.length - 1,
      ));
    }
  }

  void nextPage() {
    if (state.currentPage < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    onComplete?.call();
  }

  void getStarted() {
    onComplete?.call();
  }

  @override
  Future<void> close() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    return super.close();
  }
}
