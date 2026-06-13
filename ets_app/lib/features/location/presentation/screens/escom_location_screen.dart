import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ds_widgets.dart';
import '../../data/services/location_service.dart';

class EscomLocationScreen extends StatefulWidget {
  const EscomLocationScreen({super.key});

  @override
  State<EscomLocationScreen> createState() => _EscomLocationScreenState();
}

class _EscomLocationScreenState extends State<EscomLocationScreen> {
  final _locationService = LocationService();

  Position? currentPosition;
  double? distanceMeters;
  bool loading = false;
  String? error;

  Future<void> _getLocation() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final distance = _locationService.distanceToEscomInMeters(position);

      setState(() {
        currentPosition = position;
        distanceMeters = distance;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _openGoogleMaps() async {
    const destinationLat = 19.5047;
    const destinationLng = -99.1469;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=walking',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir Google Maps.');
    }
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }

    return '${meters.toStringAsFixed(0)} m';
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final distanceText =
        distanceMeters == null ? null : _formatDistance(distanceMeters!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de ESCOM'),
        flexibleSpace: const SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: BrandAccentBar(),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadii.rxl,
                        border: Border.all(color: AppColors.azul200),
                      ),
                      child: const Icon(Icons.place_outlined,
                          size: 42, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(child: Eyebrow('Escuela Superior de Cómputo')),
                  const SizedBox(height: 8),
                  Center(
                    child: Text('Ubicación de ESCOM',
                        style: AppType.serif(size: 26)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Av. Juan de Dios Bátiz s/n, Col. Lindavista, '
                    'Gustavo A. Madero, Ciudad de México.',
                    textAlign: TextAlign.center,
                    style: AppType.sans(
                      size: 14,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (distanceText != null)
                    DsCard(
                      color: AppColors.primarySoft,
                      borderColor: AppColors.azul200,
                      shadow: AppShadows.xs,
                      child: Column(
                        children: [
                          Text(
                            'Distancia aproximada desde tu ubicación',
                            style: AppType.sans(
                              size: 13,
                              color: AppColors.azul800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            distanceText,
                            style: AppType.serif(
                              size: 36,
                              color: AppColors.azul900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (error != null)
                    DsCard(
                      color: AppColors.dangerSoft,
                      borderColor: AppColors.red600,
                      shadow: AppShadows.xs,
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              error!,
                              style: AppType.sans(
                                  size: 13, color: AppColors.red600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _getLocation,
                    icon: const Icon(Icons.my_location, size: 18),
                    label: const Text('Actualizar mi ubicación'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _openGoogleMaps,
                    icon: const Icon(Icons.directions_outlined, size: 18),
                    label: const Text('Cómo llegar a ESCOM'),
                  ),
                ],
              ),
            ),
    );
  }
}
