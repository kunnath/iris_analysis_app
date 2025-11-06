import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/security_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/services/cloud_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final SecurityService _securityService = SecurityService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  final CloudStorageService _storageService = CloudStorageService();

  bool _isLoading = true;
  bool _biometricEnabled = false;
  bool _encryptionEnabled = true;
  bool _autoLockEnabled = true;
  bool _privacyModeEnabled = false;
  bool _biometricAvailable = false;
  int _autoLockTimeout = 300;
  List<BiometricType> _availableBiometrics = [];
  Map<String, dynamic>? _securityAudit;
  Map<String, dynamic>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      // Load security settings
      _biometricAvailable = await _securityService.isBiometricAvailable();
      _availableBiometrics = await _securityService.getAvailableBiometrics();
      _biometricEnabled = _securityService.isBiometricEnabled;
      _encryptionEnabled = _securityService.isEncryptionEnabled;
      _autoLockEnabled = _securityService.isAutoLockEnabled;
      _autoLockTimeout = _securityService.autoLockTimeout;
      _privacyModeEnabled = await _securityService.isPrivacyModeEnabled();

      // Load security audit
      _securityAudit = await _securityService.performSecurityAudit();

      // Load subscription info
      try {
        _userSubscription = await _subscriptionService.getCurrentSubscription();
      } catch (e) {
        _userSubscription = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadSettings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSecuritySection(),
                const SizedBox(height: 24),
                _buildSubscriptionSection(),
                const SizedBox(height: 24),
                _buildDataManagementSection(),
                const SizedBox(height: 24),
                _buildPrivacySection(),
                const SizedBox(height: 24),
                _buildAccountSection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_securityAudit != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSecurityScoreColor(_securityAudit!['security_score']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: ${_securityAudit!['security_score']}/100',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSecurityScoreColor(_securityAudit!['security_score']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Biometric Authentication
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: Text(_biometricAvailable 
                ? 'Use ${_availableBiometrics.map((e) => e.name).join(', ')} to unlock app'
                : 'Not available on this device'),
            value: _biometricEnabled && _biometricAvailable,
            onChanged: _biometricAvailable ? _toggleBiometric : null,
            secondary: const Icon(Icons.fingerprint),
          ),
          
          const Divider(height: 1),
          
          // Data Encryption
          SwitchListTile(
            title: const Text('Data Encryption'),
            subtitle: const Text('Encrypt all health data and images'),
            value: _encryptionEnabled,
            onChanged: _toggleEncryption,
            secondary: const Icon(Icons.lock),
          ),
          
          const Divider(height: 1),
          
          // Auto Lock
          SwitchListTile(
            title: const Text('Auto Lock'),
            subtitle: Text('Lock app after ${_autoLockTimeout ~/ 60} minutes of inactivity'),
            value: _autoLockEnabled,
            onChanged: _toggleAutoLock,
            secondary: const Icon(Icons.timer),
          ),
          
          if (_autoLockEnabled) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Auto Lock Timeout'),
              subtitle: Text('${_autoLockTimeout ~/ 60} minutes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showAutoLockTimeoutDialog,
            ),
          ],
          
          const Divider(height: 1),
          
          // Security Audit
          ListTile(
            title: const Text('Security Audit'),
            subtitle: const Text('Review security status and recommendations'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.security_update_good),
            onTap: _showSecurityAuditDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.card_membership, color: Colors.green.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          if (_userSubscription != null) ...[
            ListTile(
              title: Text('Current Plan: ${_userSubscription!['planName']}'),
              subtitle: Text('Expires: ${_formatDate(_userSubscription!['expiresAt'])}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _userSubscription!['isActive'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _userSubscription!['isActive'] ? 'Active' : 'Expired',
                  style: TextStyle(
                    fontSize: 12,
                    color: _userSubscription!['isActive'] ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          
          ListTile(
            title: const Text('Manage Subscription'),
            subtitle: const Text('View plans, upgrade, or cancel'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.manage_accounts),
            onTap: _manageSubscription,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Billing History'),
            subtitle: const Text('View payment history and receipts'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.receipt_long),
            onTap: _viewBillingHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.storage, color: Colors.purple.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Data Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Download all your health data'),
            trailing: const Icon(Icons.download),
            leading: const Icon(Icons.file_download),
            onTap: _exportData,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Storage Usage'),
            subtitle: const Text('View cloud storage usage'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.cloud_queue),
            onTap: _viewStorageUsage,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Backup Settings'),
            subtitle: const Text('Configure automatic backups'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.backup),
            onTap: _configureBackups,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up local storage space'),
            trailing: const Icon(Icons.delete_sweep),
            leading: const Icon(Icons.cleaning_services),
            onTap: _clearCache,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.privacy_tip, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Privacy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          SwitchListTile(
            title: const Text('Privacy Mode'),
            subtitle: const Text('Enhanced data protection and anonymization'),
            value: _privacyModeEnabled,
            onChanged: _togglePrivacyMode,
            secondary: const Icon(Icons.enhanced_encryption),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.policy),
            onTap: _viewPrivacyPolicy,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Data Sharing'),
            subtitle: const Text('Control how your data is shared'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.share),
            onTap: _configureDataSharing,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Delete All Data'),
            subtitle: const Text('Permanently delete all your data'),
            trailing: const Icon(Icons.warning, color: Colors.red),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _deleteAllData,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.account_circle, color: Colors.indigo.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            title: const Text('Profile'),
            subtitle: const Text('Manage your profile information'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.person),
            onTap: _editProfile,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.lock_reset),
            onTap: _changePassword,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add extra security to your account'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.security),
            onTap: _configureTwoFactor,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out of your account'),
            trailing: const Icon(Icons.logout),
            leading: const Icon(Icons.exit_to_app),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.teal.shade700),
                const SizedBox(width: 12),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Build 1)'),
            leading: const Icon(Icons.info_outline),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms of service'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.description),
            onTap: _viewTermsOfService,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Contact Support'),
            subtitle: const Text('Get help with the app'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.support_agent),
            onTap: _contactSupport,
          ),
          
          const Divider(height: 1),
          
          ListTile(
            title: const Text('Rate App'),
            subtitle: const Text('Rate us on the app store'),
            trailing: const Icon(Icons.star),
            leading: const Icon(Icons.rate_review),
            onTap: _rateApp,
          ),
        ],
      ),
    );
  }

  Color _getSecurityScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Security toggles
  void _toggleBiometric(bool value) async {
    try {
      await _securityService.updateSecuritySettings(biometricEnabled: value);
      setState(() => _biometricEnabled = value);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric authentication ${value ? 'enabled' : 'disabled'}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update biometric setting: $e')),
      );
    }
  }

  void _toggleEncryption(bool value) async {
    if (!value) {
      final confirmed = await _showConfirmationDialog(
        'Disable Encryption',
        'Disabling encryption will make your health data less secure. Are you sure?',
      );
      if (!confirmed) return;
    }

    try {
      await _securityService.updateSecuritySettings(encryptionEnabled: value);
      setState(() => _encryptionEnabled = value);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data encryption ${value ? 'enabled' : 'disabled'}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update encryption setting: $e')),
      );
    }
  }

  void _toggleAutoLock(bool value) async {
    try {
      await _securityService.updateSecuritySettings(autoLockEnabled: value);
      setState(() => _autoLockEnabled = value);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto lock ${value ? 'enabled' : 'disabled'}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update auto lock setting: $e')),
      );
    }
  }

  void _togglePrivacyMode(bool value) async {
    try {
      if (value) {
        await _securityService.enablePrivacyMode();
      } else {
        await _securityService.disablePrivacyMode();
      }
      setState(() => _privacyModeEnabled = value);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Privacy mode ${value ? 'enabled' : 'disabled'}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update privacy mode: $e')),
      );
    }
  }

  // Dialog methods
  void _showAutoLockTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Lock Timeout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('1 minute'),
              value: 60,
              groupValue: _autoLockTimeout,
              onChanged: (value) => _updateAutoLockTimeout(value!),
            ),
            RadioListTile<int>(
              title: const Text('5 minutes'),
              value: 300,
              groupValue: _autoLockTimeout,
              onChanged: (value) => _updateAutoLockTimeout(value!),
            ),
            RadioListTile<int>(
              title: const Text('15 minutes'),
              value: 900,
              groupValue: _autoLockTimeout,
              onChanged: (value) => _updateAutoLockTimeout(value!),
            ),
            RadioListTile<int>(
              title: const Text('30 minutes'),
              value: 1800,
              groupValue: _autoLockTimeout,
              onChanged: (value) => _updateAutoLockTimeout(value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateAutoLockTimeout(int timeout) async {
    try {
      await _securityService.updateSecuritySettings(autoLockTimeout: timeout);
      setState(() => _autoLockTimeout = timeout);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto lock timeout updated to ${timeout ~/ 60} minutes'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update timeout: $e')),
      );
    }
  }

  void _showSecurityAuditDialog() {
    if (_securityAudit == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Audit'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Security Score: ${_securityAudit!['security_score']}/100',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getSecurityScoreColor(_securityAudit!['security_score']),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_securityAudit!['recommendations'].isNotEmpty) ...[
                const Text(
                  'Recommendations:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...(_securityAudit!['recommendations'] as List<String>).map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(rec)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Action methods
  void _manageSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription management coming soon!')),
    );
  }

  void _viewBillingHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Billing history coming soon!')),
    );
  }

  void _exportData() async {
    try {
      await _storageService.exportUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data export initiated. Check your email.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }

  void _viewStorageUsage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage usage view coming soon!')),
    );
  }

  void _configureBackups() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup configuration coming soon!')),
    );
  }

  void _clearCache() async {
    final confirmed = await _showConfirmationDialog(
      'Clear Cache',
      'This will clear all cached data. Continue?',
    );
    
    if (confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully!')),
      );
    }
  }

  void _viewPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy view coming soon!')),
    );
  }

  void _configureDataSharing() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data sharing settings coming soon!')),
    );
  }

  void _deleteAllData() async {
    final confirmed = await _showConfirmationDialog(
      'Delete All Data',
      'This will permanently delete all your health data and cannot be undone. Continue?',
    );
    
    if (confirmed) {
      try {
        await _storageService.deleteAllUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete data: $e')),
        );
      }
    }
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile editing coming soon!')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password change coming soon!')),
    );
  }

  void _configureTwoFactor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication coming soon!')),
    );
  }

  void _signOut() async {
    final confirmed = await _showConfirmationDialog(
      'Sign Out',
      'Are you sure you want to sign out?',
    );
    
    if (confirmed) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: $e')),
        );
      }
    }
  }

  void _viewTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service view coming soon!')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support contact coming soon!')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App rating coming soon!')),
    );
  }
}