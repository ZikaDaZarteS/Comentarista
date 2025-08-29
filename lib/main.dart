import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/providers_config.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'screens/list_screen.dart';
import 'screens/round_screen.dart';
import 'screens/classification_screen.dart';
import 'screens/top_screen.dart';
import 'screens/confrontation_detail_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const ComentaristaApp());
}

class ComentaristaApp extends StatelessWidget {
  const ComentaristaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProvidersConfig.providers,
      child: MaterialApp(
        title: 'Comentarista',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.initialRoute,
        routes: AppRoutes.routes,
        onGenerateRoute: (settings) {
          // Rota para tela de histórico do competidor
          if (settings.name == AppRoutes.competitorHistory) {
            final confrontation = settings.arguments as Map<String, dynamic>;
            return AppRoutes.competitorHistoryRoute(confrontation);
          }

          // Rota para tela de detalhes do confronto
          if (settings.name == AppRoutes.confrontationDetail) {
            final confrontation = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) =>
                  ConfrontationDetailScreen(confrontation: confrontation),
            );
          }

          return null;
        },
        home: const HomeScreen(),
      ),
    );
  }
}
