import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/classification_screen.dart';
import '../screens/list_screen.dart';
import '../screens/top_screen.dart';
import '../screens/round_screen.dart';
import '../screens/competitor_history_screen.dart';
import '../screens/confrontation_detail_screen.dart';

class AppRoutes {
  static const String initialRoute = '/login';
  static const String login = '/login';
  static const String home = '/home';
  static const String classification = '/classification';
  static const String list = '/list';
  static const String top = '/top';
  static const String round = '/round';
  static const String competitorHistory = '/competitor-history';
  static const String confrontationDetail = '/confrontation-detail';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        home: (context) => const HomeScreen(),
        classification: (context) => const ClassificationScreen(),
        list: (context) => const ListScreen(),
        top: (context) => const TopScreen(),
        round: (context) => const RoundScreen(),
        competitorHistory: (context) => CompetitorHistoryScreen(
              confrontation: {'competidor': '', 'animal': ''},
            ),
      };

  static Route<dynamic> competitorHistoryRoute(
      Map<String, dynamic> confrontation) {
    return MaterialPageRoute(
      builder: (context) =>
          CompetitorHistoryScreen(confrontation: confrontation),
    );
  }

  static Route<dynamic> confrontationDetailRoute(
      Map<String, dynamic> confrontation) {
    return MaterialPageRoute(
      builder: (context) =>
          ConfrontationDetailScreen(confrontation: confrontation),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  String _getTitle(int index) {
    final titles = ['Lista', 'Round', 'Classificação', 'Top Bull'];
    return titles[index];
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Implementar logout aqui
    // Por enquanto apenas navega para login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          ListScreen(),
          RoundScreen(),
          ClassificationScreen(),
          TopScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFFE53E3E),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Lista',
            backgroundColor: Color(0xFF1A1A1A),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.desktop_windows),
            label: 'Round',
            backgroundColor: Color(0xFF1A1A1A),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Classificação',
            backgroundColor: Color(0xFF1A1A1A),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Top Bull',
            backgroundColor: Color(0xFF1A1A1A),
          ),
        ],
      ),
    );
  }
}
