import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../services/import_export_service.dart';
import 'add_reservation_screen.dart';
import 'reservation_detail_screen.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  final ImportExportService _importExportService = ImportExportService();
  List<Reservation> _reservations = [];
  String _filtreVue = 'Toutes';

  @override
  void initState() {
    super.initState();
    _chargerReservations();
  }

  Future<void> _chargerReservations() async {
    List<Reservation> reservations;

    switch (_filtreVue) {
      case 'Aujourd\'hui':
        reservations =
            await _reservationService.getReservationsParDate(DateTime.now());
        break;
      case 'Cette semaine':
        final maintenant = DateTime.now();
        final debutSemaine =
            maintenant.subtract(Duration(days: maintenant.weekday - 1));
        final finSemaine = debutSemaine.add(const Duration(days: 6));
        reservations = await _reservationService.getReservationsParPeriode(
            debutSemaine, finSemaine);
        break;
      case 'Ce mois':
        final maintenant = DateTime.now();
        final debutMois = DateTime(maintenant.year, maintenant.month, 1);
        final finMois = DateTime(maintenant.year, maintenant.month + 1, 0);
        reservations = await _reservationService.getReservationsParPeriode(
            debutMois, finMois);
        break;
      default:
        reservations = await _reservationService.readAllReservations();
    }

    setState(() {
      _reservations = reservations;
    });
  }

  Future<void> _supprimerReservation(int id) async {
    await _reservationService.deleteReservation(id);
    _chargerReservations();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation supprimée')),
      );
    }
  }

  Color _getColorForReservation(Reservation reservation) {
    final maintenant = DateTime.now();
    if (reservation.dateFin.isBefore(maintenant)) {
      return Colors.grey;
    } else if (reservation.dateDebut.isBefore(maintenant) &&
        reservation.dateFin.isAfter(maintenant)) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  String _getStatusText(Reservation reservation) {
    final maintenant = DateTime.now();
    if (reservation.dateFin.isBefore(maintenant)) {
      return 'Terminée';
    } else if (reservation.dateDebut.isBefore(maintenant) &&
        reservation.dateFin.isAfter(maintenant)) {
      return 'En cours';
    } else {
      return 'À venir';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations'),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            initialValue: _filtreVue,
            onSelected: (String value) {
              setState(() {
                _filtreVue = value;
              });
              _chargerReservations();
            },
            itemBuilder: (BuildContext context) {
              return ['Toutes', 'Aujourd\'hui', 'Cette semaine', 'Ce mois']
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            icon: const Icon(Icons.filter_list),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export') {
                final path = await _importExportService.exporterReservations();
                if (mounted && path != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exporté vers: $path')),
                  );
                }
              } else if (value == 'import') {
                final result =
                    await _importExportService.importerReservations();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor:
                          result['success'] ? Colors.green : Colors.red,
                    ),
                  );
                  if (result['success']) {
                    _chargerReservations();
                  }
                }
              } else if (value == 'export_tout') {
                final path = await _importExportService.exporterTout();
                if (mounted && path != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export complet vers: $path')),
                  );
                }
              } else if (value == 'import_tout') {
                final result = await _importExportService.importerTout();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor:
                          result['success'] ? Colors.green : Colors.red,
                    ),
                  );
                  if (result['success']) {
                    _chargerReservations();
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
                    Text('Exporter les réservations'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Importer des réservations'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'export_tout',
                child: Row(
                  children: [
                    Icon(Icons.backup, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Exporter tout (livres + réservations)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import_tout',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Importer tout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _reservations.isEmpty
          ? const Center(
              child: Text(
                'Aucune réservation trouvée',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final reservation = _reservations[index];
                final color = _getColorForReservation(reservation);
                final status = _getStatusText(reservation);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Icon(
                        reservation.dateFin.isBefore(DateTime.now())
                            ? Icons.check
                            : Icons.event,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      reservation.titre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${dateFormat.format(reservation.dateDebut)} - ${dateFormat.format(reservation.dateFin)}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        if (reservation.nomReservant != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.person,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                reservation.nomReservant!,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: Text(
                                'Voulez-vous vraiment supprimer la réservation "${reservation.titre}" ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _supprimerReservation(reservation.id!);
                                },
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReservationDetailScreen(reservation: reservation),
                        ),
                      );
                      _chargerReservations();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddReservationScreen()),
          );
          _chargerReservations();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
