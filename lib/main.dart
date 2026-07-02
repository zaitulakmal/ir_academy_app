import 'package:flutter/material.dart';

import 'core/services/firebase_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/role_select_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IrAcademyApp());
}

class IrAcademyApp extends StatelessWidget {
  const IrAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IR Academy',
      theme: AppTheme.light,
      home: const _AppLoader(),
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  bool _ready = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _ready = false; _loadError = null; });
    try {
      await FirebaseService.init();
      await SupabaseService.init();
      await FirebaseService.loadUsers();
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
      return;
    }
    // Non-critical — push notifications aren't supported on every browser
    // (e.g. iOS Safari). Never let this block login.
    try {
      await FirebaseService.requestNotificationPermission();
    } catch (_) {}
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Failed to connect to server',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_loadError!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _load, child: const Text('Try Again')),
              ],
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting…', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return const RoleSelectScreen();
  }
}
