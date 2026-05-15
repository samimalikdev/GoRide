import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_driver_app/features/auth/presentation/pages/auth_page.dart';
import 'package:goride_driver_app/features/documents/presentation/pages/document_submission_page.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_event.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_state.dart';
import 'package:goride_driver_app/features/profile/presentation/pages/about_app_page.dart';
import 'package:goride_driver_app/features/profile/presentation/pages/support_and_help_page.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _driverData;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(FetchDriverStatusEvent());
    final authState = context.read<AuthBloc>().state;
    if (authState.userId.isNotEmpty) {
      context.read<WalletBloc>().add(FetchWalletData(authState.userId));
    }
  }

  Future<void> _fetchProfile() async {
    context.read<HomeBloc>().add(FetchDriverStatusEvent());
    final authState = context.read<AuthBloc>().state;
    if (authState.userId.isNotEmpty) {
      context.read<WalletBloc>().add(FetchWalletData(authState.userId));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      if (mounted) {
        final authBloc = context.read<AuthBloc>();
        final currentUser = authBloc.state.currentUser;
        if (currentUser != null) {
          authBloc.add(UpdateProfileEvent(
            fullName: currentUser.fullName ?? "Driver",
            profilePicBase64: base64Image,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        } else if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated successfully!")),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload failed: ${state.message}"), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading && _driverData == null) {
            return const Scaffold(
              backgroundColor: Color(0xff0a0a0a),
              body: Center(child: CircularProgressIndicator(color: Color(0xff76eb07))),
            );
          }

          if (state is HomeStatusUpdated) {
            _driverData = state.driverData;
            _isLoadingStatus = false;
          }

          return Scaffold(
            backgroundColor: const Color(0xff0a0a0a),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchProfile,
                color: const Color(0xff76eb07),
                backgroundColor: const Color(0xff1a1a1a),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildProfileCard(),
                      const SizedBox(height: 40),
                      _buildStatGrid(),
                      const SizedBox(height: 40),
                      _buildMenuSection("Account Settings", [
                        _buildMenuItem(
                          "Personal Information", 
                          Icons.person_outline_rounded,
                          onTap: () => _showPersonalDetails(),
                        ),
                        _buildMenuItem(
                          "Vehicle Details", 
                          Icons.directions_car_outlined,
                          onTap: () => _showVehicleDetails(),
                        ),
                        _buildMenuItem(
                          "Documents & Verification", 
                          Icons.verified_user_outlined,
                          trailing: _driverData?['status']?.toString().toUpperCase() ?? "PENDING",
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DocumentSubmissionPage()),
                            );
                          },
                        ),
                      ]),

                      const SizedBox(height: 30),
                      _buildMenuSection("App & Support", [
                        _buildMenuItem(
                          "Support & Help", 
                          Icons.help_outline_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SupportAndHelpPage()),
                            );
                          },
                        ),
                        _buildMenuItem(
                          "About App & Developer", 
                          Icons.info_outline_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AboutAppPage()),
                            );
                          },
                        ),
                      ]),

                      const SizedBox(height: 30),
                      _buildLogoutBtn(context),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "DRIVER PROFILE",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xff1a1a1a),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: const Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.currentUser;
        final profilePic = user?.profilePic;
        final isUploading = authState is AuthLoading;

        return Column(
          children: [
            GestureDetector(
              onTap: isUploading ? null : _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xff76eb07), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xff1a1a1a),
                      backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                          ? NetworkImage(profilePic)
                          : null,
                      child: (profilePic == null || profilePic.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white54, size: 50)
                          : (isUploading ? const CircularProgressIndicator(color: Color(0xff76eb07)) : null),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xff76eb07),
                      shape: BoxShape.circle,
                    ),
                    child: isUploading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?.fullName ?? _driverData?['full_name'] ?? "Sami Malik",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              "Driver ID: #${user?.id.substring(0, 8).toUpperCase() ?? _driverData?['id']?.toString().substring(0, 8).toUpperCase() ?? "N/A"}",
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatGrid() {
    String vehicleName = _driverData?['vehicle_model']?.toString() ?? "";
    if (vehicleName.isEmpty) {
      vehicleName = "N/A";
    }
    final status = _driverData?['status']?.toString().toUpperCase() ?? "ACTIVE";

    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        double earnings = 0.0;
        if (walletState is WalletLoaded) {
          earnings = walletState.balance;
        }

        return Row(
          children: [
            Expanded(child: _buildStatItem(vehicleName, "Vehicle", Icons.directions_car_rounded, Colors.amber)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatItem("Rs. ${earnings.toStringAsFixed(0)}", "Earnings", Icons.account_balance_wallet_rounded, const Color(0xff76eb07))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatItem(status, "Status", Icons.check_circle_outline_rounded, Colors.blueAccent)),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.02),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 15),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xff1a1a1a),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData icon, {String? trailing, bool isSwitch = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (trailing == "APPROVED") ? const Color(0xff76eb07).withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trailing,
                  style: GoogleFonts.outfit(
                    color: (trailing == "APPROVED") ? const Color(0xff76eb07) : Colors.amber, 
                    fontSize: 10, 
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else if (isSwitch)
              Switch(
                value: true,
                onChanged: (v) {},
                activeColor: const Color(0xff76eb07),
                activeTrackColor: const Color(0xff76eb07).withValues(alpha: 0.2),
              )
            else
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  void _showPersonalDetails() {
    _showDetailsBottomSheet("Personal Information", [
      _detailTile("Full Name", _driverData?['full_name'] ?? "N/A"),
      _detailTile("Date of Birth", _driverData?['date_of_birth'] ?? "N/A"),
      _detailTile("City", _driverData?['city'] ?? "N/A"),
      _detailTile("Postal Code", _driverData?['postal_code'] ?? "N/A"),
    ]);
  }

  void _showVehicleDetails() {
    _showDetailsBottomSheet("Vehicle Details", [
      _detailTile("Vehicle Model", _driverData?['vehicle_model'] ?? "N/A"),
      _detailTile("Vehicle Type", _driverData?['vehicle_type'] ?? "Car"),
      _detailTile("Registration Status", "Verified", isVerified: true),
    ]);
  }

  void _showDetailsBottomSheet(String title, List<Widget> children) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0a0a0a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 25),
            ...children,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(String label, String value, {bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14)),
          Row(
            children: [
              Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              if (isVerified) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: Color(0xff76eb07), size: 16),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutBtn(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AuthBloc>().add(LogoutEvent());
      },
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                "LOGOUT SESSION",
                style: GoogleFonts.outfit(
                  color: Colors.redAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
