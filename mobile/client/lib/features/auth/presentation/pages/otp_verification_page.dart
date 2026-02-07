import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/ui_state_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/firebase_otp_service.dart';
import '../../providers/firebase_otp_provider.dart';
import '../providers/auth_provider.dart';

const _otpCountdownId = 'otp_countdown';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool sendOtpOnInit;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    this.sendOtpOnInit = true,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage>
    with TickerProviderStateMixin {
  final int _otpLength = 6;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  Timer? _timer;
  
  late AnimationController _mainAnimController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    
    _mainAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainAnimController, curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );
    
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _mainAnimController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ne démarrer le countdown que s'il n'est pas déjà actif (évite réinitialisation)
      final currentCountdown = ref.read(countdownProvider(_otpCountdownId));
      if (currentCountdown <= 0) {
        _startResendCountdown();
      } else {
        // Continuer le countdown existant
        _continueExistingCountdown();
      }
      if (widget.sendOtpOnInit) _sendFirebaseOtp();
    });
  }

  @override
  @override
  void dispose() {
    _timer?.cancel();
    _mainAnimController.dispose();
    _pulseController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _startResendCountdown() {
    _timer?.cancel();
    ref.read(countdownProvider(_otpCountdownId).notifier).setValue(60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = ref.read(countdownProvider(_otpCountdownId));
      if (current > 0) {
        ref.read(countdownProvider(_otpCountdownId).notifier).decrement();
      } else {
        timer.cancel();
      }
    });
  }

  /// Continue un countdown existant (quand on revient sur la page)
  void _continueExistingCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = ref.read(countdownProvider(_otpCountdownId));
      if (current > 0) {
        ref.read(countdownProvider(_otpCountdownId).notifier).decrement();
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();
  bool get _isOtpComplete => _otpCode.length == _otpLength;

  void _onOtpChanged(int index, String value) {
    setState(() {});
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_isOtpComplete) _verifyOtp();
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _sendFirebaseOtp() async {
    final notifier = ref.read(firebaseOtpProvider.notifier);
    await notifier.sendOtp(widget.phoneNumber);
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete) {
      _showError('Veuillez entrer le code complet');
      return;
    }
    final notifier = ref.read(firebaseOtpProvider.notifier);
    final result = await notifier.verifyOtp(_otpCode);
    if (!mounted) return;
    if (result.success) {
      await _linkToBackend(result.firebaseUid!);
    }
  }

  Future<void> _linkToBackend(String firebaseUid) async {
    try {
      // Utiliser le AuthNotifier pour mettre à jour l'état global
      final authNotifier = ref.read(authProvider.notifier);
      final result = await authNotifier.verifyFirebaseOtp(
        phone: widget.phoneNumber,
        firebaseUid: firebaseUid,
      );
      if (!mounted) return;
      result.fold(
        (failure) => _showError(failure.message),
        (success) {
          if (context.mounted) {
            // Utiliser go_router pour la navigation
            context.go(AppRoutes.home);
          }
        },
      );
    } catch (e) {
      if (mounted) _showError('Erreur de liaison au compte');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _resendOtp() async {
    final countdown = ref.read(countdownProvider(_otpCountdownId));
    if (countdown > 0) return;
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    final notifier = ref.read(firebaseOtpProvider.notifier);
    await notifier.resendOtp();
    _startResendCountdown();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Nouveau code envoye'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _formatPhone(String phone) {
    if (phone.startsWith('+225') && phone.length >= 13) {
      final n = phone.substring(4);
      return '+225 ${n.substring(0, 2)} ${n.substring(2, 4)} ${n.substring(4, 6)} ${n.substring(6, 8)} ${n.substring(8)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(firebaseOtpProvider);
    final countdown = ref.watch(countdownProvider(_otpCountdownId));
    final isLoading = otpState.isLoading;
    final errorMessage = otpState.errorMessage;
    final state = otpState.state;

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withValues(alpha: 0.08), Colors.white, Colors.white],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Revenir à la page précédente (pas forcément register)
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.login);
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          
                          // Icon
                          ScaleTransition(
                            scale: _scaleAnim,
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (context, child) => Transform.scale(
                                scale: _pulseAnim.value,
                                child: Container(
                                  width: 110, height: 110,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)]),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 25, offset: const Offset(0, 12))],
                                  ),
                                  child: const Icon(Icons.sms_outlined, size: 50, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 28),
                          const Text('Verification OTP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5)),
                          const SizedBox(height: 12),
                          _buildStatusWidget(state),
                          const SizedBox(height: 10),
                          
                          // Phone badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_android, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(_formatPhone(widget.phoneNumber), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 36),
                          _buildOtpFields(),
                          
                          if (errorMessage != null) ...[
                            const SizedBox(height: 20),
                            _buildErrorWidget(errorMessage),
                          ],
                          
                          const SizedBox(height: 32),
                          _buildVerifyButton(isLoading),
                          const SizedBox(height: 28),
                          _buildResendSection(countdown, isLoading),
                          const SizedBox(height: 36),
                          _buildSecurityBadge(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ), // Closing Container
      ), // Closing Scaffold
    ); // Closing PopScope
  }

  Widget _buildStatusWidget(FirebaseOtpState state) {
    IconData icon;
    String message;
    Color color;
    
    switch (state) {
      case FirebaseOtpState.initial:
        icon = Icons.hourglass_top;
        message = 'Envoi du code en cours...';
        color = AppColors.primary;
      case FirebaseOtpState.codeSent:
        icon = Icons.mark_email_read_outlined;
        message = 'Code envoye avec succes';
        color = AppColors.success;
      case FirebaseOtpState.verifying:
        icon = Icons.sync;
        message = 'Verification en cours...';
        color = AppColors.primary;
      case FirebaseOtpState.verified:
        icon = Icons.check_circle;
        message = 'Verification reussie !';
        color = AppColors.success;
      case FirebaseOtpState.error:
        icon = Icons.info_outline;
        message = 'Entrez le code recu par SMS';
        color = Colors.grey[600]!;
      case FirebaseOtpState.timeout:
        icon = Icons.timer_off;
        message = 'Le code a expire';
        color = AppColors.warning;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state == FirebaseOtpState.initial || state == FirebaseOtpState.verifying)
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
        else
          Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(message, style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildOtpFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final totalGaps = (_otpLength - 1) * 10.0;
        final fieldWidth = ((availableWidth - totalGaps) / _otpLength).clamp(44.0, 54.0);
        
        if (availableWidth < 320) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_otpLength, (i) => Padding(
                padding: EdgeInsets.only(right: i < _otpLength - 1 ? 10 : 0),
                child: _buildOtpField(i, 50.0),
              )),
            ),
          );
        }
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_otpLength, (i) => Padding(
            padding: EdgeInsets.only(right: i < _otpLength - 1 ? 10 : 0),
            child: _buildOtpField(i, fieldWidth),
          )),
        );
      },
    );
  }

  Widget _buildOtpField(int index, double width) {
    final hasValue = _controllers[index].text.isNotEmpty;
    final isFocused = _focusNodes[index].hasFocus;
    
    return GestureDetector(
      onTap: () => _focusNodes[index].requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: 62,
        decoration: BoxDecoration(
          color: hasValue ? AppColors.primary.withValues(alpha: 0.08) : isFocused ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused ? AppColors.primary : hasValue ? AppColors.primary.withValues(alpha: 0.4) : Colors.grey[300]!,
            width: isFocused ? 2.5 : 1.5,
          ),
          boxShadow: isFocused
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) => _onKeyEvent(index, event),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(fontSize: width > 48 ? 28 : 24, fontWeight: FontWeight.bold, color: AppColors.primary),
            cursorColor: AppColors.primary,
            decoration: const InputDecoration(counterText: '', border: InputBorder.none, contentPadding: EdgeInsets.zero),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onOtpChanged(index, value),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    // Déterminer si c'est une erreur de rate limit Firebase
    final isRateLimitError = message.toLowerCase().contains('trop de tentatives') ||
                             message.toLowerCase().contains('too many requests');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isRateLimitError ? Colors.orange.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isRateLimitError ? Colors.orange.shade200 : Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRateLimitError ? Colors.orange.shade100 : Colors.red.shade100, 
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRateLimitError ? Icons.timer_outlined : Icons.error_outline, 
                  color: isRateLimitError ? Colors.orange.shade700 : Colors.red.shade600, 
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message, 
                  style: TextStyle(
                    color: isRateLimitError ? Colors.orange.shade800 : Colors.red.shade700, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (isRateLimitError) ...[
            const SizedBox(height: 10),
            Text(
              '💡 C\'est une protection Firebase contre les abus. Patientez quelques minutes avant de réessayer.',
              style: TextStyle(
                color: Colors.orange.shade600, 
                fontSize: 12, 
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifyButton(bool isLoading) {
    final isComplete = _isOtpComplete;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isComplete ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)] : [Colors.grey[300]!, Colors.grey[350]!],
        ),
        boxShadow: isComplete ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8))] : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading || !isComplete ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.grey[500],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 22, color: isComplete ? Colors.white : Colors.grey[500]),
                  const SizedBox(width: 10),
                  Text('Verifier le code', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: isComplete ? Colors.white : Colors.grey[500])),
                ],
              ),
      ),
    );
  }

  Widget _buildResendSection(int countdown, bool isLoading) {
    return Column(
      children: [
        if (countdown > 0) ...[
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64, height: 64,
                child: CircularProgressIndicator(value: countdown / 60, backgroundColor: Colors.grey[200], color: AppColors.primary, strokeWidth: 4, strokeCap: StrokeCap.round),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$countdown', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('sec', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Renvoyer le code dans', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ] else ...[
          OutlinedButton.icon(
            onPressed: isLoading ? null : _resendOtp,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Renvoyer le code', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.verified_user, color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verification securisee', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Propulse par Firebase', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }
}
