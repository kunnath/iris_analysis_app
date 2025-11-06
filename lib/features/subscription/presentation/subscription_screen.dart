import 'package:flutter/material.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/models/app_user.dart';
import '../../../shared/widgets/custom_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  Map<String, dynamic>? _currentSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentSubscription();
  }

  Future<void> _loadCurrentSubscription() async {
    try {
      final subscription = await _subscriptionService.getCurrentSubscription();
      if (mounted) {
        setState(() {
          _currentSubscription = subscription;
        });
      }
    } catch (e) {
      print('Failed to load current subscription: $e');
    }
  }

  Future<void> _subscribeToPlan(SubscriptionPlan plan) async {
    setState(() => _isLoading = true);

    try {
      // Show payment method selection
      final paymentMethod = await _showPaymentMethodDialog();
      if (paymentMethod == null) {
        setState(() => _isLoading = false);
        return;
      }

      PaymentResult result;
      if (paymentMethod == PaymentMethod.stripe) {
        result = await _subscriptionService.subscribeWithStripe(plan);
      } else {
        result = await _subscriptionService.subscribeWithInAppPurchase(plan);
      }

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully subscribed to ${plan.name}!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCurrentSubscription();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subscription failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<PaymentMethod?> _showPaymentMethodDialog() async {
    return showDialog<PaymentMethod>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit Card (Stripe)'),
              subtitle: const Text('Secure payment with Stripe'),
              onTap: () => Navigator.pop(context, PaymentMethod.stripe),
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('App Store / Google Play'),
              subtitle: const Text('Use your device payment method'),
              onTap: () => Navigator.pop(context, PaymentMethod.inAppPurchase),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current subscription status
                  if (_currentSubscription != null) _buildCurrentSubscriptionCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock advanced features with our subscription plans',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Free plan
                  _buildFreePlanCard(),
                  const SizedBox(height: 16),

                  // Subscription plans
                  ...SubscriptionPlan.availablePlans.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPlanCard(plan),
                  )),

                  const SizedBox(height: 32),

                  // Features comparison
                  _buildFeaturesComparison(),

                  const SizedBox(height: 32),

                  // Terms and restore purchases
                  _buildFooter(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    final isActive = _currentSubscription!['isActive'] as bool;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(_currentSubscription!['expiresAt']);
    final planData = _currentSubscription!['plan'] as Map<String, dynamic>?;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.error,
                color: isActive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'Active Subscription' : 'Subscription Expired',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (planData != null) ...[
            Text(
              planData['name'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            isActive 
                ? 'Expires on ${_formatDate(expiresAt)}'
                : 'Expired on ${_formatDate(expiresAt)}',
            style: const TextStyle(color: Colors.grey),
          ),
          if (isActive) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _cancelSubscription,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Cancel Subscription'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFreePlanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Free Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Current',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Basic iris analysis with limited features',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            '\$0',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '• 3 analyses per month\n• Basic insights\n• Local storage only\n• Community support',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: plan.isPopular ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular ? Colors.blue.shade300 : Colors.grey.shade200,
          width: plan.isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Popular',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${plan.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                plan.durationDays == 30 ? '/month' : '/year',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            plan.features.map((feature) => '• $feature').join('\n'),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Subscribe Now',
              onPressed: () => _subscribeToPlan(plan),
              backgroundColor: plan.isPopular ? Colors.blue.shade900 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feature Comparison',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildComparisonRow('Monthly Analyses', 'Free: 3', 'Basic: 20', 'Premium: 100', 'Pro: Unlimited'),
              _buildComparisonRow('Cloud Storage', '❌', '✅', '✅', '✅'),
              _buildComparisonRow('Advanced Insights', '❌', '❌', '✅', '✅'),
              _buildComparisonRow('Trend Analysis', '❌', '❌', '✅', '✅'),
              _buildComparisonRow('Priority Support', '❌', '❌', '✅', '✅'),
              _buildComparisonRow('API Access', '❌', '❌', '❌', '✅'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String feature, String free, String basic, String premium, String pro) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(free, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text(basic, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text(premium, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text(pro, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        TextButton(
          onPressed: _restorePurchases,
          child: const Text('Restore Purchases'),
        ),
        const SizedBox(height: 8),
        const Text(
          'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscriptions automatically renew unless cancelled.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel your subscription? You will lose access to premium features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _subscriptionService.cancelSubscription();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCurrentSubscription();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel subscription: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _subscriptionService.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCurrentSubscription();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore purchases: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}