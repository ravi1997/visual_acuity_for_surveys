import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.remove_red_eye,
                    size: 90,
                    color: Colors.indigo.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Visual Acuity For RPC",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// ABOUT SECTION
            const Text(
              "About This App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "This application is designed to capture and track visual acuity test results "
              "in a fast and standardized manner. It helps ophthalmologists and clinicians "
              "record multiple vision parameters including UVA, CVA, PinVA and Near Vision "
              "with ease.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            /// FEATURES
            const Text(
              "Key Features",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            buildFeature(
              icon: Icons.radio_button_checked,
              title: "Multiple Vision Modes",
              subtitle: "Right eye / Left eye, UVA, CVA, PinVA and Near Vision",
            ),
            buildFeature(
              icon: Icons.library_books_outlined,
              title: "Patient Test History",
              subtitle: "Automatically stores each test in a spreadsheet log",
            ),
            buildFeature(
              icon: Icons.analytics_outlined,
              title: "Smart Test Flow",
              subtitle: "Detects completed vision types & marks them as done",
            ),
            buildFeature(
              icon: Icons.shield_outlined,
              title: "Secure Local Storage",
              subtitle: "Data is stored on device only, no internet required",
            ),

            const SizedBox(height: 24),

            /// DISCLAIMER
            const Text(
              "Disclaimer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "This application is intended to assist clinicians in recording visual acuity. "
              "It is not a substitute for a diagnostic clinical examination. Please consult "
              "a licensed ophthalmologist for medical advice and treatment decisions.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),

            /// COPYRIGHT / CREDITS
            Center(
              child: Column(
                children: [
                  Divider(color: Colors.grey.shade400, thickness: 1),
                  const SizedBox(height: 16),
                  Text(
                    "Developed at RPC, AIIMS",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade400, thickness: 1),
                  const SizedBox(height: 16),

                  const Text(
                    "Developed By",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Ravinder Singh",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Programmer, AIIMS New Delhi",
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "© 2026 All rights reserved",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A helper widget to keep feature tiles consistent
  Widget buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
