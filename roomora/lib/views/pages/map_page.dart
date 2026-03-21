import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '/../theme/colors.dart';
import '/../viewmodels/map_viewmodel.dart';
import '/../services/models/api_listing.dart';
import '/../utils/location_calculator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<MapViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purple500),
            );
          }

          return Stack(
            children: [
              _buildMap(vm),
              _buildTopBar(vm),
              _buildDistanceFilter(vm),
              if (vm.selectedListing != null) _buildListingPreview(vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(MapViewModel vm) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: vm.mapCenter,
        initialZoom: 14,
        onTap: (_, __) => vm.selectListing(null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.roomora',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: vm.campusLocation,
              radius: vm.distanceFilter,
              useRadiusInMeter: true,
              color: AppColors.purple500.withValues(alpha: 0.08),
              borderColor: AppColors.purple500.withValues(alpha: 0.3),
              borderStrokeWidth: 1.5,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: vm.campusLocation,
              width: 40,
              height: 40,
              child: _buildCampusMarker(),
            ),
            if (vm.currentPosition != null)
              Marker(
                point: LatLng(
                  vm.currentPosition!.latitude,
                  vm.currentPosition!.longitude,
                ),
                width: 20,
                height: 20,
                child: _buildUserMarker(),
              ),
            ...vm.filteredListings.map((listing) {
              if (listing.latitude == 0 && listing.longitude == 0) {
                return Marker(
                  point: LatLng(
                    vm.campusLocation.latitude + (vm.filteredListings.indexOf(listing) * 0.002),
                    vm.campusLocation.longitude + (vm.filteredListings.indexOf(listing) * 0.002),
                  ),
                  width: 80,
                  height: 40,
                  child: _buildListingMarker(listing, vm),
                );
              }
              return Marker(
                point: LatLng(listing.latitude, listing.longitude),
                width: 80,
                height: 40,
                child: _buildListingMarker(listing, vm),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCampusMarker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.purple500,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple500.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 18),
    );
  }

  Widget _buildUserMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildListingMarker(ApiListing listing, MapViewModel vm) {
    final isSelected = vm.selectedListing?.id == listing.id;
    return GestureDetector(
      onTap: () {
        vm.selectListing(listing);
        final point = listing.latitude == 0
            ? LatLng(
                vm.campusLocation.latitude + (vm.filteredListings.indexOf(listing) * 0.002),
                vm.campusLocation.longitude + (vm.filteredListings.indexOf(listing) * 0.002),
              )
            : LatLng(listing.latitude, listing.longitude);
        _mapController.move(point, 15);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple500 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '\$${listing.rent.toStringAsFixed(0)}',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.neutral900,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(MapViewModel vm) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.neutral900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.search, size: 16, color: AppColors.neutral500),
                      const SizedBox(width: 8),
                      Text(
                        'Search area...',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${vm.filteredListings.length}',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceFilter(MapViewModel vm) {
    return Positioned(
      bottom: vm.selectedListing != null ? 220 : 24,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 14, color: AppColors.purple500),
                    const SizedBox(width: 6),
                    Text(
                      'Distance from campus',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    LocationCalculator.formatDistance(vm.distanceFilter),
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple600,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.purple500,
                inactiveTrackColor: AppColors.neutral300,
                thumbColor: AppColors.purple500,
                overlayColor: AppColors.purple500.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: vm.distanceFilter,
                min: 300,
                max: 3000,
                divisions: 9,
                onChanged: (value) => vm.setDistanceFilter(value),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('300m', style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.neutral500)),
                Text('~5min walk', style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.neutral500)),
                Text('3km', style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.neutral500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingPreview(MapViewModel vm) {
    final listing = vm.selectedListing!;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral900,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => vm.selectListing(null),
                            child: Icon(LucideIcons.x, size: 18, color: AppColors.neutral500),
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
                          Icon(LucideIcons.mapPin, size: 12, color: AppColors.neutral500),
                          const SizedBox(width: 3),
                          Text(
                            '${listing.city}, ${listing.state}',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 11,
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(LucideIcons.footprints, size: 12, color: AppColors.green500),
                          const SizedBox(width: 3),
                          Text(
                            vm.getWalkingTime(listing),
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'View details',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
    );
  }
}