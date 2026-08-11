import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
            tooltip: l10n.settingsTitle,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.messages.isEmpty
                ? _buildWelcomeMessage(l10n)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),
          if (provider.isLoading || provider.isStreaming)
            const LinearProgressIndicator(minHeight: 2),
          _buildInputArea(context, provider, l10n),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.welcomeMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ChatProvider provider, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.messagePlaceholder,
                  suffixIcon: provider.isLoading || provider.isStreaming
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                onSubmitted: (_) => _sendMessage(provider),
                enabled: !provider.isLoading,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.send_rounded),
              onPressed: provider.isLoading || _controller.text.trim().isEmpty
                  ? null
                  : () => _sendMessage(provider),
              tooltip: l10n.send,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(ChatProvider provider) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    provider.sendMessage(text);
    _scrollToBottom();
  }

  void _showSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ChatProvider>();
    final apiKeyController = TextEditingController(text: provider.apiKey);
    final themeMode = Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light';
    final locale = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.settingsTitle, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.apiKeyLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                hintText: l10n.apiKeyHint,
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.saveApiKey),
                onPressed: () async {
                  await provider.setApiKey(apiKeyController.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.apiKeySaved)),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _LanguageChip(
                  label: l10n.english,
                  selected: locale == 'en',
                  onTap: () => _changeLocale(context, const Locale('en')),
                ),
                const SizedBox(width: 8),
                _LanguageChip(
                  label: l10n.hindi,
                  selected: locale == 'hi',
                  onTap: () => _changeLocale(context, const Locale('hi')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(l10n.theme, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _ThemeChip(
                  label: l10n.light,
                  selected: themeMode == 'light',
                  onTap: () => _changeTheme(context, ThemeMode.light),
                ),
                const SizedBox(width: 8),
                _ThemeChip(
                  label: l10n.dark,
                  selected: themeMode == 'dark',
                  onTap: () => _changeTheme(context, ThemeMode.dark),
                ),
                const SizedBox(width: 8),
                _ThemeChip(
                  label: l10n.system,
                  selected: themeMode == 'system',
                  onTap: () => _changeTheme(context, ThemeMode.system),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.clearChat),
                    onPressed: () => _confirmClearChat(context, provider, l10n),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(l10n.version, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    l10n.poweredBy,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _changeLocale(BuildContext context, Locale locale) {
    // In a real app, you'd use a state management solution to persist this
    // For simplicity, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language changed to ${locale.languageCode == 'hi' ? 'Hindi' : 'English'}. Restart app to apply.')),
    );
  }

  void _changeTheme(BuildContext context, ThemeMode mode) {
    // Theme is handled by system in this implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme set to ${mode.name}. Uses system theme.')),
    );
  }

  void _confirmClearChat(BuildContext context, ChatProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearChat),
        content: Text(l10n.clearChatConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              provider.clearChat();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy_outlined,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.person_outline,
                size: 16,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: selected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: selected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
