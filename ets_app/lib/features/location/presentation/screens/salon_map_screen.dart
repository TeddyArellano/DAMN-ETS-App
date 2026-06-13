import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ds_widgets.dart';

class SalonMapScreen extends StatefulWidget {
  final String salon;

  const SalonMapScreen({
    super.key,
    required this.salon,
  });

  @override
  State<SalonMapScreen> createState() => _SalonMapScreenState();
}

class _SalonMapScreenState extends State<SalonMapScreen> {
  String? svgContent;
  bool salonEncontrado = false;

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    final rawSvg = await rootBundle.loadString('assets/maps/mapa_escom.svg');

    final salon = _cleanSalon(widget.salon);

    final result = _highlightSalon(rawSvg, salon);

    setState(() {
      svgContent = result.svg;
      salonEncontrado = result.found;
    });
  }

  String _cleanSalon(String value) {
    return value
        .trim()
        .replaceAll('Salón', '')
        .replaceAll('Laboratorio', '')
        .replaceAll('Salon', '')
        .replaceAll(':', '')
        .replaceAll('-', '')
        .trim();
  }

  _HighlightResult _highlightSalon(String svg, String salon) {
    if (salon.isEmpty) {
      return _HighlightResult(svg: svg, found: false);
    }

    final salonId = RegExp.escape(salon);

    final rectRegex = RegExp(
      r'<rect\b(?=[^>]*\bid="' + salonId + r'")[^>]*/?>',
      caseSensitive: false,
      dotAll: true,
    );

    final foundRect = rectRegex.hasMatch(svg);

    if (!foundRect) {
      return _HighlightResult(svg: svg, found: false);
    }

    final highlightedSvg = svg.replaceFirstMapped(
      rectRegex,
      (match) {
        var rectTag = match.group(0)!;

        rectTag = _replaceOrAddRectAttribute(
          rectTag,
          'fill',
          '#FFD54F',
        );

        rectTag = _replaceOrAddRectAttribute(
          rectTag,
          'fill-opacity',
          '0.95',
        );

        rectTag = _replaceOrAddRectAttribute(
          rectTag,
          'stroke',
          '#D32F2F',
        );

        rectTag = _replaceOrAddRectAttribute(
          rectTag,
          'stroke-width',
          '2',
        );

        rectTag = _replaceOrAddRectAttribute(
          rectTag,
          'style',
          'fill:#FFD54F;fill-opacity:0.95;stroke:#D32F2F;stroke-width:2;stroke-dasharray:none',
        );

        return rectTag;
      },
    );

    return _HighlightResult(svg: highlightedSvg, found: true);
  }

  String _replaceOrAddRectAttribute(
    String tag,
    String attribute,
    String value,
  ) {
    final attributeRegex = RegExp('$attribute="[^"]*"');

    if (attributeRegex.hasMatch(tag)) {
      return tag.replaceAll(attributeRegex, '$attribute="$value"');
    }

    return tag.replaceFirst(
      '<rect',
      '<rect $attribute="$value"',
    );
  }

  @override
  Widget build(BuildContext context) {
    final salon = widget.salon.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación salón $salon'),
        flexibleSpace: const SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: BrandAccentBar(),
          ),
        ),
      ),
      body: svgContent == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!salonEncontrado)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    color: AppColors.warningSoft,
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.amber600, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'El salón $salon no está registrado en el mapa interno.',
                            style: AppType.sans(
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppColors.slate700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 6,
                    child: Center(
                      child: SvgPicture.string(svgContent!),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HighlightResult {
  final String svg;
  final bool found;

  const _HighlightResult({
    required this.svg,
    required this.found,
  });
}