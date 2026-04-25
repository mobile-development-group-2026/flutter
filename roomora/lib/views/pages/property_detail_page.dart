import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../theme/colors.dart';
import '../../models/listing.dart';
import '../../services/api_service.dart';
import '../../viewmodels/property_detail_viewmodel.dart';

class PropertyDetailPage extends StatelessWidget {
  final Listing listing;

  const PropertyDetailPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyDetailViewModel(apiService: ApiService()),
      child: _PropertyDetailView(listing: listing),
    );
  }
}

class _PropertyDetailView extends StatefulWidget {
  final Listing listing;
  const _PropertyDetailView({required this.listing});

  @override
  State<_PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<_PropertyDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = ClerkAuth.of(context, listen: false);
      final tokenObj = await auth.sessionToken();
      final token = tokenObj?.jwt;
      if (token != null && mounted) {
        context
            .read<PropertyDetailViewModel>()
            .initWithListing(widget.listing, token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyDetailViewModel>(
      builder: (context, vm, _) {
        final listing = vm.listing ?? widget.listing;
        return Scaffold(
          backgroundColor: AppColors.neutral200,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, listing, vm),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainInfo(listing),
                    _buildDivider(),
                    _buildDetails(listing),
                    _buildDivider(),
                    _buildRules(listing),
                    _buildDivider(),
                    _buildDescription(listing),
                    _buildDivider(),
                    _buildLandlordCard(vm),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, listing, vm),
        );
      },
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    Listing listing,
    PropertyDetailViewModel vm,
  ) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.neutral100,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(LucideIcons.arrowLeft,
              size: 18, color: AppColors.neutral900),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: vm.toggleSaved,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              vm.isSaved ? LucideIcons.heart : LucideIcons.heart,
              size: 18,
              color: vm.isSaved ? AppColors.red400 : AppColors.neutral700,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.purple100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(LucideIcons.house, size: 72, color: AppColors.purple300),
                const SizedBox(height: 8),
                Text(
                  listing.propertyType,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    color: AppColors.purple500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo(Listing listing) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge "Verified landlord"
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green100,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.green500,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Verified landlord',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Título
          Text(
            listing.title,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 6),

          // Dirección
          Row(
            children: [
              const Icon(LucideIcons.mapPin,
                  size: 13, color: AppColors.neutral500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${listing.address}, ${listing.city}, ${listing.state} ${listing.zipCode}',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Precio principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${listing.rent.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              const Text(
                '/mo',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  color: AppColors.neutral600,
                ),
              ),
              const Spacer(),
              // Chips de habitaciones/baños
              _smallChip(
                  LucideIcons.bedDouble, '${listing.bedrooms} bed'),
              const SizedBox(width: 6),
              _smallChip(
                  LucideIcons.bath, '${listing.bathrooms} bath'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(Listing listing) {
    final deposit = listing.securityDeposit > 0
        ? '\$${listing.securityDeposit.toStringAsFixed(0)}'
        : 'N/A';

    final utilText = listing.utilitiesIncluded
        ? 'Included'
        : listing.utilitiesCost != null
            ? '+\$${listing.utilitiesCost!.toStringAsFixed(0)}/mo'
            : 'Not included';

    final available =
        '${listing.availableDate.month}/${listing.availableDate.day}/${listing.availableDate.year}';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Details'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _detailTile(
                      LucideIcons.calendarDays, 'Available', available)),
              Expanded(
                  child: _detailTile(
                      LucideIcons.clock, 'Lease', '${listing.leaseTermMonths} mo')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _detailTile(
                      LucideIcons.shield, 'Deposit', deposit)),
              Expanded(
                  child: _detailTile(
                      LucideIcons.zap, 'Utilities', utilText)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _detailTile(LucideIcons.house, 'Type',
                      _capitalize(listing.propertyType))),
              Expanded(
                  child: _detailTile(LucideIcons.users, 'Listing',
                      _capitalize(listing.listingType))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRules(Listing listing) {
    final rules = <Map<String, dynamic>>[
      {
        'icon': LucideIcons.pawPrint,
        'label': 'Pets',
        'allowed': listing.petsAllowed,
      },
      {
        'icon': LucideIcons.partyPopper,
        'label': 'Parties',
        'allowed': listing.partiesAllowed,
      },
      {
        'icon': LucideIcons.cigarette,
        'label': 'Smoking',
        'allowed': listing.smokingAllowed,
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('House Rules'),
          const SizedBox(height: 16),
          Row(
            children: rules
                .map((r) => Expanded(child: _ruleChip(r)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Listing listing) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('About this place'),
          const SizedBox(height: 10),
          Text(
            listing.description.isNotEmpty
                ? listing.description
                : 'No description provided.',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              height: 1.6,
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandlordCard(PropertyDetailViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Listed by'),
          const SizedBox(height: 14),
          if (vm.isLoadingProfile)
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.purple500,
                ),
              ),
            )
          else if (vm.landlordProfile != null)
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.purple100,
                  backgroundImage: vm.landlordProfile!.profilePhoto != null
                      ? NetworkImage(vm.landlordProfile!.profilePhoto!)
                      : null,
                  child: vm.landlordProfile!.profilePhoto == null
                      ? Text(
                          vm.landlordProfile!.firstName.isNotEmpty
                              ? vm.landlordProfile!.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple500,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            vm.landlordProfile!.fullName,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                          if (vm.landlordProfile!.verified) ...[
                            const SizedBox(width: 6),
                            const Icon(LucideIcons.badgeCheck,
                                size: 15, color: AppColors.purple500),
                          ],
                        ],
                      ),
                      if (vm.landlordProfile!.university != null)
                        Text(
                          vm.landlordProfile!.university!,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            color: AppColors.neutral600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          else
            Text(
              'Landlord info not available',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                color: AppColors.neutral500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    Listing listing,
    PropertyDetailViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${listing.rent.toStringAsFixed(0)}/mo',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                'Deposit: \$${listing.securityDeposit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact information coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.purple500,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.messageCircle,
                        size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Contact Landlord',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(height: 8, color: AppColors.neutral200);

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
        ),
      );

  Widget _smallChip(IconData icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.neutral700),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral800,
              ),
            ),
          ],
        ),
      );

  Widget _detailTile(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.purple500),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  color: AppColors.neutral500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _ruleChip(Map<String, dynamic> rule) {
    final allowed = rule['allowed'] as bool;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: allowed ? AppColors.green100 : AppColors.red100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            rule['icon'] as IconData,
            size: 20,
            color: allowed ? AppColors.green600 : AppColors.red400,
          ),
          const SizedBox(height: 4),
          Text(
            rule['label'] as String,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: allowed ? AppColors.green700 : AppColors.red500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            allowed ? 'OK' : 'No',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              color: allowed ? AppColors.green600 : AppColors.red400,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}