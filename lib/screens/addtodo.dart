import 'package:flutter/material.dart';
import 'package:flutter_todo/main.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class AddToDoPage extends StatefulWidget {
  AddToDoPage({super.key});
  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Todo'),
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: 'Enter Task Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'Enter Task Description'),
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 8,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: submitData, child: Text('Submit'))
          ],
        ));
  }

  void submitData() async {
    //get data from the form
    const keyApplicationId = 'LjUL2oOdYmMAwMYcMHruGwK2coH5aS3zmE00YG5k';
    const keyClientKey = 'tXYkmXBQPOnKzHKUTzr8lURdvSinxpQlI7cE9N3q';
    const keyParseServerUrl = 'https://parseapi.back4app.com';

    Parse().initialize(keyApplicationId, keyParseServerUrl,
        clientKey: keyClientKey, debug: true);

    final title = titleController.text;
    final description = descriptionController.text;

    //check for empty task
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a task and description"),
        duration: Duration(seconds: 2),
      ));

      return;
    }
    await saveToDo(title, description);
    {
      setState(() {
        titleController.clear();
        descriptionController.clear();
      });
    }

    //Submit data to parse server

    //Show success or failure message
  }

  saveToDo(String title, String description) {
    final todo = ParseObject('Todo')
      ..set('title', title)
      ..set('done', false)
      ..set('description', description);
    todo.save();

    final route = MaterialPageRoute(
        builder: (context) => Home(refresh: true, maintainState: false));

    Navigator.push(
      context,
      route,
    );
  }
}
