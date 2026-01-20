import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  Future<void> _shareApp() async {
    final l10n = AppLocalizations.of(context);
    final link = await _fetchShareLink();
    final shareText = _buildShareText(l10n, link);
    if (shareText == null) {
      _showToast(l10n.aboutShareUnavailable);
      return;
    }
    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  Future<void> _openUpdate() async {
    final l10n = AppLocalizations.of(context);
    final url = AppConstants.appUpdateUrl;
    if (url.isEmpty) {
      _showToast(l10n.aboutUpdateUnavailable);
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showToast(l10n.aboutUpdateUnavailable);
      return;
    }
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      _showToast(l10n.aboutUpdateUnavailable);
    }
  }

  String? _buildShareText(AppLocalizations l10n, String? link) {
    final normalized = link?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return '${l10n.aboutShareMessage}\n$normalized';
    }
    final url = AppConstants.appShareUrl;
    if (url.isEmpty) {
      return null;
    }
    return '${l10n.aboutShareMessage}\n$url';
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<String?> _fetchShareLink() async {
    try {
      final dio = context.read<Dio>();
      final response = await dio.get('/finance/app_links/');
      final data = response.data;
      if (data is! Map) {
        return null;
      }
      final ok = data['ok'] == true;
      if (!ok) {
        return null;
      }
      return _pickStoreLink(data['app_links']);
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _pickStoreLink(dynamic appLinks) {
    final List<Map<String, dynamic>> links;
    if (appLinks is List) {
      links = appLinks.whereType<Map>().map((entry) {
        return Map<String, dynamic>.from(entry);
      }).toList();
    } else if (appLinks is Map) {
      links = [Map<String, dynamic>.from(appLinks)];
    } else {
      return null;
    }

    String? androidLink;
    String? iosLink;
    String? firstLink;

    for (final entry in links) {
      for (final item in entry.entries) {
        final key = item.key.toString();
        final value = item.value;
        if (value is! String || value.trim().isEmpty) {
          continue;
        }
        final link = value.trim();
        firstLink ??= link;
        if (key == 'play_marcet') {
          androidLink ??= link;
        } else if (key == 'app_store') {
          iosLink ??= link;
        }
      }
    }

    if (kIsWeb) {
      return androidLink ?? iosLink ?? firstLink;
    }
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return iosLink ?? androidLink ?? firstLink;
    }
    if (platform == TargetPlatform.android) {
      return androidLink ?? iosLink ?? firstLink;
    }
    return firstLink ?? androidLink ?? iosLink;
  }

  String _formatVersion(PackageInfo info) {
    final build = info.buildNumber.trim();
    if (build.isEmpty) {
      return info.version;
    }
    return '${info.version}+$build';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuAbout),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.surface,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aboutDescription,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale =
                        MediaQuery.textScalerOf(context).scale(1.0);
                    final stackButtons = constraints.maxWidth < 360 ||
                        textScale >= 1.3;

                    final shareButton = FilledButton.icon(
                      onPressed: _shareApp,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.share_outlined, size: 20),
                      label: Flexible(
                        child: Text(
                          l10n.aboutShareButton,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                    final updateButton = OutlinedButton.icon(
                      onPressed: _openUpdate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(
                        Icons.system_update_alt_outlined,
                        size: 20,
                      ),
                      label: Flexible(
                        child: Text(
                          l10n.aboutUpdateButton,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );

                    if (stackButtons) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          shareButton,
                          const SizedBox(height: 12),
                          updateButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: shareButton),
                        const SizedBox(width: 12),
                        Expanded(child: updateButton),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _Card(
                  child: FutureBuilder<PackageInfo>(
                    future: _packageInfoFuture,
                    builder: (context, snapshot) {
                      final version = snapshot.hasData
                          ? _formatVersion(snapshot.data!)
                          : '--';
                      return Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.aboutVersionLabel,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            version,
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
