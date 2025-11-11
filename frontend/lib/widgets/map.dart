import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

@override
Widget build(BuildContext context) {
  return FlutterMap(
    options: MapOptions(
      initialCenter: LatLng(-5.03108, -42.79778), // mapa de Teresina
      initialZoom: 9.2,
    ),
    children: [
      RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
        attributions: [
          TextSourceAttribution(
            'OpenStreetMap contributors',
            onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
          ),
          // Also add images...
        ],
      ),
    ],
  );
}
