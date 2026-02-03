import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/theme.dart';
import 'data/auth_service.dart';

// Import all screens (Placeholders for now)
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/assistant_screen.dart';
import 'presentation/screens/compare_transport_screen.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/screens/nearby_stations_screen.dart';
import 'presentation/screens/local_transport_screen.dart';
import 'presentation/screens/navigation_screen.dart';
import 'presentation/screens/train_list_screen.dart';
import 'presentation/screens/train_details_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/signup_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const TravelGuideApp(),
    ),
  );
}

class TravelGuideApp extends StatelessWidget {
  const TravelGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Rail Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/assistant': (context) => const AssistantScreen(),
        '/compare': (context) => const CompareTransportScreen(),
        '/map': (context) => const MapScreen(),
        '/nearby': (context) => const NearbyStationsScreen(),
        '/local': (context) => const LocalTransportScreen(),
        '/navigation': (context) => const NavigationScreen(),
        '/trains': (context) => const TrainListScreen(),
        '/train_details': (context) => const TrainDetailsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/history': (context) => const HistoryScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
