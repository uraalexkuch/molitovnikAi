import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/ai/model_management_service.dart';
import '../../core/theme/app_theme.dart';

class ModelSelectionDialog extends StatefulWidget {
  final bool isMandatory;

  const ModelSelectionDialog({super.key, this.isMandatory = false});

  static Future<void> show(BuildContext context, {bool isMandatory = false}) async {
    return showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) => ModelSelectionDialog(isMandatory: isMandatory),
    );
  }

  @override
  State<ModelSelectionDialog> createState() => _ModelSelectionDialogState();
}

class _ModelSelectionDialogState extends State<ModelSelectionDialog> {
  final _modelService = ModelManagementService();
  AIModel? _selectedModel;
  bool _isDownloading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.isMandatory,
      child: Dialog(
        backgroundColor: AppTheme.backgroundDark,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.liturgicalRed.withOpacity(0.3), width: 1),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: const AssetImage("assets/images/paperold.jpg"),
              fit: BoxFit.cover,
              opacity: 0.03,
              colorFilter: ColorFilter.mode(AppTheme.backgroundDark.withOpacity(0.8), BlendMode.darken),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const Icon(Icons.auto_awesome_rounded, color: AppTheme.goldAccent, size: 40),
                    if (!widget.isMandatory && !_isDownloading)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Штучний Інтелект',
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Church',
                  ),
                ),
                const SizedBox(height: 12),
                if (!_isDownloading) ...[
                  const Text(
                    'Капелан потребує модель для автономної роботи. Оберіть варіант під ваш пристрій.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.parchment, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  ..._modelService.availableModels.map((model) => _buildModelOption(model)),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedModel == null ? null : _startDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.liturgicalRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                      ),
                      child: const Text(
                        'ЗАНУРИТИСЬ У ВИВЧЕННЯ',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ] else ...[
                  _buildDownloadProgress(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelOption(AIModel model) {
    bool isSelected = _selectedModel?.id == model.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedModel = model),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.liturgicalRed.withOpacity(0.15) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.liturgicalRed : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.liturgicalRed : Colors.white38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: TextStyle(
                      color: isSelected ? AppTheme.goldLight : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    model.description,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${model.sizeInGb} ГБ',
                style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadProgress() {
    return ValueListenableBuilder<double>(
      valueListenable: _modelService.downloadProgress,
      builder: (context, progress, child) {
        return Column(
          children: [
            const Icon(Icons.downloading, color: AppTheme.liturgicalRed, size: 48),
            const SizedBox(height: 16),
             Text(
              'Завантаження сувоїв...',
              style: TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontFamily: 'Church'),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                color: AppTheme.liturgicalRed,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 24),
            const Text(
              'Не закривайте додаток. Ми наповнюємо капелана мудрістю.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        );
      },
    );
  }

  void _startDownload() {
    if (_selectedModel == null) return;
    
    setState(() {
      _isDownloading = true;
      _error = null;
    });

    _modelService.downloadModel(
      _selectedModel!,
      onCompleted: (path) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ШІ-модель завантажена успішно!'),
              backgroundColor: AppTheme.liturgicalRed,
            ),
          );
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _error = err;
          });
        }
      },
    );
  }
}
