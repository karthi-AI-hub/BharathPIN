import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post_office.dart';
import '../widgets/post_office_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final List<PostOffice> searchResults;
  final String searchQuery;
  final String searchType;
  const SearchResultsScreen({
    super.key,
    required this.searchResults,
    required this.searchQuery,
    required this.searchType,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with TickerProviderStateMixin {
  Map<String, bool> _expandedCards = {};
  String _sortBy = 'name'; // 'name', 'pincode', 'branchType'
  bool _showOnlyDeliveryOffices = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<PostOffice> get _filteredAndSortedResults {
    List<PostOffice> filtered = widget.searchResults;

    // Filter by delivery status if enabled
    if (_showOnlyDeliveryOffices) {
      filtered = filtered.where((po) => po.isDeliveryAvailable).toList();
    }

    // Sort results
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'pincode':
        filtered.sort((a, b) => a.pincode.compareTo(b.pincode));
        break;
      case 'branchType':
        filtered.sort((a, b) {
          if (a.isHeadPostOffice && !b.isHeadPostOffice) return -1;
          if (!a.isHeadPostOffice && b.isHeadPostOffice) return 1;
          if (a.isSubPostOffice && !b.isSubPostOffice) return -1;
          if (!a.isSubPostOffice && b.isSubPostOffice) return 1;
          return a.branchType.compareTo(b.branchType);
        });
        break;
    }

    return filtered;
  }

  // Get analytics for the results
  Map<String, dynamic> get _analytics {
    final results = widget.searchResults;
    final deliveryCount = results.where((po) => po.isDeliveryAvailable).length;
    final headOfficeCount = results.where((po) => po.isHeadPostOffice).length;
    final subOfficeCount = results.where((po) => po.isSubPostOffice).length;

    final uniqueDistricts = results.map((po) => po.district).toSet().length;
    final uniqueStates = results.map((po) => po.state).toSet().length;

    return {
      'total': results.length,
      'delivery': deliveryCount,
      'headOffices': headOfficeCount,
      'subOffices': subOfficeCount,
      'districts': uniqueDistricts,
      'states': uniqueStates,
    };
  }

  void _toggleCardExpanded(String cardKey) {
    setState(() {
      _expandedCards[cardKey] = !(_expandedCards[cardKey] ?? false);
    });
  }

  void _showSortBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB22222), Color(0xFF8B0000)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header with premium design
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB22222).withOpacity(0.1),
                    const Color(0xFFB22222).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFB22222).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB22222), Color(0xFF8B0000)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB22222).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sort & Filter Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customize your search results',
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
            ),
            const SizedBox(height: 24),

            // Sort options with modern design
            const Text(
              'Sort by:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),

            ...['name', 'pincode', 'branchType'].map((option) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: _sortBy == option
                        ? const LinearGradient(
                            colors: [Color(0xFFB22222), Color(0xFF8B0000)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    color: _sortBy == option ? null : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _sortBy == option
                          ? const Color(0xFFB22222)
                          : const Color(0xFFE9ECEF),
                    ),
                    boxShadow: _sortBy == option
                        ? [
                            BoxShadow(
                              color: const Color(0xFFB22222).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(
                          _getSortIcon(option),
                          color: _sortBy == option
                              ? Colors.white
                              : const Color(0xFF7F8C8D),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getSortOptionLabel(option),
                          style: TextStyle(
                            fontWeight: _sortBy == option
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: _sortBy == option
                                ? Colors.white
                                : const Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    value: option,
                    groupValue: _sortBy,
                    activeColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _sortBy = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )),

            const SizedBox(height: 24),

            // Filter options with premium design
            Container(
              decoration: BoxDecoration(
                gradient: _showOnlyDeliveryOffices
                    ? const LinearGradient(
                        colors: [Color(0xFF27AE60), Color(0xFF1E8449)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color:
                    _showOnlyDeliveryOffices ? null : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showOnlyDeliveryOffices
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE9ECEF),
                ),
                boxShadow: _showOnlyDeliveryOffices
                    ? [
                        BoxShadow(
                          color: const Color(0xFF27AE60).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: SwitchListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: _showOnlyDeliveryOffices
                          ? Colors.white
                          : const Color(0xFF7F8C8D),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Show only delivery offices',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _showOnlyDeliveryOffices
                              ? Colors.white
                              : const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    'Hide non-delivery post offices',
                    style: TextStyle(
                      color: _showOnlyDeliveryOffices
                          ? Colors.white70
                          : const Color(0xFF7F8C8D),
                    ),
                  ),
                ),
                value: _showOnlyDeliveryOffices,
                activeColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _showOnlyDeliveryOffices = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Reset button with premium design
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7F8C8D).withOpacity(0.1),
                    const Color(0xFF7F8C8D).withOpacity(0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7F8C8D).withOpacity(0.3),
                ),
              ),
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _sortBy = 'name';
                    _showOnlyDeliveryOffices = false;
                  });
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFF7F8C8D),
                  size: 20,
                ),
                label: const Text(
                  'Reset to Default',
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(String option) {
    switch (option) {
      case 'name':
        return Icons.sort_by_alpha;
      case 'pincode':
        return Icons.pin_drop;
      case 'branchType':
        return Icons.business;
      default:
        return Icons.sort;
    }
  }

  String _getSortOptionLabel(String option) {
    switch (option) {
      case 'name':
        return 'Post Office Name';
      case 'pincode':
        return 'PIN Code';
      case 'branchType':
        return 'Branch Type';
      default:
        return option;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredResults = _filteredAndSortedResults;
    final analytics = _analytics;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB22222),
                Color(0xFF8B0000),
                Color(0xFFB22222),
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  widget.searchType == 'pincode'
                      ? Icons.pin_drop
                      : Icons.business,
                  color: const Color(0xFFFFD700),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${widget.searchType == 'pincode' ? 'PIN: ' : 'Name: '}${widget.searchQuery}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: _showSortBottomSheet,
              tooltip: 'Sort & Filter',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
              Color(0xFFF1F3F4),
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: filteredResults.isEmpty
                ? _buildEmptyState()
                : _buildScrollableContent(
                    filteredResults, isWideScreen, screenWidth, analytics),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB22222), Color(0xFF8B0000)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB22222).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(
            Icons.search,
            color: Colors.white,
            size: 22,
          ),
          label: const Text(
            'New Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent(List<PostOffice> results, bool isWideScreen,
      double screenWidth, Map<String, dynamic> analytics) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: isWideScreen ? screenWidth * 0.1 : 16,
        right: isWideScreen ? screenWidth * 0.1 : 16,
        bottom: 100, // Space for FAB
        top: 8,
      ),
      itemCount: results.length + 1, // +1 for the analytics header
      itemBuilder: (context, index) {
        if (index == 0) {
          // Analytics Dashboard Card as first item
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFCFCFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header with search info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB22222), Color(0xFF8B0000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB22222).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Found ${analytics['total']} post office${analytics['total'] != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (results.length != analytics['total'])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFB8860B)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Showing ${results.length} filtered',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Text(
                                    'Across ${analytics['districts']} district${analytics['districts'] != 1 ? 's' : ''}, ${analytics['states']} state${analytics['states'] != 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (_showOnlyDeliveryOffices || _sortBy != 'name')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Filtered',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Statistics grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2C3E50).withOpacity(0.02),
                          const Color(0xFF2C3E50).withOpacity(0.01),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2C3E50).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            Icons.local_shipping,
                            '${analytics['delivery']}',
                            'Delivery',
                            const Color(0xFF27AE60),
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.business,
                            '${analytics['headOffices']}',
                            'Head Offices',
                            const Color(0xFF3498DB),
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.store,
                            '${analytics['subOffices']}',
                            'Sub Offices',
                            const Color(0xFF9B59B6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Post office cards (index - 1 because first item is header)
          final postOffice = results[index - 1];
          final cardKey = '${postOffice.name}_${postOffice.pincode}';
          return Container(
            margin: const EdgeInsets.only(bottom: 2),
            child: PostOfficeCard(
              postOffice: postOffice,
              isExpanded: _expandedCards[cardKey] ?? false,
              onToggleExpanded: () => _toggleCardExpanded(cardKey),
            ),
          );
        }
      },
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7F8C8D),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9800).withOpacity(0.1),
                    const Color(0xFFFF9800).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.search_off,
                size: 64,
                color: Color(0xFFFF9800),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No post offices match your current filter settings.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB22222), Color(0xFF8B0000)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB22222).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _showOnlyDeliveryOffices = false;
                    _sortBy = 'name';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.clear_all,
                  color: Colors.white,
                  size: 22,
                ),
                label: const Text(
                  'Clear All Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
