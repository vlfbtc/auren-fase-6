import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auren/features/auth/data/repositories/insights_repository.dart';
import 'package:auren/features/auth/data/datasources/financial_education_service.dart';

class InsightsScreen extends StatefulWidget {
  final bool showAppBar;
  const InsightsScreen({super.key, this.showAppBar = true});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late final InsightsRepository _repo;

  List<FinancialTip> _financialTips = [];
  List<EducationalContentItem> _educationalContent = [];

  @override
  void initState() {
    super.initState();
    _repo = RepositoryProvider.of<InsightsRepository>(context);
    _loadFinancialContent();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL inválida')),
      );
      return;
    }

    // Preferir abrir in-app (Custom Tabs / SFSafariViewController)
    if (await canLaunchUrl(uri)) {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView, // <- abre no app
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
      if (!ok) {
        // Tenta externo como fallback
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link')),
      );
    }
  }

  Future<void> _loadFinancialContent() async {
    try {
      final bundle = await _repo.recent();
      if (!mounted) return;

      setState(() {
        _financialTips = bundle.tips;
        _educationalContent = bundle.edu;
      });

      if (_financialTips.isEmpty && _educationalContent.isEmpty) {
        final gen = await _repo.recent();
        if (!mounted) return;
        setState(() {
          _financialTips = gen.tips;
          _educationalContent = gen.edu;
        });
      }
    } catch (_) {
      try {
        final gen = await _repo.recent();
        if (!mounted) return;
        setState(() {
          _financialTips = gen.tips;
          _educationalContent = gen.edu;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar conteúdo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Auren', style: TextStyle(color: Colors.white)),
        elevation: 0,
      )
          : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Auren',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recomendações Personalizadas
              Text(
                'Recomendações Personalizadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1.0),
              const SizedBox(height: 8),

              _financialTips.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : Column(
                children: _financialTips
                    .where((tip) => (tip.contentType ?? 'recommendation').toLowerCase() == 'recommendation')
                    .take(3)
                    .map((recommendation) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          )),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recommendation.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),

              const SizedBox(height: 32),

              // Dicas Financeiras
              Text(
                'Dicas Financeiras',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1.0),
              const SizedBox(height: 8),

              _financialTips.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : Column(
                children: _financialTips
                    .where((tip) => (tip.contentType ?? 'tip') == 'tip')
                    .take(3)
                    .map((tip) => _buildTipItem(tip))
                    .toList(),
              ),

              const SizedBox(height: 32),

              // Conteúdo Educacional
              Text(
                'Conteúdo Educacional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1.0),
              const SizedBox(height: 8),

              _educationalContent.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : Column(
                children: _educationalContent.take(4).map((content) {
                  return InkWell(
                    onTap: () async {
                      final t = content.type.toLowerCase();
                      if (t == 'video' || t == 'podcast') {
                        if (content.url.isNotEmpty) {
                          return _openUrl(content.url);
                        }
                      }
                      if (t == 'article' && content.id.isNotEmpty) {
                        return _showArticleBottomSheet(content.id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Abrindo: ${content.title}')),
                      );
                    },
                    child: _buildEducationalContentItem(content),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(FinancialTip tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(Icons.lightbulb_outline, size: 18, color: Colors.amber[700]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalContentItem(EducationalContentItem content) {
    IconData contentIcon;
    String contentTypeText;

    switch (content.type) {
      case 'article':
        contentIcon = Icons.article_outlined;
        contentTypeText = 'Artigo';
        break;
      case 'video':
        contentIcon = Icons.video_library_outlined;
        contentTypeText = 'Vídeo';
        break;
      case 'podcast':
        contentIcon = Icons.headphones_outlined;
        contentTypeText = 'Podcast';
        break;
      default:
        contentIcon = Icons.school_outlined;
        contentTypeText = 'Conteúdo';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(contentIcon, size: 18, color: Colors.blue[700]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: '$contentTypeText: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    children: [
                      TextSpan(
                        text: content.title,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mantém o mesmo layout da bottom sheet, agora pegando dados do backend (ou fallback)
  void _showArticleBottomSheet(String articleId) async {
    try {
      // loading sheet
      showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const SizedBox(
          height: 400,
          child: Center(child: CircularProgressIndicator()),
        ),
      );

      // encontra item da memória, senão busca no /recent
      EducationalContentItem? item;
      try {
        item = _educationalContent.firstWhere((c) => c.id == articleId);
      } catch (_) {}

      if (item == null) {
        final bundle = await _repo.recent();
        if (bundle.edu.isEmpty) {
          throw Exception('Nenhum conteúdo educacional disponível.');
        }
        item = bundle.edu.firstWhere(
              (c) => c.id == articleId,
          orElse: () => bundle.edu.first,
        );
      }

      // monta "artigo" usando a descrição como corpo
      final article = FinancialArticle(
        id: item.id,
        title: item.title,
        author: item.author ?? 'Auren',
        publishDate: DateTime.now(),
        content: item.description.isNotEmpty
            ? item.description
            : 'Conteúdo educacional selecionado para você. Acesse: ${item.url}',
        category: item.category,
        readTimeMinutes: item.readTimeMinutes ?? 5,
        tags: item.tags,
      );

      if (!mounted) return;
      Navigator.pop(context); // fecha loading

      showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        article.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Por ${article.author}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${article.readTimeMinutes} min leitura',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          article.content,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: article.tags
                              .map((tag) => Chip(
                            label: Text('#$tag'),
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.zero,
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  if (item!.url.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Abrir no navegador'),
                        onPressed: () => _openUrl(item!.url),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // fecha loading se aberto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar o artigo: $e')),
      );
    }
  }
}
