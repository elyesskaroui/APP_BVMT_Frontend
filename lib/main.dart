import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/cubits/market_status_cubit.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/home_event.dart';
import 'features/home/presentation/bloc/index_chart_bloc.dart';
import 'features/home/presentation/bloc/market_summary_bloc.dart';
import 'features/home/presentation/bloc/market_summary_event.dart';
import 'features/market/presentation/bloc/market_bloc.dart';
import 'features/market/presentation/bloc/market_event.dart';
import 'features/portfolio/presentation/bloc/portfolio_bloc.dart';
import 'features/portfolio/presentation/bloc/portfolio_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Injection des dépendances (async — GetStorage init)
  await initDependencies();

  // Barre de statut transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BvmtApp());
}

class BvmtApp extends StatelessWidget {
  const BvmtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MarketStatusCubit>(
          create: (_) => MarketStatusCubit(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => sl<HomeBloc>()..add(const HomeLoadRequested()),
        ),
        BlocProvider<MarketSummaryBloc>(
          create: (_) => sl<MarketSummaryBloc>()..add(const MarketSummaryLoadRequested()),
        ),
        BlocProvider<IndexChartBloc>(
          create: (_) => sl<IndexChartBloc>(),
        ),
        BlocProvider<MarketBloc>(
          create: (_) => sl<MarketBloc>()..add(const MarketLoadRequested()),
        ),
        BlocProvider<PortfolioBloc>(
          create: (_) => sl<PortfolioBloc>()..add(const PortfolioLoadRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'BVMT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        locale: const Locale('fr'),
        supportedLocales: const [
          Locale('fr'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
