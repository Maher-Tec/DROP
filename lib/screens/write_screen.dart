import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../widgets/lake_background.dart';
import 'drop_animation_screen.dart';

class WriteScreen extends StatefulWidget {
  final bool wordless;

  const WriteScreen({super.key, this.wordless = false});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _controller = TextEditingController();
  bool _releasing = false;

  @override
  void initState() {
    super.initState();
    soundService.playLetItGo();
  }

  void _release() {
    if (_releasing || (!widget.wordless && _controller.text.trim().isEmpty)) {
      return;
    }

    setState(() => _releasing = true);
    final thought = _controller.text.trim();
    _controller.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    soundService.fadeOutAmbient();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => DropAnimationScreen(thought: thought),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _controller.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeService>().isDarkMode;
    final text = DropTheme.getTextColor(dark);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LakeBackground(
        showParticles: false,
        showWaves: false,
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _releasing
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(foregroundColor: text),
                ),
              ),
              SizedBox(height: keyboardOpen ? 2 : 12),
              Text(
                widget.wordless
                    ? "You don't have to write it."
                    : 'What would you like to let go?',
                textAlign: TextAlign.center,
                style: DropTheme.getBodyStyle(
                  dark,
                ).copyWith(fontSize: keyboardOpen ? 20 : 23),
              ),
              const SizedBox(height: 10),
              Text(
                "Your words aren't saved or sent by DROP.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: text.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              SizedBox(height: keyboardOpen ? 14 : 24),
              Expanded(
                child: widget.wordless
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              color: DropTheme.getAccentColor(dark),
                              size: 64,
                            ),
                            const SizedBox(height: 22),
                            Text(
                              "Hold a thought in your mind.\nRelease it when you're ready.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: text,
                                fontSize: 18,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      )
                    : TextField(
                        controller: _controller,
                        autofocus: true,
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        autocorrect: false,
                        enableSuggestions: false,
                        enableIMEPersonalizedLearning: false,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        scrollPadding: const EdgeInsets.only(bottom: 90),
                        style: DropTheme.getInputStyle(
                          dark,
                        ).copyWith(fontSize: 21, height: 1.55),
                        decoration: InputDecoration(
                          hintText: 'One thought...',
                          hintStyle: TextStyle(
                            color: text.withValues(alpha: 0.65),
                          ),
                          filled: true,
                          fillColor: text.withValues(alpha: 0.04),
                          contentPadding: const EdgeInsets.all(22),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: DropTheme.getAccentColor(dark),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: DropTheme.getAccentColor(
                                dark,
                              ).withValues(alpha: 0.55),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: DropTheme.getAccentColor(dark),
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
              ),
              SizedBox(height: keyboardOpen ? 12 : 22),
              SizedBox(
                width: 330,
                height: 54,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => FilledButton.icon(
                    onPressed:
                        !_releasing &&
                            (widget.wordless || value.text.trim().isNotEmpty)
                        ? _release
                        : null,
                    icon: const Icon(Icons.water_drop_outlined),
                    label: const Text('Let it go'),
                  ),
                ),
              ),
              if (!keyboardOpen) ...[
                const SizedBox(height: 12),
                Text(
                  'Leaving this screen discards your words.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: text.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
