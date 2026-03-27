import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CustomErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.pokedexRed,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: AppTheme.pokedexGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.pokedexLightBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('TENTAR NOVAMENTE'),
          ),
        ],
      ),
    );
  }
}
