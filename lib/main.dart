import 'package:flutter/material.dart';

void main() => runApp(TimecopApp());

class TimecopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timecop',
      home: TaskListPage(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.lightGreen[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[900],
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.greenAccent,
        ),
      ),
    );
  }
}

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final List<Task> _tasks = [];

  void _addTask(String name, TimeOfDay? reminderTime, DateTime? reminderDate) {
    setState(() {
      // If reminderDate is null, set it to the current date
      reminderDate ??= DateTime.now();

      _tasks.add(Task(
        name: name,
        reminderTime: reminderTime,
        reminderDate: reminderDate,
        reminderEnabled: reminderTime != null,
      ));
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    TimeOfDay? selectedTime;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: Text('Add Task', style: TextStyle(color: Colors.green[900])),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Task name', hintStyle: TextStyle(color: Colors.grey)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
              },
              child: Text('Set Reminder Time'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
              },
              child: Text('Set Reminder Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.green[900])),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _addTask(name, selectedTime, selectedDate);
              }
              Navigator.pop(context);
            },
            child: Text('Add', style: TextStyle(color: Colors.green[900])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timecop', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return TaskTile(
            task: task,
            onDelete: () => _deleteTask(index),
            onToggleReminder: () {
              setState(() {
                task.reminderEnabled = !task.reminderEnabled;
              });
            },
            onEdit: () {
              _showEditTaskDialog(index, task.name, task.reminderTime, task.reminderDate);
            },
            onComplete: () {
              setState(() {
                task.completeTask();
              });
            },
          );
        },
      ),
    );
  }

  void _showEditTaskDialog(int index, String currentName, TimeOfDay? currentTime, DateTime? currentDate) {
    final controller = TextEditingController(text: currentName);
    TimeOfDay? selectedTime = currentTime;
    DateTime? selectedDate = currentDate ?? DateTime.now(); // Use current date if null

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: Text('Edit Task', style: TextStyle(color: Colors.green[900])),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Task name', hintStyle: TextStyle(color: Colors.grey)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                selectedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                );
              },
              child: Text('Set Reminder Time'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                ) ?? selectedDate; // Keep current date if no date is selected
              },
              child: Text('Set Reminder Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.green[900])),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _tasks[index] = Task(
                    name: name,
                    reminderTime: selectedTime,
                    reminderDate: selectedDate,
                    reminderEnabled: selectedTime != null,
                  );
                });
              }
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.green[900])),
          ),
        ],
      ),
    );
  }
}

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggleReminder;
  final VoidCallback onEdit;
  final VoidCallback onComplete;

  TaskTile({
    required this.task,
    required this.onDelete,
    required this.onToggleReminder,
    required this.onEdit,
    required this.onComplete,
  });

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _isRunning = false;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _ticker = Ticker(onTick: _updateTime);
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _stopwatch.start();
      _ticker.start();
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _stopwatch.stop();
      _ticker.stop();
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        widget.task.elapsedTime = _stopwatch.elapsed;
      });
    }
  }

  String _formatElapsedTime() {
    final elapsed = widget.task.elapsedTime;
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.green[50],
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          widget.task.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[900]),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.task.isCompleted)
              Text(
                _formatElapsedTime(),
                style: TextStyle(fontSize: 14, color: Colors.green[600]),
              ),
            if (widget.task.reminderTime != null)
              Text(
                'Reminder: ${widget.task.reminderDate?.toLocal().toString().split(' ')[0]} at ${widget.task.reminderTime!.format(context)}',
                style: TextStyle(fontSize: 14, color: Colors.green[600]),
              ),
            if (widget.task.isCompleted)
              Text(
                'Completed in: ${_formatElapsedTime()}',
                style: TextStyle(fontSize: 14, color: Colors.green[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.greenAccent),
              onPressed: _isRunning ? _stopTimer : _startTimer,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDelete,
            ),
            IconButton(
              icon: Icon(
                widget.task.reminderEnabled ? Icons.notifications_active : Icons.notifications_none,
                color: widget.task.reminderEnabled ? Colors.green[900] : Colors.grey,
              ),
              onPressed: widget.onToggleReminder,
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: widget.onEdit,
            ),
            if (!widget.task.isCompleted)
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: widget.onComplete,
              ),
          ],
        ),
      ),
    );
  }
}

class Task {
  final String name;
  final TimeOfDay? reminderTime;
  final DateTime? reminderDate;
  bool reminderEnabled;
  bool isCompleted = false;
  Duration elapsedTime = Duration.zero;

  Task({
    required this.name,
    this.reminderTime,
    this.reminderDate,
    this.reminderEnabled = false,
  });

  void completeTask() {
    isCompleted = true;
  }
}

class Ticker {
  final Function() onTick;
  late final Duration _interval;
  late final VoidCallback _callback;

  Ticker({required this.onTick, Duration interval = const Duration(seconds: 1)})
      : _interval = interval;

  void start() {
    _callback = () async {
      while (true) {
        await Future.delayed(_interval);
        onTick();
      }
    };
    _callback();
  }

  void stop() {
    _callback = () {};
  }

  void dispose() {
    stop();
  }
}
