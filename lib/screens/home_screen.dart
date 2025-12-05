import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visual Acuity RPC v1.0'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/home_screen_image.gif',
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/testHome',
                        arguments: {'patientInfo': null},
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.indigo, // Button background color
                        foregroundColor: Colors.white, // Text/icon color
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corners
                        ),
                      ),
                      child: const Text('Start Test'),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                _buildFullWidthButton(
                  context,
                  label: 'Instructions',
                  route: '/instructions',
                ),
                _buildFullWidthButton(
                  context,
                  label: 'Tutorial',
                  route: '/tutorial',
                ),
                _buildFullWidthButton(
                  context,
                  label: 'Calibrate Screen',
                  route: '/calibrate',
                ),
                _buildFullWidthButton(
                  context,
                  label: 'History',
                  route: '/history',
                ),
                _buildFullWidthButton(context, label: 'About', route: '/about'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthButton(
    BuildContext context, {
    required String label,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, route),
          child: Text(label),
        ),
      ),
    );
  }
}
