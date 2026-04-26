import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'models/livre.dart';
import 'screens/add_livre_screen.dart';
import 'screens/bibliotheque_screen.dart';
import 'screens/livre_detail_screen.dart';
import 'screens/reservations_screen.dart';
import 'services/database_helper.dart';
import 'services/sqflite_init_mobile.dart'
    if (dart.library.ffi) 'services/sqflite_init_desktop.dart';

bool get _isDesktop =>
    !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

// ─── Scanner QR / Saisie manuelle ──────────────────────────────────────────

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool _isProcessing = false;

  // ── Logique commune ────────────────────────────────────────────────────────

  Future<void> _handleScannedValue(String value) async {
    final livres = await DatabaseHelper.instance.searchLivresByNumero(value);
    if (!mounted) return;

    if (livres.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LivreDetailScreen(livre: livres.first),
        ),
      );
    } else {
      final livre = Livre(
        titre: '',
        auteur: '',
        thematique: '',
        numero: value,
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddLivreScreen(livre: livre),
        ),
      );
    }
  }

  // ── Mobile : MobileScanner ─────────────────────────────────────────────────

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue == null) continue;
      setState(() => _isProcessing = true);
      await _handleScannedValue(barcode.rawValue!);
      if (mounted) setState(() => _isProcessing = false);
      break;
    }
  }

  Widget _buildMobileScanner() {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(onDetect: _onDetect),
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Text(
            'Pointez vers le QR code d\'un livre',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [Shadow(blurRadius: 6, color: Colors.black)],
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Recherche du livre...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Desktop : saisie manuelle / scanner USB ────────────────────────────────

  final _desktopController = TextEditingController();

  Widget _buildDesktopInput() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.qr_code_scanner, size: 80, color: Colors.indigo),
          const SizedBox(height: 24),
          const Text(
            'Saisir le numéro ou ISBN du livre',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous pouvez aussi brancher un scanner USB de bibliothèque\n(il s\'utilise comme un clavier — scannez directement dans le champ).',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _desktopController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Numéro / ISBN',
              hintText: 'Ex: 9782070360024',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submitDesktop(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _submitDesktop,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(_isProcessing ? 'Recherche...' : 'Rechercher'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDesktop() async {
    final value = _desktopController.text.trim();
    if (value.isEmpty) return;
    setState(() => _isProcessing = true);
    await _handleScannedValue(value);
    if (mounted) {
      _desktopController.clear();
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _desktopController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner / Rechercher'),
        backgroundColor: Colors.indigo,
      ),
      body: _isDesktop ? _buildDesktopInput() : _buildMobileScanner(),
    );
  }
}

// ─── App ────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await initializeSqflite();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bibliothèque & Réservations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Navigation principale ───────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BibliothequeScreen(),
    const ReservationsScreen(),
    const QrScanner(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Bibliothèque',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR Code',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _selectedIndex == 0
            ? Colors.blue
            : _selectedIndex == 1
                ? Colors.green
                : Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}
