import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/design_message.dart';
import '../providers/app_state.dart';
import '../models/page.dart';

/// Site text editor — matches /secret-panel/editor.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  List<PageItem> _pages = [];
  PageItem? _selected;
  String _content = '';
  bool _loading = true;
  bool _saving = false;
  String? _statusType;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    await state.loadPages();
    if (!mounted) return;
    setState(() {
      _pages = state.pages;
      _loading = false;
      if (_pages.isNotEmpty) {
        _selectPage(_pages.first);
      }
    });
  }

  void _selectPage(PageItem page) {
    setState(() {
      _selected = page;
      _content = page.content ?? '';
      _statusType = null;
      _statusMessage = null;
    });
  }

  Future<void> _handleSave() async {
    if (_selected == null) return;
    setState(() {
      _saving = true;
      _statusType = 'loading';
      _statusMessage = 'Saving changes...';
    });
    try {
      final ok = await context
          .read<AppState>()
          .updatePageContent(_selected!.id, _content);
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (ok) {
          _statusType = 'success';
          _statusMessage = 'Changes saved successfully!';
          _pages = _pages
              .map((p) => p.id == _selected!.id
                  ? PageItem(
                      id: p.id, title: p.title, slug: p.slug, content: _content)
                  : p)
              .toList();
        } else {
          _statusType = 'error';
          _statusMessage = 'Failed to save changes. Please try again.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _statusType = 'error';
        _statusMessage = 'Failed to save changes. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading)
            const DesignMessage(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page list
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.designBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pages',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.sidebarSectionTitle,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._pages.map((p) {
                              final active = _selected?.id == p.id;
                              return InkWell(
                                onTap: () => _selectPage(p),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? const Color(0xFFEEE9F8)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: active
                                          ? const Color(0xFFDDD5F3)
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    p.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: active
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: active
                                          ? AppColors.designText
                                          : AppColors.designMuted,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                // Editor
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Site Text Editor',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.designText),
                            ),
                            GradientButton(
                              label: _saving ? 'Saving...' : 'Save Changes',
                              onPressed: _handleSave,
                              loading: _saving,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.designBorder),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Content (HTML Supported)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.sidebarSectionTitle,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (_selected != null) ...[
                                    const Spacer(),
                                    Text(
                                      'Editing: ${_selected!.title}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.designMuted),
                                    ),
                                  ],
                                  const SizedBox(width: 16),
                                ],
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: TextField(
                                    controller:
                                        TextEditingController(text: _content),
                                    onChanged: (v) =>
                                        setState(() => _content = v),
                                    maxLines: null,
                                    expands: true,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 14,
                                      color: AppColors.designText,
                                      height: 1.5,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter page content here...',
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                  ),
                                ),
                              ),
                              if (_statusMessage != null)
                                StatusBanner(
                                    type: _statusType ?? 'info',
                                    message: _statusMessage!),
                              Container(
                                height: 1,
                                color: AppColors.designBorder,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Live Preview',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.sidebarSectionTitle,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: AppColors.designBorder),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _previewHtml(_content),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _previewHtml(String html) {
    if (html.isEmpty) return const SizedBox();
    var result = html;
    result =
        result.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    result = result.replaceAll(
        RegExp(r'</(p|div|h[1-6]|li)>', caseSensitive: false), '\n');
    result = result.replaceAll(RegExp(r'<[^>]*>'), '');
    result = result
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return Text(
      result.trim().isEmpty ? '' : result.trim(),
      style: const TextStyle(
          fontSize: 15, color: AppColors.designText, height: 1.6),
    );
  }
}
