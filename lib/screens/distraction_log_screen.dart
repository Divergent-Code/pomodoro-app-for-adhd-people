
import 'package:flutter/material.dart';
import 'package:pomodoro_app/services/distraction_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DistractionLogScreen extends StatelessWidget {
  const DistractionLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final distractionService = Provider.of<DistractionService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distraction Log'),
      ),
      body: ListView.builder(
        itemCount: distractionService.distractions.length,
        itemBuilder: (context, index) {
          final distraction = distractionService.distractions[index];
          return ListTile(
            title: Text(distraction.description),
            subtitle: Text(DateFormat.yMd().add_jm().format(distraction.timestamp)),
          );
        },
      ),
    );
  }
}
