import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showLegalMoves = true;
  bool _showLastMove = true;
  int _timeControl = 10; // 10 minutes per player
  String _boardStyle = 'Classic';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Game Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show Legal Moves'),
                    subtitle: const Text('Highlight possible moves for selected piece'),
                    value: _showLegalMoves,
                    onChanged: (value) {
                      setState(() {
                        _showLegalMoves = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Last Move'),
                    subtitle: const Text('Highlight the last move played'),
                    value: _showLastMove,
                    onChanged: (value) {
                      setState(() {
                        _showLastMove = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time Control',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Time per player'),
                    subtitle: Text('$_timeControl minutes'),
                    trailing: DropdownButton<int>(
                      value: _timeControl,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _timeControl = value;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 5,
                          child: Text('5 minutes'),
                        ),
                        DropdownMenuItem(
                          value: 10,
                          child: Text('10 minutes'),
                        ),
                        DropdownMenuItem(
                          value: 15,
                          child: Text('15 minutes'),
                        ),
                        DropdownMenuItem(
                          value: 30,
                          child: Text('30 minutes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Board Style'),
                    subtitle: Text(_boardStyle),
                    trailing: DropdownButton<String>(
                      value: _boardStyle,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _boardStyle = value;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'Classic',
                          child: Text('Classic'),
                        ),
                        DropdownMenuItem(
                          value: 'Wood',
                          child: Text('Wood'),
                        ),
                        DropdownMenuItem(
                          value: 'Modern',
                          child: Text('Modern'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Save settings
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}