import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../errors/auth_exception.dart';

enum PaymentMethod {
  inAppPurchase,
  stripe,
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final SubscriptionTier tier;
  final int durationDays;
  final List<String> features;
  final String? stripePriceId;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tier,
    required this.durationDays,
    required this.features,
    this.stripePriceId,
    this.isPopular = false,
  });

  static const List<SubscriptionPlan> availablePlans = [
    SubscriptionPlan(
      id: 'iris_basic_monthly',
      name: 'Basic Monthly',
      description: 'Essential iris analysis features',
      price: 9.99,
      tier: SubscriptionTier.basic,
      durationDays: 30,
      stripePriceId: 'price_basic_monthly',
      features: [
        '20 analyses per month',
        'Basic health insights',
        'Cloud storage',
        'PDF reports',
        'Email support',
      ],
    ),
    SubscriptionPlan(
      id: 'iris_premium_monthly',
      name: 'Premium Monthly',
      description: 'Advanced analysis with detailed insights',
      price: 19.99,
      tier: SubscriptionTier.premium,
      durationDays: 30,
      stripePriceId: 'price_premium_monthly',
      isPopular: true,
      features: [
        '100 analyses per month',
        'Advanced AI insights',
        'Trend analysis',
        'Detailed health reports',
        'Priority support',
        'Export data',
        'Comparison features',
      ],
    ),
    SubscriptionPlan(
      id: 'iris_pro_yearly',
      name: 'Pro Yearly',
      description: 'Complete health monitoring solution',
      price: 199.99,
      tier: SubscriptionTier.pro,
      durationDays: 365,
      stripePriceId: 'price_pro_yearly',
      features: [
        'Unlimited analyses',
        'Professional insights',
        'Multi-device sync',
        'Custom reports',
        'API access',
        'Priority support',
        'Health tracking',
        'Consultation booking',
      ],
    ),
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'tier': tier.name,
      'durationDays': durationDays,
      'features': features,
      'stripePriceId': stripePriceId,
      'isPopular': isPopular,
    };
  }
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? error;
  final SubscriptionPlan? plan;
  final DateTime? expiresAt;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.error,
    this.plan,
    this.expiresAt,
  });
}

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  // Initialize the service
  Future<void> initialize() async {
    try {
      // Initialize Stripe
      Stripe.publishableKey = 'pk_test_your_publishable_key_here';
      
      // Initialize In-App Purchase
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (_isAvailable) {
        await _loadProducts();
      }
    } catch (e) {
      throw SubscriptionException('Failed to initialize payment system: $e');
    }
  }

  // Load available products
  Future<void> _loadProducts() async {
    try {
      final productIds = SubscriptionPlan.availablePlans.map((plan) => plan.id).toSet();
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
    } catch (e) {
      throw SubscriptionException('Failed to load products: $e');
    }
  }

  // Get available subscription plans
  List<SubscriptionPlan> getAvailablePlans() {
    return SubscriptionPlan.availablePlans;
  }

  // Get product details for a plan
  ProductDetails? getProductDetails(String planId) {
    try {
      return _products.firstWhere((product) => product.id == planId);
    } catch (e) {
      return null;
    }
  }

  // Subscribe with In-App Purchase
  Future<PaymentResult> subscribeWithInAppPurchase(SubscriptionPlan plan) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    if (!_isAvailable) {
      throw const SubscriptionException('In-app purchases not available');
    }

    try {
      final productDetails = getProductDetails(plan.id);
      if (productDetails == null) {
        throw const SubscriptionException('Product not found');
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      
      // Start the purchase
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      // Listen for purchase updates (this should be set up in app initialization)
      return const PaymentResult(success: true);
      
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }

  // Subscribe with Stripe
  Future<PaymentResult> subscribeWithStripe(SubscriptionPlan plan) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      // Create payment intent on your backend
      final paymentIntentData = await _createPaymentIntent(plan);
      
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Iris Analysis',
          customFlow: false,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      // If we reach here, payment was successful
      final expiresAt = DateTime.now().add(Duration(days: plan.durationDays));
      
      // Update user subscription in Firestore
      await _updateUserSubscription(user.uid, plan, paymentIntentData['id'], expiresAt);
      
      return PaymentResult(
        success: true,
        transactionId: paymentIntentData['id'],
        plan: plan,
        expiresAt: expiresAt,
      );
      
    } on StripeException catch (e) {
      return PaymentResult(success: false, error: e.error.localizedMessage);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }

  // Create payment intent (this would call your backend)
  Future<Map<String, dynamic>> _createPaymentIntent(SubscriptionPlan plan) async {
    // This is a mock implementation
    // In a real app, you would call your backend API to create a payment intent
    return {
      'client_secret': 'pi_mock_client_secret',
      'id': 'pi_mock_payment_intent_id',
    };
  }

  // Update user subscription in Firestore
  Future<void> _updateUserSubscription(
    String userId,
    SubscriptionPlan plan,
    String transactionId,
    DateTime expiresAt,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'subscriptionTier': plan.tier.name,
      'subscriptionExpiresAt': expiresAt.millisecondsSinceEpoch,
      'subscriptionPlanId': plan.id,
      'lastPaymentTransactionId': transactionId,
      'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
    });

    // Create subscription record
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .doc(transactionId)
        .set({
      'planId': plan.id,
      'tier': plan.tier.name,
      'amount': plan.price,
      'currency': 'USD',
      'transactionId': transactionId,
      'startDate': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Check subscription status
  Future<bool> isSubscriptionActive() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final expiresAt = data['subscriptionExpiresAt'] as int?;
      
      if (expiresAt == null) return false;
      
      return DateTime.fromMillisecondsSinceEpoch(expiresAt).isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Get current subscription info
  Future<Map<String, dynamic>?> getCurrentSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final planId = data['subscriptionPlanId'] as String?;
      final expiresAt = data['subscriptionExpiresAt'] as int?;
      final tier = data['subscriptionTier'] as String?;

      if (planId == null || expiresAt == null || tier == null) return null;

      final plan = SubscriptionPlan.availablePlans
          .where((p) => p.id == planId)
          .firstOrNull;

      return {
        'plan': plan?.toMap(),
        'expiresAt': expiresAt,
        'tier': tier,
        'isActive': DateTime.fromMillisecondsSinceEpoch(expiresAt).isAfter(DateTime.now()),
      };
    } catch (e) {
      return null;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      // In a real app, you would call your backend to cancel the subscription
      // For now, we'll just update the local status
      
      await _firestore.collection('users').doc(user.uid).update({
        'subscriptionTier': SubscriptionTier.free.name,
        'subscriptionExpiresAt': null,
        'subscriptionPlanId': null,
        'subscriptionCancelledAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw SubscriptionException('Failed to cancel subscription: $e');
    }
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw SubscriptionException('Failed to get payment history: $e');
    }
  }

  // Restore purchases (iOS)
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      throw SubscriptionException('Failed to restore purchases: $e');
    }
  }

  // Handle purchase updates (should be called during app initialization)
  void listenToPurchaseUpdated() {
    _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {},
      onError: (error) {
        print('Purchase stream error: $error');
      },
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        
        // Handle successful purchase
        _handleSuccessfulPurchase(purchaseDetails);
        
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        
        // Handle purchase error
        print('Purchase error: ${purchaseDetails.error}');
        
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        
        // Handle pending purchase
        print('Purchase pending: ${purchaseDetails.productID}');
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final plan = SubscriptionPlan.availablePlans
          .where((p) => p.id == purchaseDetails.productID)
          .firstOrNull;

      if (plan != null) {
        final expiresAt = DateTime.now().add(Duration(days: plan.durationDays));
        await _updateUserSubscription(
          user.uid,
          plan,
          purchaseDetails.purchaseID ?? 'unknown',
          expiresAt,
        );
      }
    } catch (e) {
      print('Failed to handle successful purchase: $e');
    }
  }

  // Dispose resources
  void dispose() {
    // Clean up resources if needed
  }
}
