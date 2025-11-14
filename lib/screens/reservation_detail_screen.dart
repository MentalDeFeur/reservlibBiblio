import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import 'add_reservation_screen.dart';

class ReservationDetailScreen extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailScreen({Key? key, required this.reservation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final maintenant = DateTime.now();
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (reservation.dateFin.isBefore(maintenant)) {
      statusColor = Colors.grey;
      statusText = 'Terminée';
      statusIcon = Icons.check_circle;
    } else if (reservation.dateDebut.isBefore(maintenant) && reservation.dateFin.isAfter(maintenant)) {
      statusColor = Colors.green;
      statusText = 'En cours';
      statusIcon = Icons.play_circle;
    } else {
      statusColor = Colors.blue;
      statusText = 'À venir';
      statusIcon = Icons.upcoming;
    }

    final duree = reservation.dateFin.difference(reservation.dateDebut);
    final heures = duree.inHours;
    final minutes = duree.inMinutes % 60;
    String dureeText = '';
    if (heures > 0) {
      dureeText += '$heures h ';
    }
    if (minutes > 0 || heures == 0) {
      dureeText += '$minutes min';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddReservationScreen(reservation: reservation),
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
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reservation.titre,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildDetailRow(
                      Icons.event_available,
                      'Date de début',
                      dateFormat.format(reservation.dateDebut),
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.event_busy,
                      'Date de fin',
                      dateFormat.format(reservation.dateFin),
                      Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.access_time,
                      'Durée',
                      dureeText,
                      Colors.orange,
                    ),
                    if (reservation.nomReservant != null &&
                        reservation.nomReservant!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.person,
                        'Réservé par',
                        reservation.nomReservant!,
                        Colors.blue,
                      ),
                    ],
                    if (reservation.categorie != null &&
                        reservation.categorie!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.category,
                        'Catégorie',
                        reservation.categorie!,
                        Colors.purple,
                      ),
                    ],
                    if (reservation.description != null &&
                        reservation.description!.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reservation.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
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
