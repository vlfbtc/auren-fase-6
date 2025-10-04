import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final bool showAppBar;

  const AboutScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: primaryColor,
              title: const Text('Auren', style: TextStyle(color: Colors.white)),
              elevation: 0,
            )
          : null,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Auren',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Custom logo image
                Image.asset(
                  'assets/images/ic_auren_logo.png',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 24),

                // App name in larger size
                Text(
                  'Auren',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Developed by section
                const Text(
                  'Desenvolvido por:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Developer list
                _buildDeveloperItem('Catherine Mian Palhares'),
                _buildDeveloperItem('Rafael Bossert Borring'),
                _buildDeveloperItem('Ramon Vitor Domingues de Moraes'),
                _buildDeveloperItem('Vanderlei Lopes Ferreira'),

                const SizedBox(height: 40),

                // Copyright
                Text(
                  '© ${DateTime.now().year}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperItem(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            name,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
