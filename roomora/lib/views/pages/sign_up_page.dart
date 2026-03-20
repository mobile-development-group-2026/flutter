import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '/../theme/colors.dart';
import '../widgets/custom_button.dart';

enum AccountType { student, landlord }

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  AccountType _selectedType = AccountType.student;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  final TextEditingController _passwordController = TextEditingController();
  double _passwordStrength = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _evaluatePassword(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.25;
    if (value.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (value.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength += 0.25;
    setState(() => _passwordStrength = strength);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildToggle(),
            const SizedBox(height: 28),
            _buildNameRow(),
            const SizedBox(height: 16),
            _buildFieldLabel('EMAIL ADDRESS'),
            const SizedBox(height: 8),
            _buildEmailField(),
            if (_selectedType == AccountType.landlord) ...[
              const SizedBox(height: 16),
              _buildFieldLabel('PHONE NUMBER'),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 16),
              _buildVerificationNotice(),
            ],
            const SizedBox(height: 16),
            _buildFieldLabel('PASSWORD'),
            const SizedBox(height: 8),
            _buildPasswordField(),
            const SizedBox(height: 8),
            _buildPasswordStrengthBar(),
            const SizedBox(height: 20),
            _buildTermsCheckbox(),
            const SizedBox(height: 24),
            CustomButton(
              text: _selectedType == AccountType.student
                  ? 'Create Student Account'
                  : 'Create Landlord Account',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(LucideIcons.chevronLeft, color: AppColors.neutral900, size: 20),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.purple600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.house, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          const Text(
            'roomora',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Log In',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.purple500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
            ),
            children: [
              const TextSpan(text: 'Create your\n'),
              TextSpan(
                text: 'account',
                style: TextStyle(color: AppColors.purple500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Reach thousands of verified students looking for\nhousing near campus.',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            color: AppColors.neutral700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleOption(label: '🎓  Student', type: AccountType.student),
          _toggleOption(label: '🏠  Landlord', type: AccountType.landlord),
        ],
      ),
    );
  }

  Widget _toggleOption({required String label, required AccountType type}) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.neutral900 : AppColors.neutral700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('FIRST NAME'),
              const SizedBox(height: 8),
              _buildTextField(hint: 'Andy', icon: LucideIcons.user),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('LAST NAME'),
              const SizedBox(height: 8),
              _buildTextField(hint: 'Ortiz', icon: LucideIcons.user),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      hint: 'a.ortiz@ufl.edu',
      icon: LucideIcons.mail,
      keyboardType: TextInputType.emailAddress,
      suffixText: 'Required',
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      hint: '+1 (813) 841-0566',
      icon: LucideIcons.phone,
      keyboardType: TextInputType.phone,
      suffixText: 'Required',
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
  }) {
    return TextField(
      keyboardType: keyboardType,
      style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.neutral900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.neutral500),
        prefixIcon: Icon(icon, size: 18, color: AppColors.neutral600),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          fontFamily: 'Sora',
          fontSize: 12,
          color: AppColors.neutral600,
        ),
        filled: true,
        fillColor: AppColors.neutral200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purple500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      onChanged: _evaluatePassword,
      obscureText: _obscurePassword,
      style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.neutral900),
      decoration: InputDecoration(
        hintText: '••••••••••••',
        hintStyle: TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.neutral500),
        prefixIcon: Icon(LucideIcons.lockKeyhole, size: 18, color: AppColors.neutral600),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
            size: 18,
            color: AppColors.neutral600,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: AppColors.neutral200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purple500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordStrengthBar() {
    if (_passwordStrength == 0) return const SizedBox.shrink();

    Color barColor;
    String label;

    if (_passwordStrength <= 0.25) {
      barColor = AppColors.red500;
      label = 'Weak';
    } else if (_passwordStrength <= 0.5) {
      barColor = AppColors.yellow500;
      label = 'Fair';
    } else if (_passwordStrength <= 0.75) {
      barColor = AppColors.yellow400;
      label = 'Good';
    } else {
      barColor = AppColors.green500;
      label = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: AppColors.neutral300,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: barColor,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.shieldCheck, size: 18, color: AppColors.purple500),
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
                    text: 'Identity verification required. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple700,
                    ),
                  ),
                  const TextSpan(
                    text: 'After signup you\'ll verify your ID and ownership documents to list properties on Roomora.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _acceptedTerms ? AppColors.green500 : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _acceptedTerms ? AppColors.green500 : AppColors.neutral400,
                width: 1.5,
              ),
            ),
            child: _acceptedTerms
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                color: AppColors.neutral700,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: AppColors.purple500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.purple500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral700,
        letterSpacing: 0.8,
      ),
    );
  }
}