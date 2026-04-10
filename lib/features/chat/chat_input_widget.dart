import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';

/// Віджет введення повідомлення з підтримкою голосу (STT).
class ChatInputWidget extends StatefulWidget {
  final Future<void> Function(String) onSend;
  final bool isLoading;

  const ChatInputWidget({
    super.key,
    required this.onSend,
    required this.isLoading,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    _controller.clear();
    widget.onSend(text);
  }

  /// Голосовий ввід (Offline STT)
  Future<void> _listen() async {
    if (!_isListening) {
      // Перевірка дозволів
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) return;
      }

      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) {
              setState(() => _isListening = false);
              // Відправляємо, якщо є текст
              if (_controller.text.trim().isNotEmpty) {
                _submit();
              }
            }
          }
        },
        onError: (val) => debugPrint('STT Error: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
            // Якщо це фінальний результат розпізнавання — відправляємо автоматично
            if (val.finalResult) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _isListening) {
                  setState(() => _isListening = false);
                  _submit();
                }
              });
            }
          },
          localeId: 'uk_UA', // Жорстко українська локаль
          cancelOnError: true,
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.goldAccent.withOpacity(0.15),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isLoading,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: AppTheme.parchment, fontSize: 15),
                decoration: InputDecoration(
                  hintText: _isListening ? 'Слухаю вас...' : 'Що на серці, друже?',
                  hintStyle: TextStyle(
                    color: _isListening ? AppTheme.goldAccent : Colors.white.withOpacity(0.3),
                    fontStyle: FontStyle.italic,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: AppTheme.goldAccent.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: AppTheme.goldAccent.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppTheme.goldAccent,
          ),
        ),
      );
    }

    // Якщо є текст — показуємо кнопку відправки, інакше — мікрофон
    final bool showMic = !_hasText;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: _isListening ? [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ] : [],
      ),
      child: IconButton(
        onPressed: showMic ? _listen : _submit,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            showMic 
              ? (_isListening ? Icons.mic : Icons.mic_none_rounded)
              : Icons.send_rounded,
            key: ValueKey(showMic ? 'mic' : 'send'),
          ),
        ),
        color: _isListening ? Colors.white : Colors.white,
        style: IconButton.styleFrom(
          backgroundColor: _isListening 
            ? Colors.redAccent 
            : AppTheme.ocuBurgundy.withOpacity(0.9),
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
