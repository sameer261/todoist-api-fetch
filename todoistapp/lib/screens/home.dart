import 'package:flutter/material.dart';
import 'package:todoistapp/api/apiservices.dart';
import 'package:todoistapp/api/model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ApiServices apiServices = ApiServices();
  List<Api> tasks = [];
  List<Api> filteredTasks = [];
  String selectedFilter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final fetchedTasks = await apiServices.getTasks();
      setState(() {
        tasks = fetchedTasks;
        filteredTasks = tasks; // Initialize filteredTasks
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch tasks')),
      );
    }
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'All') {
        filteredTasks = tasks; // Show all tasks
      } else {
        int priority = _getPriorityValue(filter);
        filteredTasks =
            tasks.where((task) => task.priority == priority).toList();
      }
    });
  }

  int _getPriorityValue(String priority) {
    switch (priority) {
      case 'High':
        return 1;
      case 'Medium':
        return 2;
      case 'Low':
        return 3;
      default:
        return 0;
    }
  }

  void showAddTaskDialog() {
    final contentController = TextEditingController();
    final descriptionController = TextEditingController();
    int priority = 1; // Default priority
    String priorityText = 'Select Priority'; // Default text for priority

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(labelText: 'Content'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  DropdownButton<int>(
                    value: priority,
                    items: [
                      DropdownMenuItem(value: 1, child: Text('High')),
                      DropdownMenuItem(value: 2, child: Text('Medium')),
                      DropdownMenuItem(value: 3, child: Text('Low')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          priority = value;
                          priorityText = _getPriorityString(value);
                        });
                      }
                    },
                    hint: Text(priorityText),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final newTask = Api(
                  content: contentController.text,
                  description: descriptionController.text,
                  priority: priority,
                );

                try {
                  await apiServices.createTask(newTask);
                  await fetchTasks();
                } catch (e) {
                  await fetchTasks();
                }

                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void editTask(String taskId, Api task) {
    final contentController = TextEditingController(text: task.content);
    final descriptionController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final updatedTask = Api(
                  content: contentController.text,
                  description: descriptionController.text,
                  priority: task.priority, // Keep existing priority
                );

                try {
                  await apiServices.updateTask(taskId, updatedTask);
                  await fetchTasks();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update task')),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void deleteTask(String taskId) async {
    try {
      await apiServices.deleteTask(taskId);
      await fetchTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task')),
      );
    }
  }

  String _getPriorityString(int? priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Not set';
    }
  }

  void sortTasks() {
    setState(() {
      tasks.sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));
      filteredTasks
          .sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          PopupMenuButton<String>(
            onSelected: applyFilter,
            itemBuilder: (BuildContext context) {
              return {'All', 'High', 'Medium', 'Low'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: sortTasks,
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(filteredTasks[index].content ?? 'No content'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(filteredTasks[index].description ??
                            'No description'),
                        Text(
                            'Priority: ${_getPriorityString(filteredTasks[index].priority)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => editTask(
                              filteredTasks[index].id!, filteredTasks[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteTask(filteredTasks[index].id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
