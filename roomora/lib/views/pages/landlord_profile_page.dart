import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../viewmodels/profile_viewmodel.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/cached_profile_image.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'landlord_listing_page.dart';

class LandlordProfilePage extends StatefulWidget {
  const LandlordProfilePage({super.key});

  @override
  State<LandlordProfilePage> createState() => _LandlordProfilePageState();
}

class _LandlordProfilePageState extends State<LandlordProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      viewModel.loadCachedProfile();
      final user = ClerkAuth.of(context, listen: false).user;
      final emails = user?.emailAddresses;
      if (emails != null && emails.isNotEmpty) {
        final primaryEmailObj = emails.firstWhere(
          (email) => email.id == user!.primaryEmailAddressId,
          orElse: () => emails.first,
        );
        viewModel.emailController.text = primaryEmailObj.emailAddress;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        apiService: ApiService(),
        storageService: LocalStorageService(),
      ),
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
        body: Consumer<ProfileViewModel>(
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
                      
                      if (!viewModel.isOnline)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'You are offline. Changes will be saved locally and synced when connection is restored.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0ECFE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF7B5BF2).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Required Fields',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7B5BF2),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• Full name\n• Email address\n• Phone number\n• Bio (minimum 20 characters)\n• Profile photo',
                              style: TextStyle(fontSize: 12, color: Color(0xFF6E7681)),
                            ),
                          ],
                        ),
                      ),
                      
                      _buildPhotoSection(context, viewModel),
                      const SizedBox(height: 32),
                      _buildBioSection(viewModel),
                      const SizedBox(height: 24),
                      _buildNameSection(viewModel),
                      const SizedBox(height: 16),
                      _buildEmailSection(viewModel),
                      const SizedBox(height: 16),
                      _buildPhoneSection(viewModel),
                      const SizedBox(height: 32),
                      
                      if (viewModel.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      _buildContinueButton(viewModel),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
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
    );
  }

  Widget _buildErrorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 14, color: Colors.red.shade700),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              error,
              style: TextStyle(fontSize: 11, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PROFILE PHOTO',
              style: TextStyle(
                color: Color(0xFF7B5BF2),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () => viewModel.showImageSourceOptions(context),
              child: Stack(
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
                          color: const Color(0xFF7B5BF2).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: viewModel.profilePhoto != null
                          ? (viewModel.selectedImage != null
                              ? Image.file(
                                  File(viewModel.selectedImage!.path),
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                )
                              : CachedProfileImage(
                                  imageUrl: viewModel.profilePhoto!,
                                  width: 84,
                                  height: 84,
                                ))
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
                  if (viewModel.profilePhoto == null)
                    Positioned(
                      bottom: 0,
                      right: 0,
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
                              color: const Color(0xFF7B5BF2).withValues(alpha: 0.4),
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
                ],
              ),
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
        ),
        _buildErrorText(viewModel.fieldErrors['photo']),
      ],
    );
  }

  Widget _buildBioSection(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'BIO',
              style: TextStyle(
                color: Color(0xFF7B5BF2),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Minimum 20 characters. Tell us about yourself and your properties.',
          style: TextStyle(fontSize: 11, color: Color(0xFFB0B6BF)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: viewModel.bioController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tell potential tenants about yourself...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        _buildErrorText(viewModel.fieldErrors['bio']),
      ],
    );
  }

  Widget _buildNameSection(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'FULL NAME',
              style: TextStyle(
                color: Color(0xFF7B5BF2),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
        _buildErrorText(viewModel.fieldErrors['name']),
      ],
    );
  }

  Widget _buildEmailSection(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'EMAIL',
              style: TextStyle(
                color: Color(0xFF7B5BF2),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.lock_outline, size: 12, color: Color(0xFFB0B6BF)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F8), // 👈 Fondo gris claro
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: TextField(
            controller: viewModel.emailController,
            readOnly: true,
            style: const TextStyle(color: Color(0xFF6E7681)),
            decoration: const InputDecoration(
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
        Row(
          children: [
            const Text(
              'PHONE',
              style: TextStyle(
                color: Color(0xFF7B5BF2),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
        _buildErrorText(viewModel.fieldErrors['phone']),
      ],
    );
  }

  void _navigateToListingPage(String landlordId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LandlordListingPage(landlordId: landlordId),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildContinueButton(ProfileViewModel viewModel) {
    return CustomButton(
      text: 'Continue',
      isPrimary: true,
      onPressed: () async {
        if (!viewModel.validateForm()) {
          viewModel.showValidationAlert(context);
          return;
        }

        print('Boton Continue presionado');
        final auth = ClerkAuth.of(context, listen: false);
        final tokenObj = await auth.sessionToken();
        final token = tokenObj?.jwt;

        if (token != null) {
          final profile = await viewModel.submitProfile(token);
          if (!context.mounted) return;

          if (profile != null) {
            print('Perfil creado, navegando...');
            _navigateToListingPage(profile.id.toString());
          } else if (viewModel.errorMessage != null) {
            print('Error: ${viewModel.errorMessage}');
            _showErrorSnackBar(viewModel.errorMessage!);
          }
        } else {
          if (context.mounted) {
            _showErrorSnackBar('Error de sesión. Por favor, volvé a ingresar.');
          }
        }
      },
    );
  }
}
