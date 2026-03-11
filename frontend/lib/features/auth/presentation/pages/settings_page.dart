import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Portuguese',
    'Chinese',
    'Japanese',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('APPEARANCE'),
          _buildThemeTile(),
          const Divider(height: 32),
          _buildSectionHeader('LANGUAGE'),
          _buildLanguageTile(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF3B5BDB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.dark_mode_outlined, color: Color(0xFF3B5BDB)),
      ),
      title: const Text(
        'Dark Mode',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        _isDarkMode ? 'On' : 'Off',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: _isDarkMode,
        onChanged: (value) {
          setState(() {
            _isDarkMode = value;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Dark mode ${value ? 'enabled' : 'disabled'}. Theme switching coming soon!',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        activeColor: const Color(0xFF3B5BDB),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.language, color: Colors.orange),
      ),
      title: const Text(
        'Language',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        _selectedLanguage,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () => _showLanguageBottomSheet(),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(),
              ..._languages.map((language) => _buildLanguageOption(language)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = language == _selectedLanguage;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(
        language,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? const Color(0xFF3B5BDB) : Colors.black87,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: Color(0xFF3B5BDB)) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Language changed to $language. Localization coming soon!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
