import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_background.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/page_indicator.dart';
import '../widgets/onboarding_button.dart';

/// Écran Onboarding Premium — Animation fluide et design BVMT
class OnboardingPage extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingPage({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(onComplete: onComplete),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return Scaffold(
      body: Stack(
        children: [
          // Fond animé
          const OnboardingBackground(),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Bouton Skip
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: state.isLastPage ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: state.isLastPage,
                            child: _SkipButton(
                              onPressed: cubit.skip,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // PageView avec les slides
                Expanded(
                  child: PageView.builder(
                    controller: cubit.pageController,
                    itemCount: cubit.slides.length,
                    itemBuilder: (context, index) {
                      final slide = cubit.slides[index];
                      return OnboardingSlide(
                        title: slide.title,
                        description: slide.description,
                        icon: slide.icon,
                        accentColor: slide.accentColor,
                        index: index,
                      );
                    },
                  ),
                ),

                // Section inférieure
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                  child: Column(
                    children: [
                      // Indicateurs de page
                      BlocBuilder<OnboardingCubit, OnboardingState>(
                        builder: (context, state) {
                          return PageIndicator(
                            currentPage: state.currentPage,
                            pageCount: cubit.slides.length,
                          );
                        },
                      ),

                      const SizedBox(height: 36),

                      // Bouton Next / Get Started
                      BlocBuilder<OnboardingCubit, OnboardingState>(
                        builder: (context, state) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: state.isLastPage
                                ? OnboardingButton(
                                    key: const ValueKey('getStarted'),
                                    text: 'Commencer',
                                    onPressed: cubit.getStarted,
                                    isPrimary: true,
                                  )
                                : OnboardingButton(
                                    key: const ValueKey('next'),
                                    text: 'Suivant',
                                    onPressed: cubit.nextPage,
                                    isPrimary: false,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton Skip stylisé
class _SkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SkipButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Passer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
