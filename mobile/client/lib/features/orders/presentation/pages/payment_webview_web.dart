import 'package:flutter/material.dart';

/// Web stub for NativePaymentWebView
/// On web, we don't use this widget - we open the URL directly in a new tab
class NativePaymentWebView extends StatelessWidget {
  final String paymentUrl;
  final String? orderId;

  const NativePaymentWebView({
    super.key,
    required this.paymentUrl,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    // This widget should never be displayed on web
    // The PaymentWebViewPage.show() method handles web differently
    return const Scaffold(
      body: Center(
        child: Text('Redirection vers la page de paiement...'),
      ),
    );
  }
}
