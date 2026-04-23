import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '/../theme/colors.dart';
import '/../viewmodels/listing_viewmodel.dart';
import '/../models/listing.dart';
import 'map_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool _showHousing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingViewModel>().loadLandlordListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral200,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Consumer<ListingViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.purple500,
                      ),
                    );
                  }

                  if (vm.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.wifiOff,
                              color: AppColors.neutral500, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'No se pudieron cargar los listings',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => vm.loadLandlordListings(),
                            child: Text(
                              'Reintentar',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                color: AppColors.purple500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (vm.landlordListings.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildListings(vm.landlordListings);
                },
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  _tabOption(
                      label: 'Roommate',
                      icon: LucideIcons.user,
                      isSelected: !_showHousing),
                  _tabOption(
                      label: 'Housing',
                      icon: LucideIcons.house,
                      isSelected: _showHousing),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.slidersHorizontal,
                size: 18, color: AppColors.neutral700),
          ),
        ],
      ),
    );
  }

  Widget _tabOption({
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showHousing = label == 'Housing'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.purple500 : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.neutral600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListings(List<Listing> listings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildSectionHeader(listings.length);
        final listing = listings[index - 1];
        if (index == 1) return _buildFeaturedCard(listing);
        return _buildCompactCard(listing);
      },
    );
  }

  Widget _buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.purple500,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LISTINGS NEAR CAMPUS',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(LucideIcons.house, size: 13, color: AppColors.neutral600),
              const SizedBox(width: 4),
              Text(
                '$count available',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Listing listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.purple100,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(LucideIcons.house,
                      size: 48, color: AppColors.purple300),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.green500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified landlord',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${listing.rent.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        '/ month',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 10,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.yellow500.withValues(alpha: 0.95),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bolt, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Flash sale — 15% off first month',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Icon(LucideIcons.heart,
                        size: 20, color: AppColors.neutral400),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin,
                        size: 13, color: AppColors.neutral500),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.city}, ${listing.state}',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        color: AppColors.neutral600,
                      ),
                    ),
                    Text(
                      ' · ${listing.propertyType}',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _buildAmenityChips(listing),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Compatibility',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.purple700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: 0.87,
                            backgroundColor: AppColors.purple200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.purple500),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '87%',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.purple500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neutral400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Schedule visit',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Apply now →',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildCompactCard(Listing listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.house,
                size: 28, color: AppColors.purple300),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${listing.rent.toStringAsFixed(0)}/mo',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Icon(LucideIcons.heart,
                        size: 16, color: AppColors.neutral400),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  listing.title,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin,
                        size: 11, color: AppColors.neutral500),
                    const SizedBox(width: 3),
                    Text(
                      '${listing.city} · ${listing.leaseTermMonths} months',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: _buildAmenityChips(listing, small: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAmenityChips(Listing listing, {bool small = false}) {
    final chips = <String>[];
    if (!listing.smokingAllowed) chips.add('No smoking');
    if (!listing.petsAllowed) chips.add('No pets');
    if (!listing.partiesAllowed) chips.add('No parties');
    if (listing.utilitiesIncluded) chips.add('Utilities incl.');
    chips.add('${listing.bedrooms}BR');

    return chips.take(small ? 3 : 4).map((label) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8,
          vertical: small ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: small ? 10 : 11,
            color: AppColors.neutral700,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.searchX, size: 48, color: AppColors.neutral400),
          const SizedBox(height: 16),
          Text(
            'No hay listings disponibles',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve más tarde',
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

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: LucideIcons.compass,
            label: 'Discover',
            isSelected: true,
          ),
          _navItem(
            icon: LucideIcons.map,
            label: 'Map',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapPage()),
            ),
          ),
          _navItem(icon: LucideIcons.clipboardList, label: 'Activity'),
          _navItem(
              icon: LucideIcons.messageCircle, label: 'Messages', badge: 3),
          _navItem(icon: LucideIcons.user, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    int? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.purple500 : AppColors.neutral500,
              ),
              if (badge != null)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.purple500,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected ? AppColors.purple500 : AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}