// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Notes App',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Developer'),
                  subtitle: Text('Emmanuel Apabiekun'),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Contact'),
                  subtitle: Text('emmanuelapabiekun@gmail.com'),
                  onTap: () => _launchUrl('mailto:emmanuelapabiekun@gmail.com'),
                ),
                ListTile(
                  leading: Icon(Icons.link),
                  title: Text('Website'),
                  subtitle: Text('Creator\'s Website'),
                  onTap: () => _launchUrl('https://www.apabiekunemmanuel.com'),
                ),
                ListTile(
                  leading: Icon(Icons.link),
                  title: Text('GitHub'),
                  subtitle: Text('github.com/ekunemmanuel'),
                  onTap: () => _launchUrl('https://github.com/ekunemmanuel'),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About This App',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                      'This is a feature-rich note-taking application built with Flutter. '
                      'It includes features like:'),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• Create and edit notes'),
                        Text('• Customizable themes'),
                        Text('• Dark mode support'),
                        Text('• Adjustable font sizes'),
                        Text('• Multiple font families'),
                        Text('• Batch note operations'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
