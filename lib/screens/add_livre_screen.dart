import 'package:flutter/material.dart';
import '../models/livre.dart';
import '../services/database_helper.dart';
import '../services/isbn_service.dart';

class AddLivreScreen extends StatefulWidget {
  final Livre? livre;

  const AddLivreScreen({Key? key, this.livre}) : super(key: key);

  @override
  State<AddLivreScreen> createState() => _AddLivreScreenState();
}

class _AddLivreScreenState extends State<AddLivreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  final _titreController = TextEditingController();
  final _auteurController = TextEditingController();
  final _thematiqueController = TextEditingController();
  final _numeroController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoadingIsbn = false;
  String? _coverUrl;

  @override
  void initState() {
    super.initState();
    if (widget.livre != null) {
      _titreController.text = widget.livre!.titre;
      _auteurController.text = widget.livre!.auteur;
      _thematiqueController.text = widget.livre!.thematique;
      _numeroController.text = widget.livre!.numero;
      _descriptionController.text = widget.livre!.description ?? '';
      _coverUrl = widget.livre!.coverUrl;
    }
  }

  Future<void> _searchByIsbn() async {
    final isbn = _isbnController.text.trim();
    if (isbn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un ISBN')),
      );
      return;
    }

    setState(() {
      _isLoadingIsbn = true;
    });

    try {
      final bookInfo = await IsbnService.fetchBookByIsbn(isbn);

      if (bookInfo != null) {
        setState(() {
          _titreController.text = bookInfo['titre'] ?? '';
          _auteurController.text = bookInfo['auteur'] ?? '';
          _thematiqueController.text = bookInfo['thematique'] ?? '';
          _descriptionController.text = bookInfo['description'] ?? '';
          _numeroController.text = bookInfo['isbn'] ?? '';
          _coverUrl = bookInfo['coverUrl'];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Informations du livre récupérées avec succès')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun livre trouvé pour cet ISBN')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la recherche: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingIsbn = false;
        });
      }
    }
  }

  Future<void> _saveLivre() async {
    if (_formKey.currentState!.validate()) {
      try {
        final livre = Livre(
          id: widget.livre?.id,
          titre: _titreController.text.trim(),
          auteur: _auteurController.text.trim(),
          thematique: _thematiqueController.text.trim(),
          numero: _numeroController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          coverUrl: _coverUrl,
          dateAjout: widget.livre?.dateAjout,
        );

        print('Tentative de sauvegarde du livre: ${livre.titre}');

        if (widget.livre == null) {
          final savedLivre = await DatabaseHelper.instance.createLivre(livre);
          print('Livre créé avec ID: ${savedLivre.id}');
        } else {
          await DatabaseHelper.instance.updateLivre(livre);
          print('Livre mis à jour avec ID: ${livre.id}');
        }

        if (mounted) {
          Navigator.pop(context, true); // Retourner true pour indiquer succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.livre == null
                  ? 'Livre ajouté avec succès'
                  : 'Livre modifié avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Erreur lors de la sauvegarde du livre: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la sauvegarde: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.livre == null ? 'Ajouter un livre' : 'Modifier le livre'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section de recherche par ISBN
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Rechercher par ISBN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _isbnController,
                              decoration: const InputDecoration(
                                labelText: 'ISBN',
                                hintText: 'Ex: 9780134685991',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isLoadingIsbn ? null : _searchByIsbn,
                            icon: _isLoadingIsbn
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.search),
                            label: const Text('Rechercher'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _auteurController,
                decoration: const InputDecoration(
                  labelText: 'Auteur',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un auteur';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thematiqueController,
                decoration: const InputDecoration(
                  labelText: 'Thématique',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une thématique';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Numéro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un numéro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Aperçu de l'image de couverture
              if (_coverUrl != null && _coverUrl!.isNotEmpty)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Aperçu de la couverture',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _coverUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, size: 48),
                                        SizedBox(height: 8),
                                        Text('Impossible de charger l\'image'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[100],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveLivre,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.livre == null ? 'Ajouter' : 'Modifier',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isbnController.dispose();
    _titreController.dispose();
    _auteurController.dispose();
    _thematiqueController.dispose();
    _numeroController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
