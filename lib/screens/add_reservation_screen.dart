import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';

class AddReservationScreen extends StatefulWidget {
  final Reservation? reservation;

  const AddReservationScreen({Key? key, this.reservation}) : super(key: key);

  @override
  State<AddReservationScreen> createState() => _AddReservationScreenState();
}

class _AddReservationScreenState extends State<AddReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _nomReservantController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categorieController = TextEditingController();
  
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      _titreController.text = widget.reservation!.titre;
      _nomReservantController.text = widget.reservation!.nomReservant ?? '';
      _descriptionController.text = widget.reservation!.description ?? '';
      _categorieController.text = widget.reservation!.categorie ?? '';
      _dateDebut = widget.reservation!.dateDebut;
      _dateFin = widget.reservation!.dateFin;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDebut) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? _dateDebut : _dateFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isDebut ? _dateDebut : _dateFin),
      );
      if (timePicked != null) {
        setState(() {
          final newDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
          if (isDebut) {
            _dateDebut = newDateTime;
            if (_dateDebut.isAfter(_dateFin)) {
              _dateFin = _dateDebut.add(const Duration(hours: 1));
            }
          } else {
            _dateFin = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveReservation() async {
    if (_formKey.currentState!.validate()) {
      if (_dateFin.isBefore(_dateDebut) || _dateFin.isAtSameMomentAs(_dateDebut)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La date de fin doit être après la date de début'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final reservationService = ReservationService();
      
      // Vérifier la disponibilité
      final disponible = await reservationService.verifierDisponibilite(
        _dateDebut,
        _dateFin,
        excludeId: widget.reservation?.id,
      );

      if (!disponible) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Conflit de réservation'),
              content: const Text(
                  'Ce créneau est déjà réservé. Voulez-vous continuer quand même ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmerSauvegarde();
                  },
                  child: const Text('Continuer'),
                ),
              ],
            ),
          );
        }
      } else {
        _confirmerSauvegarde();
      }
    }
  }

  Future<void> _confirmerSauvegarde() async {
    final reservation = Reservation(
      id: widget.reservation?.id,
      titre: _titreController.text.trim(),
      dateDebut: _dateDebut,
      dateFin: _dateFin,
      nomReservant: _nomReservantController.text.trim().isEmpty
          ? null
          : _nomReservantController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      categorie: _categorieController.text.trim().isEmpty
          ? null
          : _categorieController.text.trim(),
    );

    final reservationService = ReservationService();

    if (widget.reservation == null) {
      await reservationService.createReservation(reservation);
    } else {
      await reservationService.updateReservation(reservation);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.reservation == null
              ? 'Réservation créée avec succès'
              : 'Réservation modifiée avec succès'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservation == null
            ? 'Nouvelle réservation'
            : 'Modifier la réservation'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
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
                controller: _nomReservantController,
                decoration: const InputDecoration(
                  labelText: 'Nom du réservant (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categorieController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.green),
                  title: const Text('Date et heure de début'),
                  subtitle: Text(dateFormat.format(_dateDebut)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.red),
                  title: const Text('Date et heure de fin'),
                  subtitle: Text(dateFormat.format(_dateFin)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _selectDate(context, false),
                ),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.reservation == null ? 'Créer' : 'Modifier',
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
    _titreController.dispose();
    _nomReservantController.dispose();
    _descriptionController.dispose();
    _categorieController.dispose();
    super.dispose();
  }
}
