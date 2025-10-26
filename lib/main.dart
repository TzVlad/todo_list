import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: TodoApp()));

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List todos = [];
  final controller = TextEditingController();
  final url = 'http://localhost:5000/todos';

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  fetchTodos() async {
    final res = await http.get(Uri.parse(url));
    setState(() => todos = json.decode(res.body));
  }

  addTodo() async {
    await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': controller.text}));
    controller.clear();
    fetchTodos();
  }

  toggleTodo(int id, bool done) async {
    await http.put(Uri.parse('$url/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'completed': !done}));
    fetchTodos();
  }

  deleteTodo(int id) async {
    await http.delete(Uri.parse('$url/$id'));
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My Tasks'),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 600,
          child: Column(
            children: [
              Container(
                color: Colors.grey[850],
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add task...',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: addTodo,
                      child: Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[900],
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, i) {
                      final todo = todos[i];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: todo['completed'],
                            onChanged: (_) => toggleTodo(todo['id'], todo['completed']),
                            checkColor: Colors.black,
                            fillColor: MaterialStateProperty.all(Colors.grey[400]),
                          ),
                          title: Text(
                            todo['title'],
                            style: TextStyle(
                              decoration: todo['completed'] ? TextDecoration.lineThrough : null,
                              color: todo['completed'] ? Colors.grey[600] : Colors.white,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.close, color: Colors.grey[500]),
                            onPressed: () => deleteTodo(todo['id']),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}