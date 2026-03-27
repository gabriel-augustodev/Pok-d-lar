import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PokedexAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PokedexAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildMainLight(),
          const SizedBox(width: 10),
          _buildSmallLight(Colors.yellow),
          _buildSmallLight(Colors.green),
          _buildSmallLight(Colors.red),
          const Spacer(),
          const Text(
            'POKÉDEX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainLight() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.pokedexLightBlue,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black26,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallLight(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
