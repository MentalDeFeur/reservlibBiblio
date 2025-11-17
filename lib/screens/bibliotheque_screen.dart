import 'package:flutter/material.dart';
import '../models/livre.dart';
import '../services/database_helper.dart';
import '../services/import_export_service.dart';
import 'add_livre_screen.dart';
import 'livre_detail_screen.dart';
import 'add_reservation_screen.dart';

class BibliothequeScreen extends StatefulWidget {
  const BibliothequeScreen({Key? key}) : super(key: key);

  @override
  State<BibliothequeScreen> createState() => _BibliothequeScreenState();
}

class _BibliothequeScreenState extends State<BibliothequeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ImportExportService _importExportService = ImportExportService();
  List<Livre> _livres = [];
  List<Livre> _livresFiltres = [];
  String _critereRecherche = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerLivres();
  }

  Future<void> _chargerLivres() async {
    final livres = await _dbHelper.readAllLivres();
    setState(() {
      _livres = livres;
      _livresFiltres = livres;
    });
  }

  void _filtrerLivres(String query) async {
    if (query.isEmpty) {
      setState(() {
        _livresFiltres = _livres;
      });
      return;
    }

    List<Livre> resultats = [];
    switch (_critereRecherche) {
      case 'Auteur':
        resultats = await _dbHelper.searchLivresByAuteur(query);
        break;
      case 'Thématique':
        resultats = await _dbHelper.searchLivresByThematique(query);
        break;
      case 'Titre':
        resultats = await _dbHelper.searchLivresByTitre(query);
        break;
      case 'Numéro':
        resultats = await _dbHelper.searchLivresByNumero(query);
        break;
      default:
        resultats = _livres.where((livre) {
          final searchLower = query.toLowerCase();
          return livre.titre.toLowerCase().contains(searchLower) ||
              livre.auteur.toLowerCase().contains(searchLower) ||
              livre.thematique.toLowerCase().contains(searchLower) ||
              livre.numero.toLowerCase().contains(searchLower);
        }).toList();
    }

    setState(() {
      _livresFiltres = resultats;
    });
  }

  Future<void> _supprimerLivre(int id) async {
    await _dbHelper.deleteLivre(id);
    _chargerLivres();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livre supprimé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque'),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export') {
                final path = await _importExportService.exporterLivres();
                if (mounted && path != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exporté vers: $path')),
                  );
                }
              } else if (value == 'import') {
                final result = await _importExportService.importerLivres();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor:
                          result['success'] ? Colors.green : Colors.red,
                    ),
                  );
                  if (result['success']) {
                    _chargerLivres();
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Exporter les livres'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Importer des livres'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filtrerLivres('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _filtrerLivres,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _critereRecherche,
                  items: ['Tous', 'Auteur', 'Thématique', 'Titre', 'Numéro']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _critereRecherche = newValue!;
                      _filtrerLivres(_searchController.text);
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _livresFiltres.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun livre trouvé',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _livresFiltres.length,
                    itemBuilder: (context, index) {
                      final livre = _livresFiltres[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: livre.coverUrl != null &&
                                  livre.coverUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    livre.coverUrl!,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          livre.numero,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: 50,
                                        height: 70,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    livre.numero,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                          title: Text(
                            livre.titre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Auteur: ${livre.auteur}'),
                              Text('Thématique: ${livre.thematique}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'reserver') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddReservationScreen(
                                      livrePreselectionne: livre,
                                    ),
                                  ),
                                );
                              } else if (value == 'supprimer') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title:
                                        const Text('Confirmer la suppression'),
                                    content: Text(
                                        'Voulez-vous vraiment supprimer "${livre.titre}" ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _supprimerLivre(livre.id!);
                                        },
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'reserver',
                                child: Row(
                                  children: [
                                    Icon(Icons.event_available,
                                        color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('Réserver'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'supprimer',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Supprimer'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LivreDetailScreen(livre: livre),
                              ),
                            );
                            _chargerLivres();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLivreScreen()),
          );
          // Recharger la liste après ajout/modification
          if (result == true) {
            await _chargerLivres();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
