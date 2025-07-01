import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/prediction_model.dart';

class HistoryScreen extends StatefulWidget {
  final bool isNepali;
  const HistoryScreen({super.key, this.isNepali = true});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late bool isNepali;

  @override
  void initState() {
    super.initState();
    isNepali = widget.isNepali;
  }

  String formatHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) {
      return isNepali ? 'आज' : 'Today';
    } else if (d == today.subtract(const Duration(days: 1))) {
      return isNepali ? 'हिजो' : 'Yesterday';
    } else {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  void _clearHistory() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('predictions');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final title = isNepali ? 'इतिहास' : 'History';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF0f2027),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => setState(() => isNepali = !isNepali),
            tooltip: isNepali ? 'English' : 'नेपाली',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(isNepali ? 'इतिहास खाली गर्नुहोस्?' : 'Clear history?'),
                  content: Text(
                    isNepali
                        ? 'सबै रेकर्ड मेटाइनेछ।'
                        : 'This will delete all predictions.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(isNepali ? 'रद्द गर्नुहोस्' : 'Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearHistory();
                      },
                      child: Text(isNepali ? 'हो' : 'Yes'),
                    ),
                  ],
                ),
              );
            },
            tooltip: isNepali ? 'इतिहास मेटाउनुहोस्' : 'Clear History',
          ),
        ],
      ),
      body: FutureBuilder<List<PredictionModel>>(
        future: DatabaseHelper.instance.getPredictions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final predictions = snapshot.data!;
          if (predictions.isEmpty) {
            return Center(
              child: Text(isNepali ? 'कुनै रेकर्ड छैन।' : 'No history yet.'),
            );
          }

          // Group by date
          Map<String, List<PredictionModel>> grouped = {};
          for (var p in predictions) {
            String key = formatHeader(DateTime.parse(p.timestamp));
            grouped.putIfAbsent(key, () => []).add(p);
          }

          return ListView(
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  ...entry.value.map((p) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: File(p.imagePath).existsSync()
                            ? Image.file(File(p.imagePath), width: 60, height: 60, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported, size: 40),
                        title: Text(
                          '${isNepali ? "नतिजा" : "Result"}: ${p.result}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${isNepali ? "समय" : "Time"}: ${DateFormat('hh:mm a').format(DateTime.parse(p.timestamp))}',
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
