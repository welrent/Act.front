import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/seed_data.dart';
import '../../models/user.dart';
import '../../providers/app_state.dart';
import '../../theme/colors.dart';
import 'login_modal.dart';

/// Header — 1:1 match to Next.js Header.tsx and header-styles.css
class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();

  Timer? _debounceTimer;
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _hoverHome = false;
  bool _hoverUser = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      if (_searchController.text.trim().length >= 2) {
        _showOverlay();
      }
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isMetaOrCtrl = HardwareKeyboard.instance.isMetaPressed ||
          HardwareKeyboard.instance.isControlPressed;
      if (isMetaOrCtrl && event.logicalKey == LogicalKeyboardKey.keyK) {
        _focusNode.requestFocus();
        _searchController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _searchController.text.length,
        );
        if (_searchController.text.trim().length >= 2) {
          _showOverlay();
        }
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape &&
          _overlayController.isShowing) {
        _hideOverlay();
        _focusNode.unfocus();
        return true;
      }
    }
    return false;
  }

  void _showOverlay() {
    if (!_overlayController.isShowing) {
      _overlayController.show();
    }
  }

  void _hideOverlay() {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  void _openUrl(String url) {
    _hideOverlay();
    _searchController.clear();
    _focusNode.unfocus();
    context.go(url);
  }

  void _onSearchChanged(String v) {
    _debounceTimer?.cancel();
    final query = v.trim();
    if (query.length < 2) {
      setState(() {
        _results = [];
      });
      _hideOverlay();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String q) async {
    final state = context.read<AppState>();
    setState(() => _isSearching = true);

    try {
      final apiResults = await state.api.search(q);
      if (!mounted) return;
      if (apiResults.isNotEmpty) {
        setState(() {
          _results = apiResults;
          _isSearching = false;
        });
        _showOverlay();
        return;
      }
    } catch (_) {}

    // Fallback: Comprehensive local search
    final localResults = <Map<String, dynamic>>[];
    final lowerQ = q.toLowerCase();
    final seenUrls = <String>{};

    // 1. Pages (State + SeedData)
    final allPages = [
      ...state.pages,
      ...SeedData.pages,
    ];
    for (final page in allPages) {
      final url = '/pages/${page.slug}';
      if (seenUrls.contains(url)) continue;
      final matchTitle = page.title.toLowerCase().contains(lowerQ);
      final matchContent = (page.content ?? '').toLowerCase().contains(lowerQ);
      if (matchTitle || matchContent) {
        seenUrls.add(url);
        localResults.add({
          'title': page.title,
          'type': 'Page',
          'url': url,
        });
      }
    }

    // 2. Standard Agreements
    final agreements = [
      {
        'title': 'Car Rental Agreement',
        'url': '/pages/car-rental-agreement',
        'type': 'Agreement'
      },
      {
        'title': 'Motorcycle Rental Agreement',
        'url': '/pages/motorcycle-rental-agreement',
        'type': 'Agreement'
      },
      {
        'title': 'Boat Rental Agreement',
        'url': '/pages/boat-rental-agreement',
        'type': 'Agreement'
      },
      {
        'title': 'Equipment Rental Agreement',
        'url': '/pages/equipment-rental-agreement',
        'type': 'Agreement'
      },
      {
        'title': 'Fleet Management Agreement',
        'url': '/pages/fleet-management-agreement',
        'type': 'Agreement'
      },
      {
        'title': 'Vehicle Damage & Insurance Terms',
        'url': '/pages/damage-insurance-terms',
        'type': 'Agreement'
      },
      {
        'title': 'EV Charging & Battery Terms',
        'url': '/pages/ev-charging-battery-terms',
        'type': 'Agreement'
      },
      {
        'title': 'Rental Cancellation Policy',
        'url': '/pages/cancellation-policy',
        'type': 'Agreement'
      },
      {
        'title': 'Agreements Overview',
        'url': '/agreements',
        'type': 'Agreement'
      },
    ];
    for (final agr in agreements) {
      final url = agr['url']!;
      if (seenUrls.contains(url)) continue;
      if (agr['title']!.toLowerCase().contains(lowerQ)) {
        seenUrls.add(url);
        localResults.add(agr);
      }
    }

    // 3. Contracts (State + SeedData)
    final allContracts = [
      ...state.contracts,
      ...SeedData.contracts,
    ];
    for (final contract in allContracts) {
      final url = '/contracts/${contract.contractRef}';
      if (seenUrls.contains(url)) continue;
      final matchRef = contract.contractRef.toLowerCase().contains(lowerQ);
      final matchVehicle = contract.vehicleName.toLowerCase().contains(lowerQ);
      final matchBooking =
          contract.bookingRef?.toLowerCase().contains(lowerQ) ?? false;
      if (matchRef || matchVehicle || matchBooking) {
        seenUrls.add(url);
        localResults.add({
          'title': '${contract.contractRef} - ${contract.vehicleName}',
          'type': 'Contract',
          'url': url,
        });
      }
    }

    // 4. Navigation
    final navItems = [
      {'title': 'Dashboard', 'url': '/', 'type': 'Navigation'},
      {'title': 'My Profile', 'url': '/profile', 'type': 'Navigation'},
      {'title': 'Control Panel', 'url': '/secret-panel', 'type': 'Admin'},
      {
        'title': 'Company Settings',
        'url': '/secret-panel/settings',
        'type': 'Admin'
      },
      {
        'title': 'Site Text Editor',
        'url': '/secret-panel/editor',
        'type': 'Admin'
      },
    ];
    for (final nav in navItems) {
      final url = nav['url']!;
      if (seenUrls.contains(url)) continue;
      if (nav['title']!.toLowerCase().contains(lowerQ)) {
        seenUrls.add(url);
        localResults.add(nav);
      }
    }

    if (!mounted) return;
    setState(() {
      _results = localResults;
      _isSearching = false;
    });
    _showOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final state = context.watch<AppState>();
    final user = state.auth.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 560;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header row: WR logo + right links
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo: WR.svg | Act
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/img/WR.svg',
                            width: isMobile ? 36 : 48,
                            height: isMobile ? 22 : 28,
                            fit: BoxFit.contain,
                            placeholderBuilder: (_) => Container(
                              width: 48,
                              height: 28,
                              alignment: Alignment.center,
                              child: const Text(
                                'WR',
                                style: TextStyle(
                                  color: AppColors.designText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 6 : 10),
                            child: Text(
                              '|',
                              style: TextStyle(
                                color: AppColors.pipeColor,
                                fontSize: isMobile ? 20 : 26,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          Text(
                            'Act',
                            style: TextStyle(
                              color: AppColors.actColor,
                              fontSize: isMobile ? 20 : 26,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Header right: Main site (welrent.com) + User section
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMobile) ...[
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() => _hoverHome = true),
                          onExit: (_) => setState(() => _hoverHome = false),
                          child: GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse('https://welrent.com'),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  size: 18,
                                  color: _hoverHome
                                      ? AppColors.designText
                                      : AppColors.designMuted,
                                ),
                                if (!isCompact) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    'Main site',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _hoverHome
                                          ? AppColors.designText
                                          : AppColors.designMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      _buildUserSection(user, isMobile || isCompact),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Search row with floating overlay
              CompositedTransformTarget(
                link: _layerLink,
                child: OverlayPortal(
                  controller: _overlayController,
                  overlayChildBuilder: (context) {
                    return CompositedTransformFollower(
                      link: _layerLink,
                      targetAnchor: Alignment.bottomLeft,
                      followerAnchor: Alignment.topLeft,
                      offset: const Offset(0, 5),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: TapRegion(
                            groupId: 'header_search_region',
                            onTapOutside: (_) => _hideOverlay(),
                            child: Material(
                              elevation: 6,
                              shadowColor: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 280),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: AppColors.borderColor),
                                ),
                                child: _buildResultsList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: TapRegion(
                    groupId: 'header_search_region',
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.searchBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _focusNode.requestFocus(),
                            child: const Icon(
                              Icons.search,
                              size: 16,
                              color: AppColors.designMutedLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              onChanged: _onSearchChanged,
                              onSubmitted: (_) {
                                if (_results.isNotEmpty) {
                                  final firstUrl =
                                      _results.first['url'] as String? ?? '/';
                                  _openUrl(firstUrl);
                                }
                              },
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.designText,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.designMutedLight,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => _focusNode.requestFocus(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.searchShortcutBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '⌘ K',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.searchShortcutText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'No results found.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.designMutedLight,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: AppColors.designBorder,
      ),
      itemBuilder: (context, index) {
        final item = _results[index];
        return _SearchResultItem(
          item: item,
          onTap: () {
            final url = item['url'] as String? ?? '/';
            _openUrl(url);
          },
        );
      },
    );
  }

  Widget _buildUserSection(AppUser user, bool isMobile) {
    if (user.isAuthenticated) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go('/profile'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                Text(
                  user.displayNameOrEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.designText,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.avatarActive,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user.avatarLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoverUser = true),
      onExit: (_) => setState(() => _hoverUser = false),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => const LoginModal(),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMobile) ...[
              Text(
                'You are not logged in',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      _hoverUser ? AppColors.designText : AppColors.designMuted,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    _hoverUser ? const Color(0xFF8EB9FF) : AppColors.avatarBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.person,
                size: 18,
                color: _hoverUser ? Colors.white : AppColors.avatarIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.item,
    required this.onTap,
  });

  @override
  State<_SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<_SearchResultItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.searchBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.designText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item['type'] ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.designMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 11,
                color: AppColors.designMutedLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
