import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ORDER IN PROGRESS', style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600, letterSpacing: 1,
                  )),
                  Text('VILLA-A1 BATCH', style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic,
                  )),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Rider Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                        child: const Icon(Icons.person, size: 28, color: Colors.grey),
                      ),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Juan Doe', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                        Text('ASSIGNED RIDER', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight, letterSpacing: 1)),
                        Row(children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Text(' 57 TRIPS', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ]),
                      ]),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('MARKET PROGRESS', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 10),
                _ProgressBar(),
                const SizedBox(height: 20),
                Text('PICKED ITEMS', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 12),
                _itemCard('🐟', 'Bangus', '1.0 KILO', '₱210.00'),
                const SizedBox(height: 10),
                _itemCard('🌶️', 'Siling Labuyo', '2 PACKS', '₱40.00'),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('ESTIMATED TOTAL', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                        Text('₱275.00', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                      ]),
                      const Spacer(),
                      Text('Delivery Fee Included', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map_outlined, color: AppColors.primaryDark),
                  label: Text('VIEW LIVE MAP', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(String emoji, String name, String qty, String price) {
    return Builder(builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
          Text('$qty • $price', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ]),
    ));
  }
}

class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = ['WET MARKET', 'VEGGIES', 'MEAT ROW', 'SPICES'];
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.35,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((s) => Text(s, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textLight, fontWeight: FontWeight.w600))).toList(),
        ),
      ],
    );
  }
}
