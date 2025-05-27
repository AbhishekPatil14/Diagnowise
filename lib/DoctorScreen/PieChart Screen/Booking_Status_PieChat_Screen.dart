import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../PatientScreen/PatientDatabase.dart';

class BookingStatusPieChart extends StatefulWidget {
  final String doctorEmail;
  const BookingStatusPieChart({super.key, required this.doctorEmail});

  @override
  State<BookingStatusPieChart> createState() => _BookingStatusPieChartState();
}

class _BookingStatusPieChartState extends State<BookingStatusPieChart> {
  int pending = 0;
  int accepted = 0;
  int declined = 0;
  bool isLoading = true;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchStatusData();
  }

  Future<void> fetchStatusData() async {
    try {
      final counts = await BookingDatabase.instance.getStatusCounts(widget.doctorEmail);
      if (mounted) {
        setState(() {
          pending = counts['pending'] ?? 0;
          accepted = counts['accepted'] ?? 0;
          declined = counts['declined'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = pending + accepted + declined;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No booking data available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 4.0,
      margin: const EdgeInsets.all(28.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 50,
                      sectionsSpace: 4,
                      startDegreeOffset: 180,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: [
                        PieChartSectionData(
                          color: Colors.orangeAccent,
                          value: pending.toDouble(),
                          title: '${((pending / total) * 100).toStringAsFixed(1)}%',
                          radius: touchedIndex == 0 ? 70 : 60,
                          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.greenAccent,
                          value: accepted.toDouble(),
                          title: '${((accepted / total) * 100).toStringAsFixed(1)}%',
                          radius: touchedIndex == 1 ? 70 : 60,
                          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.redAccent,
                          value: declined.toDouble(),
                          title: '${((declined / total) * 100).toStringAsFixed(1)}%',
                          radius: touchedIndex == 2 ? 70 : 60,
                          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 1200),
                    swapAnimationCurve: Curves.easeInOutCubic,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      Text('$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildIndicator('Pending', Colors.orangeAccent, pending, total),
                  const SizedBox(height: 8),
                  _buildIndicator('Accepted', Colors.greenAccent, accepted, total),
                  const SizedBox(height: 8),
                  _buildIndicator('Declined', Colors.redAccent, declined, total),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String label, Color color, int value, int total) {
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0.0';

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          '$value ($percentage%)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

