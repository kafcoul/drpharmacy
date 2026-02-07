import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';

// Conditionally import webview_flutter only for non-web platforms
import 'payment_webview_native.dart' if (dart.library.html) 'payment_webview_web.dart'
    as platform_webview;

/// A WebView page for displaying payment gateway pages (Jeko, etc.)
/// This provides a better mobile experience than opening in external browser
class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String? orderId;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentError;

  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    this.orderId,
    this.onPaymentSuccess,
    this.onPaymentError,
  });

  /// Navigate to this page and return whether payment was successful
  /// On web, it opens in a new tab/popup and returns null (user must verify manually)
  /// On mobile, it opens in a WebView with callback detection
  static Future<bool?> show(
    BuildContext context, {
    required String paymentUrl,
    String? orderId,
  }) async {
    if (kIsWeb) {
      // On web, open in a new tab using url_launcher
      final url = Uri.parse(paymentUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
      // Return null - user needs to manually verify payment status
      return null;
    } else {
      // On mobile, use native WebView
      return Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => platform_webview.NativePaymentWebView(
            paymentUrl: paymentUrl,
            orderId: orderId,
          ),
        ),
      );
    }
  }

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  @override
  void initState() {
    super.initState();
    // This widget is only used as a fallback
    // The actual implementation is platform-specific
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPaymentUrl();
    });
  }

  Future<void> _openPaymentUrl() async {
    final url = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    if (mounted) {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Paiement sécurisé'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Redirection vers la page de paiement...'),
          ],
        ),
      ),
    );
  }
}
