import 'package:flutter/material.dart';
import 'dart:io';

class PhotoUploadWidget extends StatelessWidget {
  final List<String> photos;
  final String? coverPhoto;
  final Function(String) onAddPhoto;
  final Function(String) onRemovePhoto;
  final Function(String) onSetCover;

  const PhotoUploadWidget({
    super.key,
    required this.photos,
    required this.coverPhoto,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.onSetCover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PHOTOS',
              style: TextStyle(
                color: Color(0xFF6E7681),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: const Color(0xFFE4E7EC),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (photos.isEmpty)
          _buildEmptyState()
        else
          _buildPhotoGrid(),
          
        const SizedBox(height: 12),
        
        if (photos.isNotEmpty)
          const Center(
            child: Text(
              'Tap on star to set as cover photo',
              style: TextStyle(
                color: Color(0xFFB0B6BF),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: () => onAddPhoto(''),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: const Color(0xFF6E7681).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add photos',
              style: TextStyle(
                color: Color(0xFF6E7681),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Show off your property',
              style: TextStyle(
                color: Color(0xFFB0B6BF),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: photos.length + 1,
      itemBuilder: (context, index) {
        if (index == photos.length) {
          return _buildAddButton();
        }
        return _buildPhotoItem(photos[index]);
      },
    );
  }

  Widget _buildPhotoItem(String photo) {
    final isCover = photo == coverPhoto;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(photo),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),
        
        if (isCover)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7B5BF2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'COVER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          
        Positioned(
          bottom: 8,
          right: 8,
          child: Row(
            children: [
              if (!isCover)
                GestureDetector(
                  onTap: () => onSetCover(photo),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_border,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => onRemovePhoto(photo),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => onAddPhoto(''),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF7B5BF2),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add',
              style: TextStyle(
                color: Color(0xFF6E7681),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}