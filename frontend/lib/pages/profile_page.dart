import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/blocs/auth_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/services/api_service.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_drawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    String? name;
    String? email;
    String? role;
    try {
      final accessToken = context.read<AuthCubit>().state?.accessToken;
      if (accessToken != null) {
        ApiService.authMe(accessToken).then((response) {
          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);

            name = body["data"]["name"];
            email = body["data"]["email"];
            role = body["data"]["role"];

            return Scaffold(
              appBar: AppAppBar(title: 'Perfil'),
              endDrawer: AppDrawer(),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header do perfil
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "$name",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$email",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),

                    Text(
                      "$role",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Cards de opções do perfil
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 2
                          : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3 / 1,
                      children: [
                        _ProfileCard(
                          icon: Icons.edit,
                          title: "Editar Perfil",
                          redirectRoute: '/edit-profile',
                        ),
                        _ProfileCard(
                          icon: Icons.history,
                          title: "Histórico de Coletas",
                          redirectRoute: '/history',
                        ),
                        _ProfileCard(
                          icon: Icons.emoji_events,
                          title: "Recompensas",
                          redirectRoute: '/reward',
                        ),
                        _ProfileCard(
                          icon: Icons.settings,
                          title: "Configurações",
                          redirectRoute: '/settings',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Botão de logout
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          try {
                            ApiService.authLogout(
                              context.read<AuthCubit>().state!.accessToken,
                            ).then((response) {
                              if (response.statusCode == 200) {
                                context.read<AuthCubit>().clearAuth();
                                Navigator.pushReplacementNamed(context, '/');
                              } else {}
                            });
                          } catch (e) {}
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Sair"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (response.statusCode == 401) {
            return Text("Não autorizado");
          }
        });
      }
    } catch (e) {
      return Text("Erro ao carregar perfil: $e");
    }
    return FutureBuilder(
      future: ApiService.authMe(context.read<AuthCubit>().state!.accessToken),
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: Text("Carregando..."));
      } else if (snapshot.hasError) {
        return Center(child: Text("Erro ao carregar perfil: ${snapshot.error}"));
      } else if (snapshot.hasData && snapshot.data!.statusCode == 200) {
        final body = jsonDecode(snapshot.data!.body);
        final name = body["data"]["name"];
        final email = body["data"]["email"];
        final role = body["data"]["role"];

        return Scaffold(
        appBar: AppAppBar(title: 'Perfil'),
        endDrawer: AppDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            ),
            const SizedBox(height: 16),
            Text(
            "$name",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
            "$email",
            style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            Text(
            "$role",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            ),
            const SizedBox(height: 24),
            GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 1,
            children: [
              _ProfileCard(
              icon: Icons.edit,
              title: "Editar Perfil",
              redirectRoute: '/edit-profile',
              ),
              _ProfileCard(
              icon: Icons.history,
              title: "Histórico de Coletas",
              redirectRoute: '/history',
              ),
              _ProfileCard(
              icon: Icons.emoji_events,
              title: "Recompensas",
              redirectRoute: '/reward',
              ),
              _ProfileCard(
              icon: Icons.settings,
              title: "Configurações",
              redirectRoute: '/settings',
              ),
            ],
            ),
            const SizedBox(height: 24),
            SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
              try {
                ApiService.authLogout(context.read<AuthCubit>().state!.accessToken).then((response) {
                if (response.statusCode == 200) {
                  context.read<AuthCubit>().clearAuth();
                  Navigator.pushReplacementNamed(context, '/');
                }
                });
              } catch (e) {}
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sair"),
              style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            ),
          ],
          ),
        ),
        );
      } else if (snapshot.hasData && snapshot.data!.statusCode == 401) {
        return const Center(child: Text("Não autorizado"));
      } else {
        return const Center(child: Text("Erro desconhecido"));
      }
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String redirectRoute;

  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.redirectRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, redirectRoute),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
