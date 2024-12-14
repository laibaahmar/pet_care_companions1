// import 'package:dio/dio.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'consts.dart';
//
// class StripeService {
//   StripeService._();
//
//   static final StripeService instance = StripeService._();
//
//   Future<bool> makePayment() async {
//     try {
//       String? paymentIntentClientSecret = await _createPaymentIntent(
//         100,
//         "usd",
//       );
//       if (paymentIntentClientSecret == null)
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentClientSecret,
//           merchantDisplayName: "laiba Ahmar",
//         ),
//       );
//       bool paymentSuccess = await _processPayment();
//       return paymentSuccess;
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future<String?> _createPaymentIntent(int amount, String currency) async {
//     try {
//       final Dio dio = Dio();
//       Map<String, dynamic> data = {
//         "amount": _calculateAmount(
//           amount,
//         ),
//         "currency": currency,
//       };
//       var response = await dio.post(
//         "https://api.stripe.com/v1/payment_intents",
//         data: data,
//         options: Options(
//           contentType: Headers.formUrlEncodedContentType,
//           headers: {
//             "Authorization": "Bearer $stripeSecretKey",
//             "Content-Type": 'application/x-www-form-urlencoded'
//           },
//         ),
//       );
//       if (response.data != null) {
//         return response.data["client_secret"];
//       }
//       return null;
//     } catch (e) {
//       print(e);
//     }
//     return null;
//   }
//
//   Future<bool> _processPayment() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//       await Stripe.instance.confirmPaymentSheetPayment();
//       return true;
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   String _calculateAmount(int amount) {
//     final calculatedAmount = amount * 100;
//     return calculatedAmount.toString();
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'consts.dart'; // Assuming you have a file for your constants like stripeSecretKey

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  // Function to make payment
  Future<bool> makePayment() async {
    try {
      // Create the payment intent and get the client secret
      String? paymentIntentClientSecret = await _createPaymentIntent(100, "usd");
      if (paymentIntentClientSecret == null) {
        print('Failed to create payment intent.');
        return false; // Return false if client secret is null
      }

      // Initialize the payment sheet with the payment intent client secret
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Laiba Ahmar", // You can replace this with a dynamic name
        ),
      );

      // Present the payment sheet to the user
      return await _presentPaymentSheet();
    } catch (e) {
      print('Error during payment setup: $e');
      return false; // Return false in case of error
    }
  }

  // Function to create payment intent using the Stripe API
  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount), // Convert to smallest unit (e.g., cents)
        "currency": currency,
      };

      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey", // Replace with your Stripe Secret Key
            "Content-Type": 'application/x-www-form-urlencoded'
          },
        ),
      );

      // Check the response and return the client secret if successful
      if (response.data != null && response.data["client_secret"] != null) {
        return response.data["client_secret"];
      } else {
        print('Payment intent creation failed: No client secret received.');
        return null;
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  // Function to process the payment by presenting the payment sheet
  Future<bool> _presentPaymentSheet() async {
    try {
      print("Presenting payment sheet...");
      await Stripe.instance.presentPaymentSheet();
      print("Payment sheet presented successfully.");

      // Confirm payment after the user completes the payment
      await Stripe.instance.confirmPaymentSheetPayment();
      print("Payment confirmed successfully.");
      return true;
    } catch (e) {
      // If there's an error, capture and print it
      print("Error during payment processing: $e");

      // Handle specific error cases
      if (e is StripeException) {
        print("Stripe error: ${e.error.localizedMessage}");
      }
      return false;
    }
  }

  // Helper function to calculate the amount in the smallest currency unit (e.g., cents)
  String _calculateAmount(int amount) {
    // Stripe expects the amount in the smallest unit (e.g., cents for USD)
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}