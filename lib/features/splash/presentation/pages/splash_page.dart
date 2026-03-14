import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_logo.dart';
import '../widgets/animated_text.dart';
import '../widgets/loading_indicator.dart';

/// Écran Splash — Animation de démarrage BVMT
class SplashPage extends StatelessWidget {
  final VoidCallback onComplete;

  const SplashPage({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(onComplete: onComplete),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SplashCubit, SplashState>(
        builder: (context, state) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: state.startFadeOut ? 0.0 : 1.0,
            child: Stack(
              children: [
                const AnimatedBackground(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedLogo(
                        show: state.showLogo,
                        showCheckmark: state.showCheckmark,
                        size: 140,
                      ),
                      const SizedBox(height: 40),
                      AnimatedText(
                        text: 'BVMT',
                        show: state.showText,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                      const SizedBox(height: 16),
                      AnimatedText(
                        text: 'Bourse des Valeurs\nMobilières de Tunis',
                        show: state.showTagline,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                        opacity: 0.9,
                      ),
                      const SizedBox(height: 50),
                      LoadingIndicator(
                        show: state.showLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


