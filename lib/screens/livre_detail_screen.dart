import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/livre.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import 'add_livre_screen.dart';
import 'add_reservation_screen.dart';

class LivreDetailScreen extends StatefulWidget {
  final Livre livre;

  const LivreDetailScreen({Key? key, required this.livre}) : super(key: key);

  @override
  State<LivreDetailScreen> createState() => _LivreDetailScreenState();
}

class _LivreDetailScreenState extends State<LivreDetailScreen> {
  final ReservationService _reservationService = ReservationService();
  Reservation? _reservationActive;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerReservation();
  }

  Future<void> _chargerReservation() async {
    final reservation = await _reservationService
        .getReservationActivePourLivre(widget.livre.titre);
    if (mounted) {
      setState(() {
        _reservationActive = reservation;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du livre'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLivreScreen(livre: widget.livre),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Afficher l'image de couverture si disponible
            if (widget.livre.coverUrl != null &&
                widget.livre.coverUrl!.isNotEmpty)
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.livre.coverUrl!,
                      height: 300,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 64, color: Colors.grey),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            if (widget.livre.coverUrl != null &&
                widget.livre.coverUrl!.isNotEmpty)
              const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.livre.coverUrl == null ||
                            widget.livre.coverUrl!.isEmpty)
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 30,
                            child: Text(
                              widget.livre.numero,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (widget.livre.coverUrl == null ||
                            widget.livre.coverUrl!.isEmpty)
                          const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.livre.titre,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildDetailRow(
                        Icons.person, 'Auteur', widget.livre.auteur),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.category, 'Thématique', widget.livre.thematique),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.numbers, 'Numéro', widget.livre.numero),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Date d\'ajout',
                      dateFormat.format(widget.livre.dateAjout),
                    ),
                    if (widget.livre.description != null &&
                        widget.livre.description!.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.livre.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section statut de réservation
            if (_isLoading)
              const Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else
              Card(
                elevation: 4,
                color: _reservationActive != null
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _reservationActive != null
                                ? Icons.block
                                : Icons.check_circle,
                            color: _reservationActive != null
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _reservationActive != null
                                  ? 'Indisponible'
                                  : 'Disponible',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _reservationActive != null
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_reservationActive != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.person,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Réservé par: ${_reservationActive!.nomReservant ?? "Non spécifié"}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Du: ${DateFormat('dd/MM/yyyy à HH:mm').format(_reservationActive!.dateDebut)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.event,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Au: ${DateFormat('dd/MM/yyyy à HH:mm').format(_reservationActive!.dateFin)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event_available,
                                  color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Disponible à partir du: ${DateFormat('dd/MM/yyyy à HH:mm').format(_reservationActive!.dateFin)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Bouton pour créer une réservation
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddReservationScreen(
                        livrePreselectionne: widget.livre,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.event_available),
                label: const Text('Réserver ce livre'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
