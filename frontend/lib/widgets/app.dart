import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/blocs/auth_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/blocs/settings_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/app_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/collection_points_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/education_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/history_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/home_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/login_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/notifications_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/edit_profile_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/profile_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/register_material_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/register_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/reward_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/schedule_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/settings_page.dart';
import 'package:recicla_ai_grupo_7_frontend/pages/video_detail_page.dart';
import 'package:recicla_ai_grupo_7_frontend/utils/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, settings) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'App',
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: settings.themeMode,

          onGenerateRoute: (settings) {
            final uri = Uri.parse(settings.name ?? '');

            // Rota padrão
            if (uri.path == '/') {
              return MaterialPageRoute(builder: (_) => const AppPage());
            }

            // Rota estática
            switch (uri.path) {
              case '/':
                return MaterialPageRoute(builder: (_) => const AppPage());
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginPage());
              case '/register':
                return MaterialPageRoute(builder: (_) => const RegisterPage());
              
              case '/home':
                return MaterialPageRoute(builder: (_) => const HomePage());
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsPage());
              case '/profile':
                return MaterialPageRoute(builder: (_) => const ProfilePage());
              case '/edit-profile':
                return MaterialPageRoute(builder: (_) => const EditProfilePage());
              case '/schedule':
                return MaterialPageRoute(builder: (_) => const SchedulePage());
              case '/notifications':
                return MaterialPageRoute(builder: (_) => const NotificationsPage());
              case '/points':
                return MaterialPageRoute(builder: (_) => const CollectionPointsPage());
              case '/reward':
                return MaterialPageRoute(builder: (_) => const RewardPage());
              case '/history':
                return MaterialPageRoute(builder: (_) => const HistoryPage());
              case '/education':
                return MaterialPageRoute(builder: (_) => const EducationPage());

              // ADMIN
              case "/register-material":
                return MaterialPageRoute(builder: (_) => const RegisterMaterialPage());
            }

            // Rota dinâmica: /education/video/:id
            if (uri.pathSegments.length == 3 &&
                uri.pathSegments[0] == 'education' &&
                uri.pathSegments[1] == 'video') {
              final video = settings.arguments as Video;
              return MaterialPageRoute(
                builder: (_) => VideoDetailPage(video: video),
                settings: settings,
              );
            }

            // fallback
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Página não encontrada')),
              ),
            );
          },

          initialRoute: '/',
        ),
      ),
    );
  }
}
