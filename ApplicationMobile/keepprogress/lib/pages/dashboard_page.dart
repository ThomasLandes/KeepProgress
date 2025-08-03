import 'package:flutter/material.dart';
import 'package:keepprogress/models/user_model.dart';
import 'package:keepprogress/widgets/weekly_visits_chart.dart';

class DashboardPage extends StatelessWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  // Données d'exemple pour le graphique avec vrais numéros de semaine
  Map<String, int> get _weeklyVisitsData {
    final now = DateTime.now();
    final data = <String, int>{};

    // Générer les 8 dernières semaines avec leurs vrais numéros
    for (int i = 7; i >= 0; i--) {
      final weekDate = now.subtract(Duration(days: i * 7));
      final weekNumber = _getWeekNumber(weekDate);

      // Données d'exemple pour chaque semaine
      final visits = [5, 8, 12, 7, 15, 10, 18, 14][7 - i];
      data['$weekNumber'] = visits;
    }

    return data;
  }

  // Fonction pour calculer le numéro de semaine dans l'année
  int _getWeekNumber(DateTime date) {
    // Trouver le premier lundi de l'année
    final firstOfYear = DateTime(date.year, 1, 1);
    final firstMonday = firstOfYear.add(
      Duration(days: (8 - firstOfYear.weekday) % 7),
    );

    // Calculer la différence en jours et diviser par 7
    final difference = date.difference(firstMonday).inDays;
    return (difference / 7).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue ${user.nom}'),
        automaticallyImplyLeading: false, // Enlever le bouton retour
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête du dashboard
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tableau de bord',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Suivez vos progrès et vos visites',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Graphique des visites par semaine
            WeeklyVisitsChart(weeklyVisits: _weeklyVisitsData),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
