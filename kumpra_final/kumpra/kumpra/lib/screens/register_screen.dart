// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  List<dynamic> _clusters = [];
  String _selectedClusterId = '';
  String _selectedClusterName = 'Select Your Barangay';
  
  bool _loading = false;
  bool _fetchingClusters = true;

  @override
  void initState() {
    super.initState();
    _loadClusters();
  }

  void _loadClusters() async {
    final res = await AuthService.getClusters();
    if (res['success'] == true) {
      setState(() {
        _clusters = res['clusters'];
        _fetchingClusters = false;
        if (_clusters.isNotEmpty) {
          _selectedClusterId = _clusters[0]['cluster_id'].toString();
          _selectedClusterName = _clusters[0]['name'];
        }
      });
    } else {
      setState(() => _fetchingClusters = false);
      _showSnack("Error loading barangays.");
    }
  }

  void _register() async {
    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String phone = _phoneController.text.trim();

    print('Name: "$name", Username: "$username", Phone: "$phone", Cluster: "$_selectedClusterId"');

    if (name.isEmpty || username.isEmpty || phone.length != 11 || !RegExp(r'^09\d{9}$').hasMatch(phone)) {
      _showSnack('Please enter a valid name, username, and 11-digit phone number starting with 09');
      return;
    }

    setState(() => _loading = true);
    
    // We will use a registration method in AuthService
    final res = await AuthService.register(name, username, phone, _selectedClusterId);
    
    setState(() => _loading = false);

    if (res['success'] == true) {
      _showSnack('Account created! Logging you in...');
      await AuthService.saveSession(res['user']);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    } else {
      _showSnack(res['message'] ?? 'Registration failed');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.primaryDark,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join KUMPRA',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'Create an account to start batching orders.',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              // NAME FIELD
              _buildField(
                controller: _nameController,
                label: 'FULL NAME',
                hint: 'Juan Dela Cruz',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // USERNAME FIELD
              _buildField(
                controller: _usernameController,
                label: 'USERNAME',
                hint: 'johndoe',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 16),

              // PHONE FIELD
              _buildField(
                controller: _phoneController,
                label: 'MOBILE NUMBER',
                hint: '09123456789',
                icon: Icons.phone_android_outlined,
                isPhone: true,
              ),
              const SizedBox(height: 16),

              // CLUSTER SELECTOR
              GestureDetector(
                onTap: _fetchingClusters ? null : _showClusterPicker,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('YOUR BARANGAY', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                            Text(_selectedClusterName.toUpperCase(), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text('CREATE ACCOUNT', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, required String label, required String hint, required IconData icon, bool isPhone = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        maxLength: isPhone ? 11 : 50,
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.primary),
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight),
          hintText: hint,
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  void _showClusterPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: ListView.builder(
          itemCount: _clusters.length,
          itemBuilder: (context, index) {
            final c = _clusters[index];
            return ListTile(
              title: Text(c['name']),
              onTap: () {
                setState(() {
                  _selectedClusterId = c['cluster_id'].toString();
                  _selectedClusterName = c['name'];
                });
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}