
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_app/services/task_service.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: taskService.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskService.tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          taskService.toggleTaskCompletion(task);
                          if (task.isCompleted) {
                            _confettiController.play();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task completed!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          taskService.removeTask(task);
                        },
                      ),
                      onTap: () {
                        taskService.selectTask(task);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'New Task',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          taskService.addTask(controller.text);
                          controller.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}
