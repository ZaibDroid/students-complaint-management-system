import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/config/api_config.dart';

class ComplaintAttachmentCard extends StatelessWidget {
  final String attachment;

  const ComplaintAttachmentCard({
    super.key,
    required this.attachment,
  });

  static String get _baseOrigin {
    try {
      final uri = Uri.parse(ApiConfig.baseUrl);
      final portSuffix = (uri.hasPort && uri.port != 80 && uri.port != 443) ? ':${uri.port}' : '';
      return '${uri.scheme}://${uri.host}$portSuffix';
    } catch (_) {
      return 'http://127.0.0.1:8000';
    }
  }

  static String resolveUrl(String raw) {
    var url = raw.trim();
    if (url.isEmpty) return url;
    if (url.startsWith('data:image')) return url;

    final origin = _baseOrigin;
    if (url.contains('localhost:8000')) {
      url = url.replaceAll('http://localhost:8000', origin).replaceAll('https://localhost:8000', origin);
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/storage/')) {
      return '$origin$url';
    }
    if (url.startsWith('storage/')) {
      return '$origin/$url';
    }
    if (url.startsWith('Applications/') || url.startsWith('/Applications/')) {
      final cleaned = url.startsWith('/') ? url.substring(1) : url;
      return '$origin/storage/$cleaned';
    }

    return '$origin/storage/$url';
  }

  static bool isImageAttachment(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('data:image')) return true;
    final lower = trimmed.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.contains('/applications/') ||
        lower.contains('/storage/applications/');
  }

  static String extractFileName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('data:image')) return 'Attached Image';
    final clean = trimmed.split('?').first;
    final name = clean.split('/').last;
    return name.isNotEmpty ? name : 'Attachment';
  }

  void _openFullScreenViewer(BuildContext context, ImageProvider imageProvider, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ),
              ),
            ),
            if (title.isNotEmpty)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = extractFileName(attachment);
    final isImg = isImageAttachment(attachment);

    if (attachment.startsWith('data:image')) {
      final base64Str = attachment.split(',').last;
      try {
        final bytes = base64Decode(base64Str);
        final imageProvider = MemoryImage(bytes);
        return _buildImageCard(context, theme, imageProvider, fileName);
      } catch (_) {
        return _buildFallbackCard('Invalid image data');
      }
    }

    if (isImg) {
      final resolved = resolveUrl(attachment);
      final imageProvider = NetworkImage(resolved);
      return _buildImageCard(
        context,
        theme,
        imageProvider,
        fileName,
        networkUrl: resolved,
      );
    }

    return _buildDocumentCard(context, theme, fileName);
  }

  Widget _buildImageCard(
    BuildContext context,
    ThemeData theme,
    ImageProvider imageProvider,
    String fileName, {
    String? networkUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _openFullScreenViewer(context, imageProvider, fileName),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 240, minHeight: 140),
                    color: Colors.grey.shade100,
                    child: networkUrl != null
                        ? Image.network(
                            networkUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 180,
                                color: Colors.grey.shade50,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        value: progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Loading attachment...',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (ctx, error, st) => Container(
                              height: 160,
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Failed to load image preview',
                                      style: TextStyle(fontSize: 13, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fileName,
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Tap to Zoom',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image, size: 18, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, ThemeData theme, String fileName) {
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPdf ? Colors.red.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.description,
              color: isPdf ? Colors.red : Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isPdf ? 'PDF Document' : 'Document Attachment',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(message, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
      ),
    );
  }
}

