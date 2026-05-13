import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service.dart';
import '../../../core/theme.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getProfile();
      setState(() {
        _userData = res;
        _nameController.text = res['name'] ?? '';
        _emailController.text = res['email'] ?? '';
        _departmentController.text = res['department'] ?? '';
        _positionController.text = res['position'] ?? '';
        _addressController.text = res['address'] ?? '';
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'department': _departmentController.text,
        'position': _positionController.text,
        'address': _addressController.text,
      };
      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      await _apiService.updateProfile(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green));
        _passwordController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) context.go('/user-login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _userData == null) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.pageBackground,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: AppTheme.danger), onPressed: _logout)
        ],
      ),
      body: Container(
        decoration: AppTheme.pageBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${_nameController.text.replaceAll(' ', '+')}&background=6366f1&color=ffffff'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.background, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _nameController.text.isEmpty ? 'Employee Profile' : _nameController.text,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.panelDecoration(radius: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                    const SizedBox(height: 16),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
                    const SizedBox(height: 16),
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
                    const SizedBox(height: 16),
                    TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'New Password (Optional)', prefixIcon: Icon(Icons.lock_outline)), obscureText: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.panelDecoration(radius: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Employee Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                    const SizedBox(height: 16),
                    TextField(controller: _departmentController, decoration: const InputDecoration(labelText: 'Department (e.g. IT, HR)', prefixIcon: Icon(Icons.domain))),
                    const SizedBox(height: 16),
                    TextField(controller: _positionController, decoration: const InputDecoration(labelText: 'Position / Jabatan', prefixIcon: Icon(Icons.work_outline))),
                    const SizedBox(height: 16),
                    TextField(controller: _addressController, maxLines: 3, decoration: const InputDecoration(labelText: 'Home Address', prefixIcon: Icon(Icons.home_outlined))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
