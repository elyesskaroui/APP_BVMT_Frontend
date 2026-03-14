import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

/// Cubit pour gérer les animations du splash screen
class SplashCubit extends Cubit<SplashState> {
  final void Function()? onComplete;

  SplashCubit({this.onComplete}) : super(const SplashState()) {
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(showLogo: true));

    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(showText: true));

    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(showTagline: true));

    await Future.delayed(const Duration(milliseconds: 400));
    emit(state.copyWith(showLoading: true));

    // Simuler le chargement
    await Future.delayed(const Duration(milliseconds: 1500));
    emit(state.copyWith(showLoading: false, showCheckmark: true));

    await Future.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith(startFadeOut: true));

    await Future.delayed(const Duration(milliseconds: 600));
    onComplete?.call();
  }
}
