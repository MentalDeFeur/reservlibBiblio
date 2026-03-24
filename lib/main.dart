import 'package:bibliotheque_app/screens/add_livre_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'screens/bibliotheque_screen.dart';
import 'screens/reservations_screen.dart';
import 'services/sqflite_init_mobile.dart'
    if (dart.library.ffi) 'services/sqflite_init_desktop.dart';

class QrScanner extends StatelessWidget {
  const QrScanner({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner QR Code'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');

            Navigator.pop(context,
                barcode.rawValue); // Retourne la valeur du QR code scanné

            if (barcode.rawValue != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('QR Code scanné: ${barcode.rawValue}')),
              );
              final livre = Livre(
                id: int.parse(barcode.rawValue!),
                titre: 'Titre du livre',
                auteur: 'Auteur du livre',
                disponible: true,
              );
              final addLivreScreen = AddLivreScreen(, livre);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => addLivreScreen),
              );
            }
          }
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser sqflite (la fonction appropriée sera appelée selon la plateforme)
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
                : Colors.yellow,
        onTap: _onItemTapped,
      ),
    );
  }
}
