import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:image_picker/image_picker.dart';

class ManageProfilePage extends StatefulWidget {
  const ManageProfilePage({super.key});

  @override
  State<ManageProfilePage> createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends State<ManageProfilePage> {
  late TextEditingController _nameController;
  String? _profilePicBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _profilePicBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      print('Failed to pick image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to pick image: $e", style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.poppins(color: Colors.white)),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile updated successfully!", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xff76eb07),
            ),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final user = state.currentUser;
        final isLoading = state is AuthLoading;

        ImageProvider? imageProvider;
        if (_profilePicBase64 != null) {
          imageProvider = MemoryImage(base64Decode(_profilePicBase64!));
        } else if (user?.profilePic != null && user!.profilePic!.isNotEmpty) {
          imageProvider = NetworkImage(user.profilePic!);
        }

        return Scaffold(
          backgroundColor: const Color(0xff0a0a0a),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              "Manage Profile",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: isLoading ? null : _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xff1a1a1a),
                          border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.5), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff76eb07).withValues(alpha: 0.15),
                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                          ],
                          image: imageProvider != null
                              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                              : null,
                        ),
                        child: imageProvider == null
                            ? Center(
                                child: Text(
                                  user?.fullName.isNotEmpty == true
                                      ? user!.fullName[0].toUpperCase()
                                      : 'U',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xff76eb07),
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xff76eb07),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Tap to update photo",
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 40),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "FULL NAME",
                    style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xff1a1a1a),
                    prefixIcon: const Icon(Icons.person_rounded, color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xff76eb07), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "EMAIL ADDRESS",
                    style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: user?.email ?? '',
                  readOnly: true,
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xff121212),
                    prefixIcon: const Icon(Icons.email_rounded, color: Colors.white38),
                    suffixIcon: const Icon(Icons.lock_rounded, color: Colors.white24, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email address cannot be changed directly for security reasons.",
                    style: GoogleFonts.poppins(color: Colors.white24, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            final newName = _nameController.text.trim();
                            if (newName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Name cannot be empty", style: GoogleFonts.poppins(color: Colors.white)),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            context.read<AuthBloc>().add(
                                  UpdateProfileEvent(
                                    fullName: newName,
                                    profilePicBase64: _profilePicBase64,
                                  ),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff76eb07),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                          )
                        : Text(
                            "Save Changes",
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
