import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/progress_indicator.dart';
import 'landlord_listing_page.dart';

class LandlordProfilePage extends StatelessWidget {
  const LandlordProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(apiService: ApiService()),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFCFD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFCFD),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF212327)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Profile Setup',
            style: TextStyle(
              color: Color(0xFF212327),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ProgressIndicatorWidget(currentStep: 1, totalSteps: 3),
                        const SizedBox(height: 24),
                        
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Build your\n',
                                style: TextStyle(
                                  color: Color(0xFF212327),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.64,
                                ),
                              ),
                              TextSpan(
                                text: 'profile',
                                style: TextStyle(
                                  color: Color(0xFF7B5BF2),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.64,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'A great profile gets you 3× more matches.',
                          style: TextStyle(
                            color: Color(0xFF6E7681),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Profile Photo Section
                        _buildPhotoSection(viewModel),
                        const SizedBox(height: 32),

                        // Bio Section
                        _buildBioSection(viewModel),
                        const SizedBox(height: 24),

                        // Name Section
                        _buildNameSection(viewModel),
                        const SizedBox(height: 16),

                        // Contact Sections
                        _buildEmailSection(viewModel),
                        const SizedBox(height: 16),
                        _buildPhoneSection(viewModel),
                        const SizedBox(height: 32),

                        // Continue Button
                        _buildContinueButton(context, viewModel),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  
                  // Loading Overlay
                  if (viewModel.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B5BF2)),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(ProfileViewModel viewModel) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9E82F7), Color(0xFF6244D4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B5BF2).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: ClipOval(
                  child: viewModel.profilePhoto != null
                      ? Image.network(
                          viewModel.profilePhoto!,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 84,
                          height: 84,
                          color: Colors.white,
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: Color(0xFF7B5BF2),
                          ),
                        ),
                ),
              ),
            ),
            if (viewModel.profilePhoto == null)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerOptions(viewModel),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B5BF2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: const Color(0xFFFCFCFD),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B5BF2).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile photo',
                style: TextStyle(
                  color: Color(0xFF212327),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'A clear photo helps landlords and roommates feel confident about you.',
                style: TextStyle(
                  color: Color(0xFFB0B6BF),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions(ProfileViewModel viewModel) {
    viewModel.setProfilePhoto('https://via.placeholder.com/150');
  }

  Widget _buildBioSection(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BIO',
          style: TextStyle(
            color: Color(0xFF2F3237),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: viewModel.bioController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tell potential tenants about yourself, your properties, and your hosting style...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FULL NAME',
          style: TextStyle(
            color: Color(0xFF2F3237),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: viewModel.nameController,
            decoration: const InputDecoration(
              hintText: 'John Doe',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMAIL',
          style: TextStyle(
            color: Color(0xFF2F3237),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'john@example.com',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHONE',
          style: TextStyle(
            color: Color(0xFF2F3237),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: viewModel.phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+1 234 567 890',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, ProfileViewModel viewModel) {
    return CustomButton(
      text: 'Continue',
      onPressed: () async {
        final profile = await viewModel.submitProfile();
        if (profile != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LandlordListingPage(landlordId: profile.id),
            ),
          );
        } else if (viewModel.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      isPrimary: true,
    );
  }
}