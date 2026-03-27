import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(context, Icons.arrow_back, AppTheme.pokedexYellow),
        const SizedBox(width: 20),
        _buildButton(context, Icons.info_outline, AppTheme.pokedexLightBlue),
        const SizedBox(width: 20),
        _buildButton(context, Icons.favorite_border, AppTheme.pokedexRed),
      ],
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black26,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidade em desenvolvimento!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
