import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '/../theme/colors.dart';
import '/../models/roommate_profile.dart';
import '/../viewmodels/roommate/roommate_viewmodel.dart';

class RoommateDetailPage extends StatelessWidget {
  final RoommateProfile roommate;

  const RoommateDetailPage({super.key, required this.roommate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral200,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  const SizedBox(height: 16),
                  if (roommate.bio != null && roommate.bio!.isNotEmpty)
                    _buildBioCard(),
                  if (roommate.bio != null && roommate.bio!.isNotEmpty)
                    const SizedBox(height: 16),
                  _buildDetailsCard(),
                  const SizedBox(height: 24),
                  _buildContactButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.purple500,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        Consumer<RoommateViewModel>(
          builder: (context, vm, _) {
            final starred = vm.isStarred(roommate.id);
            return GestureDetector(
              onTap: () => vm.toggleStar(roommate.id),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    starred ? Icons.star_rounded : Icons.star_border_rounded,
                    color: starred ? AppColors.yellow500 : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.purple600, AppColors.purple500],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              _buildAvatar(size: 90),
              const SizedBox(height: 12),
              Text(
                roommate.fullName,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (roommate.university != null) ...[
                    Icon(LucideIcons.graduationCap,
                        size: 13, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      roommate.university!,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({double size = 60}) {
    if (roommate.profilePhoto != null && roommate.profilePhoto!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(roommate.profilePhoto!),
        onBackgroundImageError: (_, __) {},
        backgroundColor: AppColors.purple300,
        child: roommate.profilePhoto == null
            ? Text(roommate.initials,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ))
            : null,
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.purple300,
      child: Text(
        roommate.initials,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: size * 0.3,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
              icon: LucideIcons.user,
              label: 'Role',
              value: roommate.role == 'tenant' ? 'Tenant' : 'Landlord'),
          _buildDivider(),
          _buildStatItem(
              icon: LucideIcons.circleCheck,
              label: 'Status',
              value: roommate.verified ? 'Verified' : 'Unverified',
              valueColor:
                  roommate.verified ? AppColors.green500 : AppColors.neutral500),
          _buildDivider(),
          _buildStatItem(
              icon: LucideIcons.calendar,
              label: 'Member since',
              value: _formatDate(roommate.createdAt)),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.purple500),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.neutral200,
    );
  }

  Widget _buildBioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileText, size: 16, color: AppColors.purple500),
              const SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            roommate.bio!,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              color: AppColors.neutral700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.info, size: 16, color: AppColors.purple500),
              const SizedBox(width: 8),
              Text(
                'Details',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (roommate.university != null)
            _buildDetailRow(LucideIcons.graduationCap, 'University', roommate.university!),
          _buildDetailRow(LucideIcons.mail, 'Email', roommate.email),
          if (roommate.role.isNotEmpty)
            _buildDetailRow(LucideIcons.user, 'Looking as', roommate.role == 'tenant' ? 'Tenant' : 'Landlord'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.neutral500),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              color: AppColors.neutral600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(LucideIcons.messageCircle, size: 18),
        label: const Text(
          'Send message',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple500,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}