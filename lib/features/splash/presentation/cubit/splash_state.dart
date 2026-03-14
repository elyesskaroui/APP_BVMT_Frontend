import 'package:equatable/equatable.dart';

/// État du splash screen
class SplashState extends Equatable {
  final bool showLogo;
  final bool showText;
  final bool showTagline;
  final bool showLoading;
  final bool showCheckmark;
  final bool startFadeOut;

  const SplashState({
    this.showLogo = false,
    this.showText = false,
    this.showTagline = false,
    this.showLoading = false,
    this.showCheckmark = false,
    this.startFadeOut = false,
  });

  SplashState copyWith({
    bool? showLogo,
    bool? showText,
    bool? showTagline,
    bool? showLoading,
    bool? showCheckmark,
    bool? startFadeOut,
  }) {
    return SplashState(
      showLogo: showLogo ?? this.showLogo,
      showText: showText ?? this.showText,
      showTagline: showTagline ?? this.showTagline,
      showLoading: showLoading ?? this.showLoading,
      showCheckmark: showCheckmark ?? this.showCheckmark,
      startFadeOut: startFadeOut ?? this.startFadeOut,
    );
  }

  @override
  List<Object?> get props => [
        showLogo,
        showText,
        showTagline,
        showLoading,
        showCheckmark,
        startFadeOut,
      ];
}
