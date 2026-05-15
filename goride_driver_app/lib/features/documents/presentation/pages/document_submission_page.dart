import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_driver_app/features/auth/presentation/pages/auth_page.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_event.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_state.dart';
import 'package:goride_driver_app/features/home/presentation/pages/main_navigation_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DocumentSubmissionPage extends StatefulWidget {
  const DocumentSubmissionPage({super.key});

  @override
  State<DocumentSubmissionPage> createState() => _DocumentSubmissionPageState();
}

class _DocumentSubmissionPageState extends State<DocumentSubmissionPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Map<String, String?> _selectedFiles = {};

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(FetchDriverStatusEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleController.dispose();
    _dobController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String docKey) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedFiles[docKey] = image.path;
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedFiles.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    Position? position;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }
    } catch (e) {
      print('DOCS_PAGE: Could not get location: $e');
    }

    if (!mounted) return;
    context.read<HomeBloc>().add(SubmitVerificationEvent(
      fullName: _nameController.text,
      dateOfBirth: _dobController.text,
      vehicleModel: _vehicleController.text,
      vehicleType: 'Car',
      city: _cityController.text,
      postalCode: _postalCodeController.text,
      latitude: position?.latitude ?? 0.0,
      longitude: position?.longitude ?? 0.0,
      documentPaths: _selectedFiles,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        }
      },
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
        if (state is HomeStatusUpdated && state.verificationStatus == 'approved') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          );
        } else if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is HomeLoading;
        final Map<String, dynamic> driverData = (state is HomeStatusUpdated) ? state.driverData : {};
        final String status = (state is HomeStatusUpdated) ? state.verificationStatus : 'none';
        final bool isWaiting = status == 'pending';

        return Scaffold(
          backgroundColor: const Color(0xff0a0a0a),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isWaiting) _buildReviewBanner(),
                        const SizedBox(height: 20),
                        _buildStepHeader(status),
                        const SizedBox(height: 35),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader("Personal Details", "Information for your driver profile"),
                              const SizedBox(height: 20),
                              _buildTextField(_nameController, "Full Name", Icons.person_outline_rounded, "Enter your legal name"),
                              const SizedBox(height: 15),
                              _buildTextField(_dobController, "Date of Birth", Icons.calendar_today_rounded, "DD/MM/YYYY", isDate: true),
                              const SizedBox(height: 35),
                              _buildSectionHeader("Vehicle Info", "Tell us about your ride"),
                              const SizedBox(height: 20),
                              _buildTextField(_vehicleController, "Vehicle Model", Icons.directions_car_outlined, "e.g. Toyota Corolla 2022"),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField(_cityController, "City", Icons.location_city_rounded, "e.g. Lahore")),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildTextField(_postalCodeController, "Postal Code", Icons.markunread_mailbox_rounded, "e.g. 54000")),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),
                        _buildSectionHeader("Identification Documents", "Required for background check"),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildDocCard("CNIC Front", Icons.badge_rounded, "cnic_front", driverData)),
                            const SizedBox(width: 15),
                            Expanded(child: _buildDocCard("CNIC Back", Icons.badge_rounded, "cnic_back", driverData)),
                          ],
                        ),
                        const SizedBox(height: 35),
                        _buildSectionHeader("Driving Privileges", "Valid license is mandatory"),
                        const SizedBox(height: 20),
                        _buildDocCard("Driving License Front", Icons.contact_emergency_rounded, "license_front", driverData, isFullWidth: true),
                        const SizedBox(height: 35),
                        _buildSectionHeader("Vehicle Information", "Registration and visual verification"),
                        const SizedBox(height: 20),
                        _buildDocCard("Car Registration Book", Icons.menu_book_rounded, "reg_book", driverData, isFullWidth: true),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildDocCard("Car Front View", Icons.directions_car_rounded, "car_front", driverData)),
                            const SizedBox(width: 15),
                            Expanded(child: _buildDocCard("Car Back View", Icons.directions_car_rounded, "car_back", driverData)),
                          ],
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: _buildSubmitPanel(isLoading, status, driverData),
        );
      },
    ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff1a1a1a),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          Text(
            "VERIFICATION",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white54, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xff76eb07).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff76eb07).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xff76eb07), size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "APPLICATION UNDER REVIEW",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                ),
                Text(
                  "Status updated recently",
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.read<HomeBloc>().add(FetchDriverStatusEvent()),
            child: Text("REFRESH", style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String status) {
    double progress = 0.5;
    if (status == 'pending') progress = 0.9;
    if (status == 'approved') progress = 1.0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xff76eb07).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.3)),
          ),
          child: Text(
            status == 'pending' ? "STEP 02" : "STEP 01",
            style: GoogleFonts.outfit(
              color: const Color(0xff76eb07),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: const Color(0xff76eb07),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String hint, {bool isDate = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
        readOnly: isDate,
        onTap: isDate ? () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now().subtract(const Duration(days: 6570)),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xff76eb07),
                    onPrimary: Colors.black,
                    surface: Color(0xff1a1a1a),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            setState(() {
              _dobController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        } : null,
        validator: (value) => value == null || value.isEmpty ? "Required field" : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xff76eb07), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDocCard(String label, IconData icon, String docKey, Map<String, dynamic> driverData, {bool isFullWidth = false}) {
    final bool isLocalSelected = _selectedFiles.containsKey(docKey);
    final String? localPath = _selectedFiles[docKey];
    final String serverStatus = driverData['${docKey}_status'] ?? 'none';

    return GestureDetector(
      onTap: () => _pickImage(docKey),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isLocalSelected ? const Color(0xff76eb07) : Colors.white.withValues(alpha: 0.05),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (isLocalSelected && localPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(localPath),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xff76eb07).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xff76eb07), size: 32),
              ),
            const SizedBox(height: 15),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isLocalSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isLocalSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _buildDocStatusText(serverStatus, isLocalSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildDocStatusText(String status, bool isSelected) {
    if (status == 'approved') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xff76eb07), size: 14),
          const SizedBox(width: 5),
          Text("APPROVED", style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      );
    } else if (status == 'rejected') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 14),
          const SizedBox(width: 5),
          Text("REJECTED - RETAP", style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      );
    } else if (status == 'pending') {
      return Text("UNDER REVIEW", style: GoogleFonts.outfit(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.w900));
    }
    return Text(
      isSelected ? "READY" : "TAP TO UPLOAD",
      style: GoogleFonts.outfit(color: isSelected ? const Color(0xff76eb07) : Colors.white24, fontSize: 10, fontWeight: FontWeight.w900),
    );
  }

  Widget _buildSubmitPanel(bool isLoading, String status, Map<String, dynamic> driverData) {
    bool hasRejected = false;
    const docKeys = ['cnic_front', 'cnic_back', 'license_front', 'reg_book', 'car_front', 'car_back'];
    for (var key in docKeys) {
      if (driverData['${key}_status'] == 'rejected') hasRejected = true;
    }

    bool canSubmit = !isLoading && (status == 'none' || status == 'rejected' || hasRejected);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xff1a1a1a),
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton(
              onPressed: canSubmit ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff76eb07),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: isLoading 
                ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                : Text(
                    "SUBMIT DOCUMENTS",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
