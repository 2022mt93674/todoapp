import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_todo/screens/addtodo.dart';
import 'package:flutter_todo/screens/edittodo.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keyApplicationId = 'LjUL2oOdYmMAwMYcMHruGwK2coH5aS3zmE00YG5k';
  const keyClientKey = 'tXYkmXBQPOnKzHKUTzr8lURdvSinxpQlI7cE9N3q';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(
      refresh: false,
      maintainState: false,
    ),
  ));
}

class Home extends StatefulWidget {
  //var refresh = false;

  Home({super.key, required refresh, required bool maintainState});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoController = TextEditingController();
  final descrptionController = TextEditingController();

  void addToDo() async {
    if (todoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a task and description"),
        duration: Duration(seconds: 2),
      ));

      return;
    }
    await saveTodo(todoController.text, descrptionController.text);
    setState(() {
      todoController.clear();
      descrptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Todo List. Have a Good day !"),
        backgroundColor: Color.fromARGB(255, 60, 102, 218),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigateToAddPage();
          },
          label: Text('Add Task')),
      body: Column(
        children: <Widget>[
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTodo(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator()),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 20.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTodo = snapshot.data![index];
                                final varTitle = varTodo.get<String>('title')!;
                                final varDescrption =
                                    varTodo.get<String>('description')!;
                                final varDone = varTodo.get<bool>('done')!;
                                //*************************************

                                return ListTile(
                                  title: Text(
                                    varTitle,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  horizontalTitleGap: 10,
                                  minLeadingWidth: 10,
                                  subtitle: Text(
                                    varDescrption,
                                    maxLines: 3,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  leading: CircleAvatar(
                                    child: Icon(
                                        varDone ? Icons.check : Icons.error),
                                    backgroundColor: varDone
                                        ? Colors.green
                                        : Color.fromARGB(255, 236, 157, 67),
                                    foregroundColor: Colors.white,
                                  ),
                                  trailing: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                          value: varDone,
                                          onChanged: (value) async {
                                            await updateTodo(
                                                varTodo.objectId!, value!);
                                            setState(() {
                                              //Refresh UI
                                            });
                                          }),
                                      IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Color.fromARGB(
                                                255, 33, 54, 243),
                                          ),
                                          onPressed: () {
                                            navigateToEditPage(varTodo);
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: const Color.fromARGB(
                                              255, 243, 33, 33),
                                        ),
                                        onPressed: () async {
                                          await deleteTodo(varTodo.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text("Task deleted!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }

  Future<void> saveTodo(String title, String description) async {
    final todo = ParseObject('Todo')
      ..set('title', title)
      ..set('done', false)
      ..set('description', description);
    await todo.save();
  }

  Future<List<ParseObject>> getTodo() async {
    QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('Todo'));
    final ParseResponse apiResponse = await queryTodo.query();
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTodo(String id, bool done) async {
    var todo = ParseObject('Todo')
      ..objectId = id
      ..set('done', done);
    await todo.save();
  }

  Future<void> deleteTodo(String id) async {
    var todo = ParseObject('Todo')..objectId = id;
    await todo.delete();
  }

  void navigateToAddPage() {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(),
    );

    Navigator.push(context, route).then((value) => setState(() {}));
  }

  void navigateToEditPage(vartodo1) {
    final route = MaterialPageRoute(
      builder: (context) => EditToDoPage(vartodo: vartodo1),
    );

    Navigator.push(context, route).then((value) => setState(() {}));
  }
}
