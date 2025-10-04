import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth_bloc.dart';
import 'password_creation_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final DateTime? birthDate; // manter compatível com seu fluxo
  final String email;

  const VerificationCodeScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLocalLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _resendCode() {
    if (widget.birthDate == null) return;
    context.read<AuthBloc>().add(SignupStartRequested(
      firstName: widget.firstName,
      lastName: widget.lastName,
      birthDate: widget.birthDate!,
      email: widget.email,
    ));
  }

  void _verifyCode() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLocalLoading = true);
    context.read<AuthBloc>().add(VerifyPinSubmitted(
      email: widget.email,
      code: _codeController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Auren', style: TextStyle(color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() => _isLocalLoading = false);
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthPinVerified) {
            setState(() => _isLocalLoading = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PasswordCreationScreen(email: widget.email),
              ),
            );
          } else if (state is AuthCodeSent) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Código reenviado')));
          } else if (state is AuthLoading) {
            // deixa o loader local ligado quando reenviando
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/ic_auren_logo.png',
                    height: 80, width: 80),
                const SizedBox(height: 20),
                Text(
                  'Auren',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  'A code has been sent to your email. Please enter the code below to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (v.length < 4) return 'Code must be at least 4 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                RichText(
                  text: TextSpan(
                    text: 'Didn\'t receive the code? ',
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Resend code',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _isLocalLoading ? null : _resendCode,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLocalLoading ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLocalLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
