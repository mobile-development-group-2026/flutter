import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '/../theme/colors.dart';
import '/../viewmodels/listing_viewmodel.dart';
import '/../viewmodels/roommate/roommate_viewmodel.dart';
import '/../models/listing.dart';
import '/../models/roommate_profile.dart';
import 'map_page.dart';
import 'property_detail_page.dart';
import 'roommate_detail_page.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '/../../models/user_session.dart';

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
      _cargarTodo();
    });
  }

  Future<void> _cargarTodo() async {
    final auth = ClerkAuth.of(context, listen: false);
    final tokenObj = await auth.sessionToken();
    final token = tokenObj?.jwt;
    if (token != null && mounted) {
      context.read<ListingViewModel>().loadLandlordListings(token);
      context.read<RoommateViewModel>().loadRoommates(token);
    }
  }

  Future<void> _cargarListings() async {
    final auth = ClerkAuth.of(context, listen: false);
    final tokenObj = await auth.sessionToken();
    final token = tokenObj?.jwt;
    if (token != null && mounted) {
      context.read<ListingViewModel>().loadLandlordListings(token);
    }
  }

  Future<void> _cargarRoommates() async {
    final auth = ClerkAuth.of(context, listen: false);
    final tokenObj = await auth.sessionToken();
    final token = tokenObj?.jwt;
    if (token != null && mounted) {
      context.read<RoommateViewModel>().loadRoommates(token);
    }
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
              child: _showHousing ? _buildHousingSection() : _buildRoommateSection(),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHousingSection() {
    return Consumer<ListingViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.landlordListings.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.purple500));
        }
        if (vm.errorMessage != null && vm.landlordListings.isEmpty) {
          return _buildErrorState(onRetry: _cargarListings);
        }
        if (vm.landlordListings.isEmpty) {
          return _buildEmptyState(
            icon: LucideIcons.searchX,
            message: 'There are no listings available',
            subtitle: 'Come back later (or pull to refresh)',
            onRefresh: _cargarListings,
          );
        }
        return _buildListings(vm);
      },
    );
  }

  Widget _buildRoommateSection() {
    return Consumer<RoommateViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.roommates.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.purple500));
        }
        if (vm.errorMessage == 'offline' && vm.roommates.isEmpty) {
          return _buildOfflineState(onRefresh: _cargarRoommates);
        }
        if (vm.errorMessage != null && vm.errorMessage != 'offline') {
          return _buildErrorState(onRetry: _cargarRoommates);
        }
        if (vm.roommates.isEmpty) {
          return _buildEmptyState(
            icon: LucideIcons.users,
            message: 'No roommates found',
            subtitle: 'Pull down to refresh',
            onRefresh: _cargarRoommates,
          );
        }
        return _buildRoommateList(vm);
      },
    );
  }

  Widget _buildListings(ListingViewModel vm) {
    final listings = vm.landlordListings;
    final isOfflineOnly = vm.errorMessage != null;
    return RefreshIndicator(
      color: AppColors.purple500,
      backgroundColor: Colors.white,
      onRefresh: _cargarListings,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: listings.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildListingSectionHeader(listings.length, isOfflineOnly);
          final listing = listings[index - 1];
          return _buildCompactCard(listing, vm);
        },
      ),
    );
  }

  Widget _buildListingSectionHeader(int count, bool isOfflineOnly) {
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
                decoration: const BoxDecoration(color: AppColors.purple500, shape: BoxShape.circle),
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
          if (isOfflineOnly)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.yellow500.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.wifiOff, size: 10, color: AppColors.yellow500),
                  const SizedBox(width: 3),
                  Text(
                    'Offline · Starred only',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.yellow500,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Icon(LucideIcons.house, size: 13, color: AppColors.neutral600),
                const SizedBox(width: 4),
                Text(
                  '$count available',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.neutral600),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(Listing listing, ListingViewModel vm) {
    final starred = vm.isStarred(listing.id.toString());
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailPage(listing: listing)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: starred
              ? Border.all(color: AppColors.yellow500.withValues(alpha: 0.6), width: 1.5)
              : null,
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
              child: Icon(LucideIcons.house, size: 28, color: AppColors.purple300),
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
                      GestureDetector(
                        onTap: () => vm.toggleStar(listing.id.toString()),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            starred ? Icons.star_rounded : Icons.star_border_rounded,
                            key: ValueKey(starred),
                            size: 20,
                            color: starred ? AppColors.yellow500 : AppColors.neutral400,
                          ),
                        ),
                      ),
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
                      Icon(LucideIcons.mapPin, size: 11, color: AppColors.neutral500),
                      const SizedBox(width: 3),
                      Text(
                        '${listing.city} · ${listing.leaseTermMonths} months',
                        style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.neutral600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(spacing: 4, children: _buildAmenityChips(listing, small: true)),
                ],
              ),
            ),
          ],
        ),
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
        padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 2 : 4),
        decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: BorderRadius.circular(100)),
        child: Text(
          label,
          style: TextStyle(fontFamily: 'Sora', fontSize: small ? 10 : 11, color: AppColors.neutral700),
        ),
      );
    }).toList();
  }

  Widget _buildRoommateList(RoommateViewModel vm) {
    final roommates = vm.roommates;
    return RefreshIndicator(
      color: AppColors.purple500,
      backgroundColor: Colors.white,
      onRefresh: _cargarRoommates,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: roommates.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildRoommateSectionHeader(roommates.length, vm);
          final roommate = roommates[index - 1];
          return _buildRoommateCard(roommate, vm);
        },
      ),
    );
  }

  Widget _buildRoommateSectionHeader(int count, RoommateViewModel vm) {
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
                decoration: const BoxDecoration(color: AppColors.purple500, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                'ROOMMATES NEAR YOU',
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
          if (vm.errorMessage == 'offline')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.yellow500.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.wifiOff, size: 10, color: AppColors.yellow500),
                  const SizedBox(width: 3),
                  Text(
                    'Offline · Starred only',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.yellow500),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Icon(LucideIcons.user, size: 13, color: AppColors.neutral600),
                const SizedBox(width: 4),
                Text(
                  '$count available',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.neutral600),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRoommateCard(RoommateProfile roommate, RoommateViewModel vm) {
    final starred = vm.isStarred(roommate.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: vm,
            child: RoommateDetailPage(roommate: roommate),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: starred
              ? Border.all(color: AppColors.yellow500.withValues(alpha: 0.6), width: 1.5)
              : null,
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
            _buildRoommateAvatar(roommate, size: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          roommate.fullName,
                          style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => vm.toggleStar(roommate.id),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            starred ? Icons.star_rounded : Icons.star_border_rounded,
                            key: ValueKey(starred),
                            size: 20,
                            color: starred ? AppColors.yellow500 : AppColors.neutral400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (roommate.university != null)
                    Row(
                      children: [
                        Icon(LucideIcons.graduationCap, size: 11, color: AppColors.neutral500),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            roommate.university!,
                            style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.neutral600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (roommate.bio != null && roommate.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      roommate.bio!,
                      style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.neutral600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildChip(
                        roommate.role == 'tenant' ? 'Tenant' : 'Landlord',
                        AppColors.purple100,
                        AppColors.purple700,
                      ),
                      const SizedBox(width: 4),
                      if (roommate.verified)
                        _buildChip('Verified ✓', AppColors.green500.withValues(alpha: 0.12), AppColors.green500),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoommateAvatar(RoommateProfile roommate, {double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.purple200),
      clipBehavior: Clip.antiAlias,
      child: roommate.profilePhoto != null && roommate.profilePhoto!.isNotEmpty
          ? Image.network(
              roommate.profilePhoto!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _avatarFallback(roommate, size),
            )
          : _avatarFallback(roommate, size),
    );
  }

  Widget _avatarFallback(RoommateProfile roommate, double size) {
    return Center(
      child: Text(
        roommate.initials,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: size * 0.28,
          fontWeight: FontWeight.w700,
          color: AppColors.purple600,
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(
        label,
        style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }

  Widget _buildOfflineState({required Future<void> Function() onRefresh}) {
    return RefreshIndicator(
      color: AppColors.purple500,
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.wifiOff, size: 44, color: AppColors.neutral400),
                  const SizedBox(height: 16),
                  Text(
                    'No internet connection',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.neutral700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Star items to see them offline',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.neutral500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '↓ Pull to retry',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.neutral400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.wifiOff, color: AppColors.neutral500, size: 40),
          const SizedBox(height: 12),
          Text(
            'Could not load content',
            style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(fontFamily: 'Sora', color: AppColors.purple500, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      color: AppColors.purple500,
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: AppColors.neutral400),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.neutral700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.neutral500),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: BorderRadius.circular(100)),
              child: Row(
                children: [
                  _tabOption(label: 'Roommate', icon: LucideIcons.user, isSelected: !_showHousing),
                  _tabOption(label: 'Housing', icon: LucideIcons.house, isSelected: _showHousing),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: BorderRadius.circular(12)),
            child: Icon(LucideIcons.slidersHorizontal, size: 18, color: AppColors.neutral700),
          ),
        ],
      ),
    );
  }

  Widget _tabOption({required String label, required IconData icon, required bool isSelected}) {
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
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.neutral600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(icon: LucideIcons.compass, label: 'Discover', isSelected: true),
          _navItem(
            icon: LucideIcons.map,
            label: 'Map',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage())),
          ),
          _navItem(icon: LucideIcons.clipboardList, label: 'Activity'),
          _navItem(icon: LucideIcons.messageCircle, label: 'Messages', badge: 3),
          _navItem(
            icon: LucideIcons.user,
            label: 'Profile',
            onTap: () async {
              await ClerkAuth.of(context, listen: false).signOut();
              if (!mounted) return;
              context.read<UserSession>().clear();
            },
          ),
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
              Icon(icon, size: 22, color: isSelected ? AppColors.purple500 : AppColors.neutral500),
              if (badge != null)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: AppColors.purple500, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '$badge',
                        style: const TextStyle(fontFamily: 'Sora', fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
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
              color: isSelected ? AppColors.purple500 : AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}