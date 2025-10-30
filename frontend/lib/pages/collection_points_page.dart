import 'package:flutter/material.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_drawer.dart';

class CollectionPointsPage extends StatefulWidget {
  const CollectionPointsPage({super.key});

  @override
  State<CollectionPointsPage> createState() => _CollectionPointsState();
}

class _CollectionPointsState extends State<CollectionPointsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: "Pontos de Coleta"),
      endDrawer: AppDrawer(),
      body: Center(child: Text("Collection Points")),
    );
  }
}