import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/listing_viewmodel.dart';
import '../../services/api_service.dart';
import '../../services/listing_storage_service.dart';
import '../widgets/photo_upload_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/progress_indicator.dart';

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
    Future.microtask(() {
      final viewModel = Provider.of<ListingViewModel>(context, listen: false);
      viewModel.loadCachedListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListingViewModel(
        apiService: ApiService(),
        storageService: ListingStorageService(),
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
            'Create Listing',
            style: TextStyle(
              color: Color(0xFF212327),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<ListingViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProgressIndicatorWidget(currentStep: 2, totalSteps: 3),
                      const SizedBox(height: 24),
                      
                      StreamBuilder<String>(
                        stream: viewModel.progressStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7B5BF2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B5BF2)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      snapshot.data!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7B5BF2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      StreamBuilder<List<String>>(
                        stream: viewModel.photosStream,
                        builder: (context, snapshot) {
                          return PhotoUploadWidget(
                            photos: snapshot.data ?? viewModel.photos,
                            coverPhoto: viewModel.coverPhoto,
                            onAddPhoto: (path) => viewModel.addPhoto(path),
                            onRemovePhoto: (path) => viewModel.removePhoto(path),
                            onSetCover: (path) => viewModel.setCoverPhoto(path),
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
                      
                      _buildActionButtons(context, viewModel),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                
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
    );
  }

  Widget _buildDetailsSection(ListingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DETAILS',
          style: TextStyle(
            color: Color(0xFF6E7681),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        
        const Text(
          'PROPERTY TITLE',
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
            controller: viewModel.titleController,
            decoration: const InputDecoration(
              hintText: 'e.g., Lovely studio near campus',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SECURITY DEPOSIT',
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
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MONTHLY RENT',
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
        const Text(
          'PROPERTY TYPE',
          style: TextStyle(
            color: Color(0xFF2F3237),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
              const Text(
                'LEASE LENGTH',
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
                  controller: viewModel.leaseLengthController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 12 months',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AVAILABLE FROM',
                style: TextStyle(
                  color: Color(0xFF2F3237),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
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
                  if (date != null) {
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
                        color: Colors.black.withOpacity(0.02),
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
        const Text(
          'AMENITIES',
          style: TextStyle(
            color: Color(0xFF2F3237),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
      ],
    );
  }

  Widget _buildHouseRulesSection(ListingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NON-NEGOTIABLE RULES',
          style: TextStyle(
            color: Color(0xFF2F3237),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
      ],
    );
  }

  Widget _buildDescriptionSection(ListingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DESCRIPTION',
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
            controller: viewModel.descriptionController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Describe your property, the neighborhood, nearby amenities, etc.',
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
            final listing = await viewModel.submitListing();
            if (listing != null) {
              _showSuccessDialog(context);
            } else if (viewModel.errorMessage != null) {
              _showErrorDialog(context, viewModel.errorMessage!);
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Success!'),
        content: const Text('Your listing has been created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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