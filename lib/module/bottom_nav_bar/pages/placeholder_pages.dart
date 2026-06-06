import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64.sp,
            color: const Color(0xFFD4AF37),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your Favorites',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Items you save will appear here.',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 64.sp,
            color: const Color(0xFFD4AF37),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your Profile',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Manage your closet and account settings.',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class AddListingPage extends StatelessWidget {
  const AddListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 64.sp,
            color: const Color(0xFFD4AF37),
          ),
          SizedBox(height: 16.h),
          Text(
            'Create a Listing',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Sell your luxury item in 60 seconds.',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
