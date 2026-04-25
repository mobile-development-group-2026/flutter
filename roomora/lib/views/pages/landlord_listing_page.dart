import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:roomora/views/pages/Onboarding/onboarding_complete_page.dart';
import 'package:roomora/views/pages/discover_page.dart';
import '../../viewmodels/listing_viewmodel.dart';
import '../../services/api_service.dart';
import '../../services/listing_storage_service.dart';
import '../widgets/photo_upload_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/progress_indicator.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../pages/Onboarding/onboarding_complete_page.dart';

class LandlordListingPage extends StatefulWidget {
  final String landlordId;

  const LandlordListingPage({
    super.key,
    required this.landlordId,
  });

  @override
  State<LandlordListingPage> createState() => _LandlordListingPageState();
}

class _LandlordListingPageState extends State<LandlordListingPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<ListingViewModel>();
      
      await viewModel.loadCachedListings();

      if (!mounted) return;
      final auth = ClerkAuth.of(context, listen: false);
      final tokenObj = await auth.sessionToken();
      final token = tokenObj?.jwt ?? '';

      if (token.isNotEmpty) {
        await viewModel.loadLandlordListings(token);
      }
      _setupListeners(viewModel);
    });
  }

  void _setupListeners(ListingViewModel viewModel) {
    viewModel.titleController.addListener(() {
      viewModel.validateField('title', viewModel.titleController.text);
    });
    viewModel.descriptionController.addListener(() {
      viewModel.validateField('description', viewModel.descriptionController.text);
    });
    viewModel.rentController.addListener(() {
      viewModel.validateField('rent', viewModel.rentController.text);
    });
    viewModel.depositController.addListener(() {
      viewModel.validateField('deposit', viewModel.depositController.text);
    });
    viewModel.leaseLengthController.addListener(() {
      viewModel.validateField('leaseLength', viewModel.leaseLengthController.text);
    });
  }

  Future<void> _onPublishPressed() async {
    final viewModel = context.read<ListingViewModel>(); 
    
    if (!viewModel.validateForm()) {
      viewModel.showValidationAlert(context);
      return;
    }
    final auth = ClerkAuth.of(context, listen: false);
    final tokenObj = await auth.sessionToken();
    final token = tokenObj?.jwt ?? '';
    
    viewModel.submitListing(token).then((_) {
      if (mounted) {
        if (viewModel.currentListing != null) {
          _showSuccessDialog(context);
        } else if (viewModel.errorMessage != null) {
          _showErrorDialog(context, viewModel.errorMessage!);
        }
      }
    });
  }

  void _onAddPhoto(String path) {
    context.read<ListingViewModel>().showImageSourceOptions(context);
  }

  void _onRemovePhoto(String path) {
    context.read<ListingViewModel>().removePhoto(path);
  }

  void _onSetCover(String path) {
    context.read<ListingViewModel>().setCoverPhoto(path);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingViewModel>(
      builder: (context, viewModel, child) {
        return _buildContent(context, viewModel);
      },
    );
  }

  Widget _buildContent(BuildContext context, ListingViewModel viewModel) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212327)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Listing',
          style: TextStyle(
            color: Color(0xFF212327),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProgressIndicatorWidget(currentStep: 2, totalSteps: 3),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0ECFE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF7B5BF2).withValues(alpha: 0.3)),
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
                        '• Property title (5-100 characters)\n• Description (20-2000 characters)\n• Monthly rent (min \$100, max \$10,000)\n• Security deposit (max \$5,000)\n• Lease length (1-60 months)\n• Move-in date (within 1 year)\n• At least one photo\n• Property type\n• At least one amenity\n• At least one house rule',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6E7681)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'PHOTOS',
                  style: TextStyle(
                    color: Color(0xFF7B5BF2),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                StreamBuilder<List<String>>(
                  stream: viewModel.photosStream,
                  builder: (context, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhotoUploadWidget(
                          photos: snapshot.data ?? viewModel.photos,
                          coverPhoto: viewModel.coverPhoto,
                          onAddPhoto: _onAddPhoto,
                          onRemovePhoto: _onRemovePhoto,
                          onSetCover: _onSetCover,
                        ),
                        _buildErrorText(viewModel.fieldErrors['photos']),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),
                _buildDetailsSection(viewModel),
                const SizedBox(height: 24),
                _buildPropertyTypeSection(viewModel),
                const SizedBox(height: 24),
                _buildLeaseAndDateSection(context, viewModel),
                const SizedBox(height: 24),
                _buildAmenitiesSection(viewModel),
                const SizedBox(height: 24),
                _buildHouseRulesSection(viewModel),
                const SizedBox(height: 24),
                _buildDescriptionSection(viewModel),
                const SizedBox(height: 32),

                if (viewModel.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 16),

                CustomButton(
                  text: 'Publish Listing',
                  onPressed: _onPublishPressed,
                  isPrimary: true,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Save as Draft',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Draft saved'),
                        backgroundColor: Color(0xFF7B5BF2),
                      ),
                    );
                  },
                  isPrimary: false,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          StreamBuilder<String>(
            stream: viewModel.progressStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B5BF2)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            snapshot.data!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF212327),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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

  Widget _buildDetailsSection(ListingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PROPERTY TITLE',
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
          '5-100 characters. Describe your property briefly.',
          style: TextStyle(fontSize: 11, color: Color(0xFFB0B6BF)),
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
            controller: viewModel.titleController,
            decoration: const InputDecoration(
              hintText: 'e.g., Lovely studio near campus',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        _buildErrorText(viewModel.fieldErrors['title']),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'SECURITY DEPOSIT',
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
                  const SizedBox(height: 4),
                  const Text(
                    'Max \$5,000',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB0B6BF)),
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
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            '\$',
                            style: TextStyle(
                              color: Color(0xFF6E7681),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: viewModel.depositController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildErrorText(viewModel.fieldErrors['deposit']),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'MONTHLY RENT',
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
                  const SizedBox(height: 4),
                  const Text(
                    'Min \$100, Max \$10,000',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB0B6BF)),
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
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            '\$',
                            style: TextStyle(
                              color: Color(0xFF6E7681),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: viewModel.rentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildErrorText(viewModel.fieldErrors['rent']),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyTypeSection(ListingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PROPERTY TYPE',
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.propertyTypes.map((type) {
            final isSelected = viewModel.selectedPropertyType == type;
            return GestureDetector(
              onTap: () => viewModel.setPropertyType(type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7B5BF2) : const Color(0xFFF6F7F8),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF7B5BF2) : const Color(0xFFE4E7EC),
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6E7681),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        _buildErrorText(viewModel.fieldErrors['propertyType']),
      ],
    );
  }

  Widget _buildLeaseAndDateSection(BuildContext context, ListingViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'LEASE LENGTH',
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
              const SizedBox(height: 4),
              const Text(
                'Format: "12 months" (1-60 months)',
                style: TextStyle(fontSize: 11, color: Color(0xFFB0B6BF)),
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
                  controller: viewModel.leaseLengthController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 12 months',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              _buildErrorText(viewModel.fieldErrors['leaseLength']),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'AVAILABLE FROM',
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
              const SizedBox(height: 4),
              const Text(
                'Within 1 year from today',
                style: TextStyle(fontSize: 11, color: Color(0xFFB0B6BF)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: viewModel.moveInDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF7B5BF2),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null && mounted) {
                    viewModel.setMoveInDate(date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          viewModel.moveInDate != null
                              ? DateFormat('MMM dd, yyyy').format(viewModel.moveInDate!)
                              : 'Select date',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF212327),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Color(0xFF6E7681),
                      ),
                    ],
                  ),
                ),
              ),
              _buildErrorText(viewModel.fieldErrors['moveInDate']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(ListingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'AMENITIES',
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
        const SizedBox(height: 4),
        const Text(
          'Select at least one',
          style: TextStyle(fontSize: 11, color: Color(0xFFB0B6BF)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.amenitiesList.map((amenity) {
            final isSelected = viewModel.selectedAmenities.contains(amenity);
            return GestureDetector(
              onTap: () => viewModel.toggleAmenity(amenity),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7B5BF2) : const Color(0xFFF6F7F8),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF7B5BF2) : const Color(0xFFE4E7EC),
                  ),
                ),
                child: Text(
                  amenity,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6E7681),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        _buildErrorText(viewModel.fieldErrors['amenities']),
      ],
    );
  }

  Widget _buildHouseRulesSection(ListingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'NON-NEGOTIABLE RULES',
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
        const SizedBox(height: 4),
        const Text(
          'Select at least one',
          style: TextStyle(fontSize: 11, color: Color(0xFFB0B6BF)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.houseRulesList.map((rule) {
            final isSelected = viewModel.selectedHouseRules.contains(rule);
            return GestureDetector(
              onTap: () => viewModel.toggleHouseRule(rule),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFDDFFCC) : const Color(0xFFF6F7F8),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF69E052) : const Color(0xFFE4E7EC),
                  ),
                ),
                child: Text(
                  rule,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF166534) : const Color(0xFF6E7681),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        _buildErrorText(viewModel.fieldErrors['houseRules']),
      ],
    );
  }

  Widget _buildDescriptionSection(ListingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'DESCRIPTION',
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
        const SizedBox(height: 4),
        const Text(
          '20-2000 characters. Describe your property in detail.',
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
            controller: viewModel.descriptionController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Describe the location, layout, nearby amenities, etc.',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

 Widget _buildActionButtons(BuildContext context, ListingViewModel viewModel) {
    return Column(
      children: [
        CustomButton(
          text: 'Publish Listing',
          onPressed: () async {
            final auth = ClerkAuth.of(context, listen: false);
            final tokenObj = await auth.sessionToken();
            final token = tokenObj?.jwt;

            if (token != null) {
              final listing = await viewModel.submitListing(token);
              if (!context.mounted) return;

              if (listing != null) {
                _showSuccessDialog(context);
              } else if (viewModel.errorMessage != null) {
                _showErrorDialog(context, viewModel.errorMessage!);
              }
            } else {
              if (context.mounted) {
                _showErrorDialog(context, "Authentication error. Please log in again.");
              }
            }
          },
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Save as Draft',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Draft saved'),
                backgroundColor: Color(0xFF7B5BF2),
              ),
            );
          },
          isPrimary: false,
        ),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Success!'),
        content: const Text('Your listing has been created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              
              if (mounted) {
                final user = ClerkAuth.of(context, listen: false).user;
                final landlordName = user?.firstName ?? 'Landlord';
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OnboardingCompleteView(
                      firstName: landlordName,
                      role: 'landlord', 
                      onContinue: () {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (_) => const DiscoverPage())
                        );
                      },
                    ), 
                  ),
                  (route) => false, 
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7B5BF2),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7B5BF2),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}