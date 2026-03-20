import '/../theme/colors.dart';
import '/../views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


enum DocumentType { utilityBill, taxRecord, propertyDeed, bankStatement }

class ProofOfAddress extends StatefulWidget {
  final VoidCallback onNext;
  const ProofOfAddress({super.key, required this.onNext});

  @override
  State<ProofOfAddress> createState() => _ProofOfAddressState();
}

class _ProofOfAddressState extends State< ProofOfAddress> {
  DocumentType _selectedDoc = DocumentType.utilityBill;
  bool _fileUploaded = false;

  final Map<DocumentType, Map<String, dynamic>> _docTypes = {
    DocumentType.utilityBill: {'label': 'Utility\nbill', 'icon': LucideIcons.fileText},
    DocumentType.taxRecord: {'label': 'Tax\nrecord', 'icon': LucideIcons.file},
    DocumentType.propertyDeed: {'label': 'Property\ndeed', 'icon': LucideIcons.house},
    DocumentType.bankStatement: {'label': 'Bank\nstatement', 'icon': LucideIcons.creditCard},
  };

  String get _selectedDocLabel {
    switch (_selectedDoc) {
      case DocumentType.utilityBill: return 'UTILITY BILL';
      case DocumentType.taxRecord: return 'TAX RECORD';
      case DocumentType.propertyDeed: return 'PROPERTY DEED';
      case DocumentType.bankStatement: return 'BANK STATEMENT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.2,
              ),
              children: [
                const TextSpan(text: 'Proof of\n'),
                TextSpan(
                  text: 'address',
                  style: TextStyle(color: AppColors.purple500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a document showing your name and property address. Reviewed privately by our team.',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              color: AppColors.neutral700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildDocTypeSelector(),
          const SizedBox(height: 20),
          if (_fileUploaded) ...[
            Text(
              'UPLOAD $_selectedDocLabel',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            _buildUploadedFile(),
            const SizedBox(height: 20),
          ] else ...[
            _buildUploadArea(),
            const SizedBox(height: 20),
          ],
          _buildWhatWeCheck(),
          const SizedBox(height: 16),
          _buildEncryptedNotice(),
          const SizedBox(height: 28),
          CustomButton(
            text: 'Submit for review →',
            onPressed: _fileUploaded ? widget.onNext : () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDocTypeSelector() {
    return Row(
      children: _docTypes.entries.map((entry) {
        final isSelected = _selectedDoc == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDoc = entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.purple100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.purple500 : AppColors.neutral300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    entry.value['icon'] as IconData,
                    size: 20,
                    color: isSelected ? AppColors.purple500 : AppColors.neutral500,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.value['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.purple600 : AppColors.neutral600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: () => setState(() => _fileUploaded = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.neutral400,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.upload, size: 24, color: AppColors.neutral500),
            const SizedBox(height: 8),
            Text(
              'Tap to upload document',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, JPG or PNG · Max 10MB',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFile() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.fileText, size: 20, color: AppColors.purple500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'utility_bill_oct.pdf',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  '2.4 MB · PDF',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 11,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.check, size: 14, color: AppColors.green500),
              const SizedBox(width: 4),
              Text(
                'Ready',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green500,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _fileUploaded = false),
                child: Icon(LucideIcons.x, size: 16, color: AppColors.neutral500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatWeCheck() {
    final items = [
      'Your full name matches your Roomora profile',
      'The property address is clearly visible',
      'Document is dated within 3 months',
      'No screenshots — original file only',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.info, size: 15, color: AppColors.neutral600),
              const SizedBox(width: 6),
              Text(
                'What we check for',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.green500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: AppColors.neutral700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEncryptedNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.purple500),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  color: AppColors.neutral800,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Your document is encrypted ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple700,
                    ),
                  ),
                  const TextSpan(
                    text: 'and only seen by our verification team. Never shared with students, deleted after 30 days.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}