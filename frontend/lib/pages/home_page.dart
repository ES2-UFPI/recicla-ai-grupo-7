import 'package:flutter/material.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_bottom_nav_bar.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    
    // Determina o número de colunas com base na largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 2 : 1;

    return Scaffold(
      appBar: AppAppBar(title: "Recicla Aí"),
      endDrawer: AppDrawer(),
      bottomNavigationBar: AppBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Bem-vindo ao Recicla Aí!",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Conectamos geradores de resíduos, coletores e recicladoras, incentivando a reciclagem por meio de recompensas e educação ambiental.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: 3 / 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _HomePageCard(
                  redirectRoute: '/schedule',
                  icon: Icons.calendar_today,
                  title: "Agendamento de Coleta",
                  description: "Agende datas e horários para coleta dos seus resíduos.",
                ),
                _HomePageCard(
                  redirectRoute: '/notifications',
                  icon: Icons.notifications,
                  title: "Notificações",
                  description: "Receba alertas sobre coletas, pontos e novidades.",
                ),
                _HomePageCard(
                  redirectRoute: '/points',
                  icon: Icons.map,
                  title: "Pontos de Coleta",
                  description: "Visualize pontos de coleta próximos na sua região.",
                ),
                _HomePageCard(
                  redirectRoute: '/reward',
                  icon: Icons.emoji_events,
                  title: "Recompensas",
                  description: "Ganhe pontos e recompensas por reciclagem correta.",
                ),
                _HomePageCard(
                  redirectRoute: '/education',
                  icon: Icons.school,
                  title: "Educação Ambiental",
                  description: "Dicas e quizzes sobre separação correta dos resíduos.",
                ),
                _HomePageCard(
                  redirectRoute: '/history',
                  icon: Icons.history,
                  title: "Histórico",
                  description: "Acompanhe suas coletas e impacto ambiental.",
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Seção de motivação / call to action
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Comece a reciclar hoje!",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Agende sua coleta, ganhe recompensas e ajude o meio ambiente.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // ---> ação para agendar coleta
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Agendar Coleta"),
                      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                            backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                            foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String redirectRoute;

  const _HomePageCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.redirectRoute,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // Ajusta tamanhos proporcionalmente kkkkk
          final iconSize = width * 0.25;
          final titleFont = width * 0.09;
          final bodyFont = width * 0.06;
          final spacing = height * 0.03;

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: EdgeInsets.all(width * 0.07),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Conteúdo principal (ícone, título, descrição)
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(width * 0.05),
                          child: Icon(
                            icon,
                            size: iconSize,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(height: spacing),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFont,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(height: spacing),
                        Flexible(
                          child: Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: bodyFont,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing),
                  // Botão com tamanho fixo
                  SizedBox(
                    width: double.infinity,
                    height: height * 0.15,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, redirectRoute);
                      },
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      label: const Text("Acessar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: TextStyle(fontSize: bodyFont * 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}