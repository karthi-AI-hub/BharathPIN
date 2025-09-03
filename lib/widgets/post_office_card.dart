import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post_office.dart';
import '../services/favorites_service.dart';

class PostOfficeCard extends StatefulWidget {
  final PostOffice postOffice;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const PostOfficeCard({
    super.key,
    required this.postOffice,
    this.isExpanded = false,
    this.onToggleExpanded,
  });

  @override
  State<PostOfficeCard> createState() => _PostOfficeCardState();
}

class _PostOfficeCardState extends State<PostOfficeCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await FavoritesService.isFavorite(widget.postOffice);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();

    try {
      if (_isFavorite) {
        await FavoritesService.removeFromFavorites(widget.postOffice);
        if (mounted) {
          setState(() {
            _isFavorite = false;
          });
          _showFavoriteSnackBar('Removed from favorites', false);
        }
      } else {
        await FavoritesService.addToFavorites(widget.postOffice);
        if (mounted) {
          setState(() {
            _isFavorite = true;
          });
          _showFavoriteSnackBar('Added to favorites', true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Failed to update favorites');
      }
    }
  }

  void _showFavoriteSnackBar(String message, bool isAdded) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAdded ? Icons.favorite : Icons.favorite_border,
                color:
                    isAdded ? const Color(0xFFE91E63) : const Color(0xFF7F8C8D),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isAdded ? const Color(0xFFE91E63) : const Color(0xFF7F8C8D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF27AE60),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label copied successfully!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF27AE60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _openMap(BuildContext context) async {
    HapticFeedback.lightImpact();
    final query = Uri.encodeComponent(
        '${widget.postOffice.name}, ${widget.postOffice.district}, ${widget.postOffice.state}, ${widget.postOffice.pincode}');

    // Try different map launching strategies
    final mapOptions = [
      // Direct Google Maps URL (most reliable)
      () async {
        final url =
            Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return true;
        } catch (e) {
          return false;
        }
      },

      // Try Google Maps intent
      () async {
        final url = Uri.parse('google.navigation:q=$query');
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return true;
        } catch (e) {
          return false;
        }
      },

      // Try generic geo intent
      () async {
        final url = Uri.parse('geo:0,0?q=$query');
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return true;
        } catch (e) {
          return false;
        }
      },

      // Fallback to in-app browser
      () async {
        final url =
            Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
        try {
          await launchUrl(url, mode: LaunchMode.inAppBrowserView);
          return true;
        } catch (e) {
          return false;
        }
      },
    ];

    bool launched = false;

    for (final mapOption in mapOptions) {
      try {
        if (await mapOption()) {
          launched = true;
          if (context.mounted) {
            _showSuccessSnackBar(context, 'Opening map location...');
          }
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched && context.mounted) {
      _showErrorSnackBar(context, 'Could not open maps application');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFB22222),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.map, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFFCFCFC),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFE9ECEF),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),

                const SizedBox(height: 16),

                // Status and Type Section
                _buildStatusSection(),

                const SizedBox(height: 16),

                // Location Information
                _buildLocationInfo(),

                // Expanded Administrative Details
                if (widget.isExpanded) ...[
                  const SizedBox(height: 16),
                  _buildExpandedDetails(),
                ],

                const SizedBox(height: 20),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Post Office Icon with gradient background
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFB22222).withOpacity(0.1),
                const Color(0xFFB22222).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB22222).withOpacity(0.2),
            ),
          ),
          child: Icon(
            widget.postOffice.isHeadPostOffice
                ? Icons.business
                : widget.postOffice.isSubPostOffice
                    ? Icons.store
                    : Icons.local_post_office,
            color: const Color(0xFFB22222),
            size: 24,
          ),
        ),

        const SizedBox(width: 16),

        // Post Office Name and Pincode
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row: Name and Expand/Collapse Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.postOffice.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onToggleExpanded?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F8C8D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color(0xFF7F8C8D),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB22222), Color(0xFF8B0000)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB22222).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pin_drop,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.postOffice.pincode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (BuildContext ctx) => GestureDetector(
                      onTap: () => _copyToClipboard(
                        ctx,
                        widget.postOffice.pincode,
                        'PIN Code',
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB22222).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFB22222).withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.copy,
                          size: 16,
                          color: Color(0xFFB22222),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Row(
      children: [
        // Delivery Status
        Flexible(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.postOffice.isDeliveryAvailable
                    ? [const Color(0xFF27AE60), const Color(0xFF1E8449)]
                    : [const Color(0xFFFF9800), const Color(0xFFE67E22)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (widget.postOffice.isDeliveryAvailable
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFFF9800))
                      .withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.postOffice.isDeliveryAvailable
                      ? Icons.local_shipping
                      : Icons.warning_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.postOffice.deliveryStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Branch Type
        Flexible(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _getBranchTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBranchTypeColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getBranchTypeIcon(),
                  size: 16,
                  color: _getBranchTypeColor(),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.postOffice.branchType,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getBranchTypeColor(),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C3E50).withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
              Icons.location_city, 'District', widget.postOffice.district),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.map, 'State', widget.postOffice.state),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.08),
            const Color(0xFFFFD700).withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Administrative Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if ((widget.postOffice.division ?? '').isNotEmpty)
            _buildInfoRow(
                Icons.business, 'Division', widget.postOffice.division!),
          if ((widget.postOffice.circle ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.account_balance, 'Circle', widget.postOffice.circle!),
          ],
          if ((widget.postOffice.region ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.location_on, 'Region', widget.postOffice.region!),
          ],
          if ((widget.postOffice.block ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.domain, 'Block', widget.postOffice.block!),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // First row: Copy Address and Favorites buttons
        Row(
          children: [
            // Copy Address Button
            Expanded(
              flex: 2,
              child: Container(
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
                child: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => _copyToClipboard(
                      context,
                      widget.postOffice.fullAddress,
                      'Full Address',
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy,
                          size: 18,
                          color: Color(0xFF7F8C8D),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Copy',
                            style: const TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Favorites Button
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isFavorite
                        ? [
                            const Color(0xFFE91E63).withOpacity(0.1),
                            const Color(0xFFE91E63).withOpacity(0.05),
                          ]
                        : [
                            const Color(0xFF7F8C8D).withOpacity(0.1),
                            const Color(0xFF7F8C8D).withOpacity(0.05),
                          ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isFavorite
                        ? const Color(0xFFE91E63).withOpacity(0.3)
                        : const Color(0xFF7F8C8D).withOpacity(0.3),
                  ),
                ),
                child: TextButton(
                  onPressed: _toggleFavorite,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: _isFavorite
                            ? const Color(0xFFE91E63)
                            : const Color(0xFF7F8C8D),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _isFavorite ? 'Saved' : 'Save',
                          style: TextStyle(
                            color: _isFavorite
                                ? const Color(0xFFE91E63)
                                : const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second row: Full width Open Map button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB22222), Color(0xFF8B0000)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB22222).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Builder(
            builder: (context) => ElevatedButton.icon(
              onPressed: () => _openMap(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.map,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                'Open in Maps',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getBranchTypeColor() {
    if (widget.postOffice.isHeadPostOffice) return const Color(0xFF3498DB);
    if (widget.postOffice.isSubPostOffice) return const Color(0xFF9B59B6);
    return const Color(0xFF7F8C8D);
  }

  IconData _getBranchTypeIcon() {
    if (widget.postOffice.isHeadPostOffice) return Icons.business;
    if (widget.postOffice.isSubPostOffice) return Icons.store;
    return Icons.local_post_office;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
