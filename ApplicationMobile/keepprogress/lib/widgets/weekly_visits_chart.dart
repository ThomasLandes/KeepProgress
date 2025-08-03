import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyVisitsChart extends StatelessWidget {
  final Map<String, int> weeklyVisits;

  const WeeklyVisitsChart({super.key, required this.weeklyVisits});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre du graphique
          Text(
            'Visites par semaine',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),

          const SizedBox(height: 16),

          // Zone principale du graphique
          Expanded(
            child: Row(
              children: [
                // Libellé de l'axe Y
                RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    'Nombre de visites',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      height: 1,
                    ),
                    textHeightBehavior: TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Graphique principal + libellé axe X
                Expanded(
                  child: Column(
                    children: [
                      // Graphique LineChart
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            // Configuration de la grille
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: _getHorizontalInterval(),
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey[300]!,
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Colors.grey[300]!,
                                  strokeWidth: 1,
                                );
                              },
                            ),

                            // Configuration des titres des axes
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: _getBottomTitles,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: _getHorizontalInterval(),
                                  reservedSize: 42,
                                  getTitlesWidget: _getLeftTitles,
                                ),
                              ),
                            ),

                            // Configuration des bordures
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),

                            // Limites des axes
                            minX: 0,
                            maxX: (weeklyVisits.length - 1).toDouble(),
                            minY: 0,
                            maxY: _getMaxY(),

                            // Configuration de la ligne de données
                            // Configuration de la ligne de données
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getSpots(),
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.7),
                                  ],
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,

                                // Configuration des points sur la ligne
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Theme.of(context).primaryColor,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                ),

                                // Zone colorée sous la ligne
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.3),
                                      Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],

                            // Configuration des tooltips au toucher
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems:
                                    (List<LineBarSpot> touchedBarSpots) {
                                      return touchedBarSpots.map((barSpot) {
                                        final flSpot = barSpot;
                                        final weekIndex = flSpot.x.toInt();
                                        final weekKey = weeklyVisits.keys
                                            .elementAt(weekIndex);

                                        return LineTooltipItem(
                                          '$weekKey\n${flSpot.y.toInt()} visites',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }).toList();
                                    },
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Libellé de l'axe X
                      Text(
                        'Semaines',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Génère les points de données pour le graphique
  List<FlSpot> _getSpots() {
    final spots = <FlSpot>[];
    final values = weeklyVisits.values.toList();

    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i].toDouble()));
    }

    return spots;
  }

  /// Calcule la valeur maximale pour l'axe Y
  double _getMaxY() {
    if (weeklyVisits.isEmpty) return 10;
    final maxValue = weeklyVisits.values.reduce((a, b) => a > b ? a : b);
    return (maxValue + 2).toDouble(); // Ajouter un peu d'espace en haut
  }

  /// Calcule l'intervalle pour la grille horizontale
  double _getHorizontalInterval() {
    final maxY = _getMaxY();
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    return 20;
  }

  /// Widget pour les titres de l'axe X (bottom)
  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    final index = value.toInt();
    if (index >= 0 && index < weeklyVisits.length) {
      final weekKey = weeklyVisits.keys.elementAt(index);
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(weekKey, style: style),
      );
    }

    return const Text('');
  }

  /// Widget pour les titres de l'axe Y (left)
  Widget _getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString(), style: style),
    );
  }
}
