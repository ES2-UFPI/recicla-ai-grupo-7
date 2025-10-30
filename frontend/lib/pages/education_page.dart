import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educação por Vídeos',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 24),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/education/video/')) {
          final video = settings.arguments as Video;
          return MaterialPageRoute(
            builder: (context) => VideoPlayerPage(video: video),
          );
        }
        return MaterialPageRoute(builder: (context) => const EducationPage());
      },
    );
  }
}

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Educação"),
        backgroundColor: colorScheme.primary,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Mais Vistos"),
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                enableInfiniteScroll: true,
              ),
              items: mostViewedVideos.map((video) {
                return VideoThumbnailCard(
                  key: ValueKey(video.id),
                  video: video,
                  removeMargin: true,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            _buildSection(context, "Educação Ambiental", environmentalEducationVideos),
            _buildSection(context, "Reciclagem", recyclingVideos),
            _buildSection(context, "Outros", otherVideos),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
        ),
      );

  Widget _buildSection(BuildContext context, String title, List<Video> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        Column(
          children: videos
              .map(
                (video) => VideoThumbnailCard(
                  key: ValueKey(video.id),
                  video: video,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class Video {
  final String title;
  final String url;
  final String id;

  Video({required this.title, required this.url})
      : id = Uri.parse(url).queryParameters['v'] ?? Uri.parse(url).pathSegments.last;

  String get thumbnailUrl => 'https://img.youtube.com/vi/$id/0.jpg';
}

class VideoThumbnailCard extends StatelessWidget {
  final Video video;
  final bool removeMargin;

  const VideoThumbnailCard({
    super.key,
    required this.video,
    this.removeMargin = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openVideo(context, video),
      child: Card(
        elevation: 3,
        margin: removeMargin
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Image.network(
                  video.thumbnailUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 180,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                video.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVideo(BuildContext context, Video video) {
    Navigator.pushNamed(
      context,
      '/education/video/${video.id}',
      arguments: video,
    );
  }
}

class VideoPlayerPage extends StatelessWidget {
  final Video video;

  const VideoPlayerPage({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final controller = YoutubePlayerController(
      initialVideoId: video.id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        onReady: () {
        },
        onEnded: (metaData) {
          Navigator.pop(context);
        },
      ),
    );
  }
}

final mostViewedVideos = [
  Video(
    title: "Plantando 20,000,000 de Árvores, Meu Maior Projeto de Todos!",
    url: "https://youtu.be/HPJKxAhLw5I",
  ),
  Video(
    title: "O QUE É EDUCAÇÃO AMBIENTAL?",
    url: "https://www.youtube.com/watch?v=oV3pK3SOjxo",
  ),
  Video(
    title: "Governança e Educação Ambiental: ação e conscientização",
    url: "https://www.youtube.com/watch?v=p64avAOgyMo",
  ),
];

final environmentalEducationVideos = [
  Video(
    title: "CienciON#106 :Educação Ambiental e Complexidades",
    url: "https://www.youtube.com/watch?v=LBQ63PFoeEI",
  ),
  Video(
    title: "Proteger e preservar os recursos naturais é preciso",
    url: "https://www.youtube.com/watch?v=zGMy0ejnSCY",
  ),
];

final recyclingVideos = [
  Video(
    title: "Como é FEITO o PAPELÃO? #Boravê",
    url: "https://www.youtube.com/watch?v=J9TWWiF68fg",
  ),
  Video(
    title: "Reciclagem de Vidro: Transformando Lixo em Algo Novo",
    url: "https://www.youtube.com/watch?v=5ADi0ZBEkqc",
  ),
];

final otherVideos = [
  Video(
    title: "Como fazer Compostagem 🌱 3 Formas Fáceis de Fazer",
    url: "https://www.youtube.com/watch?v=WKPIGfYbJ0c",
  ),
  Video(
    title: "10 DICAS para ECONOMIZAR ÁGUA em CASA 💧✅",
    url: "https://www.youtube.com/watch?v=oVADyHI9GIg",
  ),
];