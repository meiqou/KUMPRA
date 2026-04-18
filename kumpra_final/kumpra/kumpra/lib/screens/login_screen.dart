// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Dynamic variables for database data
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

  // Calls the Hostinger API to fill the cluster list
  void _loadClusters() async {
    final res = await AuthService.getClusters();
    if (res['success'] == true) {
      setState(() {
        _clusters = res['clusters'];
        _fetchingClusters = false;
        
        // Auto-select the first one if available
        if (_clusters.isNotEmpty) {
          _selectedClusterId = _clusters[0]['cluster_id'].toString();
          _selectedClusterName = _clusters[0]['name'];
        }
      });
    } else {
      setState(() => _fetchingClusters = false);
      _showSnack("Could not load barangays. Check connection.");
    }
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();

    if (username.isEmpty) {
      _showSnack('Enter your username');
      return;
    }
    if (phone.length < 11) {
      _showSnack('Enter a valid 11-digit mobile number');
      return;
    }
    if (_selectedClusterId.isEmpty) {
      _showSnack('Please select a cluster');
      return;
    }

    setState(() => _loading = true);
    final res = await AuthService.login(username, phone, _selectedClusterId);
    setState(() => _loading = false);

    if (res['success'] == true) {
      await AuthService.saveSession(res['user']);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      _showSnack(res['message'] ?? 'Login failed');
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'KUMPRA',
                  style: GoogleFonts.poppins(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              // CLUSTER SELECTOR (Dynamic)
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
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _fetchingClusters 
                          ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR CLUSTER',
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1),
                            ),
                            Text(
                              _selectedClusterName.toUpperCase(),
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // USERNAME FIELD
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44, margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Icon(Icons.alternate_email, color: AppColors.primary)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'johndoe',
                          hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
                          labelText: 'USERNAME',
                          labelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(right: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // PHONE FIELD
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44, margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('#', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        decoration: InputDecoration(
                          hintText: '09XX XXX XXXX',
                          hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
                          labelText: 'MOBILE NUMBER',
                          labelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1),
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: const EdgeInsets.only(right: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text('LOGIN', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 40),
              
              // SIGN UP LINK
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign up',
                          style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Your Cluster', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _clusters.length,
                itemBuilder: (context, index) {
                  final c = _clusters[index];
                  return ListTile(
                    title: Text(c['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    leading: const Icon(Icons.location_on, color: AppColors.primary),
                    selected: _selectedClusterId == c['cluster_id'].toString(),
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
          ],
        ),
      ),
    );
  }
}