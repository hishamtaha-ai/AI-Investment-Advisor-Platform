import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const NexusApp());
}

class NexusColors {
  static const teal = Color(0xFF0D7775);
  static const dark = Color(0xFF1D1B19);
  static const gray = Color(0xFF5C5852);
  static const muted = Color(0xFF8A857D);
  static const input = Color(0xFFEFECE6);
  static const border = Color(0xFFE5E0D8);
  static const chipBorder = Color(0xFFDDD7CD);
  static const glow = Color(0xFFD4ECE8);
  static const disabledBg = Color(0xFFDFD9D2);
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void signIn() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter your email and password.');
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      showMessage('Please enter a valid email.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecuritySettingsScreen(),
      ),
    );
  }

  void openRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXUS',
                        style: GoogleFonts.newsreader(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 4.8,
                          color: NexusColors.teal,
                        ),
                      ),
                      const SizedBox(height: 60),
                      Text(
                        'Welcome back',
                        style: GoogleFonts.newsreader(
                          fontSize: 34,
                          fontWeight: FontWeight.w400,
                          color: NexusColors.dark,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sign in to continue to your financial intelligence stream.',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15,
                          color: NexusColors.gray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      NexusInput(
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.mail_outline,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      NexusInput(
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        controller: passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: openForgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: NexusColors.teal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NexusColors.teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Sign in',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to NEXUS?',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      color: NexusColors.gray,
                    ),
                  ),
                  TextButton(
                    onPressed: openRegistration,
                    child: Text(
                      'Create account',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NexusColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController(text: '');
  final lastNameController = TextEditingController(text: '');
  final dobController = TextEditingController(text: '');
  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController();
  final countryController = TextEditingController(text: 'Egypt');
  final timezoneController = TextEditingController(text: '(GMT+02:00) Cairo');

  final List<String> allSectors = [
    'Technology',
    'Financial Services',
    'Healthcare',
    'Energy',
    'Industrials',
    'Consumer',
    'Real Estate',
    'Telecommunications',
  ];

  final Set<String> selectedSectors = {'Technology', 'Financial Services'};
  bool acceptTerms = true;
  bool acceptPrivacy = true;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    emailController.dispose();
    passwordController.dispose();
    countryController.dispose();
    timezoneController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      setState(() {
        dobController.text = '$day/$month/$year';
      });
    }
  }

  void showSimpleSelector({
    required String title,
    required List<String> options,
    required TextEditingController controller,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: GoogleFonts.newsreader(
                    fontSize: 20,
                    color: NexusColors.dark,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...options.map(
                (item) => ListTile(
                  title: Text(item, style: GoogleFonts.instrumentSans(fontSize: 15)),
                  trailing: controller.text == item
                      ? const Icon(Icons.check, color: NexusColors.teal)
                      : null,
                  onTap: () {
                    setState(() {
                      controller.text = item;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void createAccount() {
    final email = emailController.text.trim();
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        dobController.text.isEmpty ||
        email.isEmpty ||
        passwordController.text.isEmpty) {
      showMessage('Please fill in all required fields.');
      return;
    }

    if (!acceptTerms || !acceptPrivacy) {
      showMessage('Please accept terms and policies.');
      return;
    }

    Navigator.popUntil(context, (route) => route.isFirst);
    showMessage('Account created successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NexusTopBar(),
              const SizedBox(height: 18),
              Text(
                'Create your account',
                style: GoogleFonts.newsreader(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: NexusColors.dark,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tell us a little about you to tailor your market stream.',
                style: GoogleFonts.instrumentSans(
                  fontSize: 15,
                  color: NexusColors.gray,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildProgressSegment(isActive: true),
                  const SizedBox(width: 6),
                  _buildProgressSegment(isActive: true),
                  const SizedBox(width: 6),
                  _buildProgressSegment(isActive: true),
                  const SizedBox(width: 6),
                  _buildProgressSegment(isActive: false),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: NexusInput(
                      label: 'First name',
                      hint: 'Alistair',
                      controller: firstNameController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NexusInput(
                      label: 'Last name',
                      hint: 'Vance',
                      controller: lastNameController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NexusInput(
                label: 'Date of birth',
                hint: 'DD/MM/YYYY',
                icon: Icons.calendar_today_outlined,
                controller: dobController,
                readOnly: true,
                onTap: pickDateOfBirth,
              ),
              const SizedBox(height: 16),
              NexusInput(
                label: 'Email',
                hint: 'a.vance@bridgewater.com',
                icon: Icons.mail_outline,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              NexusInput(
                label: 'Password',
                hint: 'Min. 12 characters',
                icon: Icons.lock_outline,
                controller: passwordController,
                isPassword: true,
                helperText: 'Use upper and lower case, a digit and a symbol.',
              ),
              const NexusSectionDivider(title: 'Interests'),
              Text(
                'Preferred sectors — choose any that apply.',
                style: GoogleFonts.instrumentSans(
                  fontSize: 12.5,
                  color: NexusColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allSectors.map((sector) {
                  final bool isSelected = selectedSectors.contains(sector);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedSectors.remove(sector);
                        } else {
                          selectedSectors.add(sector);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? NexusColors.teal : NexusColors.input,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? NexusColors.teal : NexusColors.chipBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            sector,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 14,
                              color: isSelected ? Colors.white : NexusColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const NexusSectionDivider(title: 'Region'),
              NexusInput(
                label: 'Country',
                hint: 'Select country',
                icon: Icons.language,
                suffixIcon: Icons.keyboard_arrow_down,
                controller: countryController,
                readOnly: true,
                onTap: () => showSimpleSelector(
                  title: 'Select Country',
                  options: ['Egypt', 'United Arab Emirates', 'Saudi Arabia', 'United Kingdom', 'United States'],
                  controller: countryController,
                ),
              ),
              const SizedBox(height: 16),
              NexusInput(
                label: 'Timezone',
                hint: 'Select timezone',
                icon: Icons.language,
                suffixIcon: Icons.keyboard_arrow_down,
                controller: timezoneController,
                readOnly: true,
                onTap: () => showSimpleSelector(
                  title: 'Select Timezone',
                  options: ['(GMT+02:00) Cairo', '(GMT+03:00) Riyadh', '(GMT+04:00) Dubai', '(GMT+00:00) London', '(GMT-05:00) New York'],
                  controller: timezoneController,
                ),
              ),
              const NexusSectionDivider(title: 'Agreements'),
              _buildAgreementRow(
                value: acceptTerms,
                onChanged: () => setState(() => acceptTerms = !acceptTerms),
                prefixText: 'I accept the ',
                linkText: 'Terms of Service',
                suffixText: '.',
              ),
              const SizedBox(height: 14),
              _buildAgreementRow(
                value: acceptPrivacy,
                onChanged: () => setState(() => acceptPrivacy = !acceptPrivacy),
                prefixText: 'I accept the ',
                linkText: 'Privacy Policy',
                suffixText: ' and how my data is handled.',
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Create account',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      color: NexusColors.gray,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Sign in',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NexusColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: isActive ? NexusColors.teal : NexusColors.disabledBg,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildAgreementRow({
    required bool value,
    required VoidCallback onChanged,
    required String prefixText,
    required String linkText,
    required String suffixText,
  }) {
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? NexusColors.teal : NexusColors.input,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: value ? NexusColors.teal : NexusColors.chipBorder,
                width: 1.5,
              ),
            ),
            child: value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: NexusColors.gray,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: prefixText),
                  TextSpan(
                    text: linkText,
                    style: const TextStyle(
                      color: NexusColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: suffixText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController(text: 'a.vance@bridgewater.com');

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void sendCode() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NexusTopBar(),
              const SizedBox(height: 24),
              Text(
                'Reset your password',
                style: GoogleFonts.newsreader(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: NexusColors.dark,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter the email linked to your account. We'll send a verification code so you can set a new password.",
                style: GoogleFonts.instrumentSans(
                  fontSize: 15,
                  color: NexusColors.gray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              NexusInput(
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.mail_outline,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Send code',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to sign in',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NexusColors.teal,
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
}

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void verifyOtp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(email: widget.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = controllers.every((c) => c.text.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NexusTopBar(),
              const SizedBox(height: 24),
              Text(
                'Enter your code',
                style: GoogleFonts.newsreader(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: NexusColors.dark,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.instrumentSans(
                    fontSize: 15,
                    color: NexusColors.gray,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: NexusColors.dark,
                      ),
                    ),
                    const TextSpan(text: '. It expires in 10 minutes.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 60,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: GoogleFonts.newsreader(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: NexusColors.dark,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: focusNodes[index].hasFocus
                            ? Colors.white
                            : NexusColors.input,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: NexusColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: NexusColors.teal,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resend code in 00:42',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      color: NexusColors.gray,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New code sent!')),
                      );
                    },
                    child: Text(
                      'Resend',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: NexusColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isComplete ? verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusColors.teal,
                    disabledBackgroundColor: NexusColors.disabledBg,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Verify',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Wrong email? ',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          color: NexusColors.gray,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Change address',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NexusColors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void resetPassword() {
    if (newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully!')),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NexusTopBar(),
              const SizedBox(height: 24),
              Text(
                'Create a new password',
                style: GoogleFonts.newsreader(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: NexusColors.dark,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.instrumentSans(
                    fontSize: 15,
                    color: NexusColors.gray,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Your code was verified. Choose a new password for '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: NexusColors.dark,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              NexusInput(
                label: 'New password',
                hint: 'Min. 12 characters',
                icon: Icons.lock_outline,
                controller: newPasswordController,
                isPassword: true,
                helperText: 'Use upper and lower case, a digit and a symbol.',
              ),
              const SizedBox(height: 16),
              NexusInput(
                label: 'Confirm password',
                hint: 'Repeat new password',
                icon: Icons.lock_outline,
                controller: confirmPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Reset password',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: Text(
                    'Back to sign in',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NexusColors.teal,
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
}

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final currentPasswordController = TextEditingController(text: '............');
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isSuccessShown = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void updatePassword() {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() {
      isSuccessShown = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: NexusColors.input,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: NexusColors.border),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: NexusColors.dark,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: NexusColors.dark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Security',
                style: GoogleFonts.newsreader(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: NexusColors.dark,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Change your password or the email you sign in with.',
                style: GoogleFonts.instrumentSans(
                  fontSize: 15,
                  color: NexusColors.gray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Change password',
                style: GoogleFonts.instrumentSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: NexusColors.dark,
                ),
              ),
              const SizedBox(height: 16),
              NexusInput(
                label: 'Current password',
                hint: 'Enter current password',
                controller: currentPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              NexusInput(
                label: 'New password',
                hint: 'Min. 12 characters',
                controller: newPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              NexusInput(
                label: 'Confirm new password',
                hint: 'Repeat new password',
                controller: confirmPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Update password',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (isSuccessShown) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 20, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      Text(
                        'Password updated.',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NexusTopBar extends StatelessWidget {
  const NexusTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: NexusColors.input,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NexusColors.border),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: NexusColors.dark,
                size: 24,
              ),
            ),
          ),
          Text(
            'NEXUS',
            style: GoogleFonts.newsreader(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 4.8,
              color: NexusColors.teal,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class NexusSectionDivider extends StatelessWidget {
  final String title;
  const NexusSectionDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: NexusColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Divider(
              color: NexusColors.border,
              thickness: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class NexusInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final IconData? suffixIcon;
  final String? helperText;
  final TextEditingController controller;
  final bool isPassword;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType;

  const NexusInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.suffixIcon,
    this.helperText,
    this.isPassword = false,
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<NexusInput> createState() => _NexusInputState();
}

class _NexusInputState extends State<NexusInput> {
  final FocusNode focusNode = FocusNode();
  bool isFocused = false;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(updateFocus);
  }

  void updateFocus() {
    setState(() {
      isFocused = focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(updateFocus);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.instrumentSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: NexusColors.dark,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : NexusColors.input,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFocused ? NexusColors.teal : NexusColors.border,
              width: isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    const BoxShadow(
                      color: NexusColors.glow,
                      blurRadius: 7,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: NexusColors.gray),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: focusNode,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword && hidePassword,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 15,
                    color: NexusColors.dark,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.instrumentSans(
                      fontSize: 15,
                      color: NexusColors.muted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: NexusColors.gray,
                  ),
                )
              else if (widget.suffixIcon != null)
                Icon(widget.suffixIcon, size: 20, color: NexusColors.gray),
            ],
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: GoogleFonts.instrumentSans(
              fontSize: 12.5,
              color: NexusColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}