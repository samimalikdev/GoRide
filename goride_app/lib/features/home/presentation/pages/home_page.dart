import 'package:flutter/material.dart';
import 'package:goride_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:goride_app/features/explore/presentation/pages/explore_page.dart';
import 'package:goride_app/features/profile/presentation/pages/profile_page.dart';
import 'package:goride_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:goride_app/features/wallet/presentation/pages/wallet_page.dart';
import '../../../../core/presentation/widgets/custom_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 

  final List<Widget> _pages = [
    const ExplorePage(),    
    const BookingsPage(),  
    const ChatListPage(),   
    const WalletPage(),     
    const ProfilePage(),   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0a0a0a),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _buildCenterFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCenterFab() {
    bool isExploreSelected = _selectedIndex == 0;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = 0); 
      },
      child: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          color: const Color(0xff76eb07),
          shape: BoxShape.circle,
          border: isExploreSelected 
              ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3) 
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff76eb07).withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const Icon(Icons.directions_car_filled_rounded, color: Colors.black, size: 30),
      ),
    );
  }
}
