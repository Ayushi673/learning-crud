import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.teal,
      accentColor: Colors.tealAccent,
    ),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var input;
  var updatedinput;
  createTodos(){
    DocumentReference documentReference= Firestore.instance.collection("MyTodos").document(input);
    Map<String,String> todos={
      "todotitle" : input
    };
    documentReference.setData(todos).whenComplete(() => ((){
      print("$input created");
    })).catchError((e)=>print(e));
  }

  //TODO:update an entry and delete it; previously after updation
  // TODO: deletion couldn't be done because updation resulted in discrepancies in the key I'm using
  /*updateTodos(item){
    DocumentReference documentReference= Firestore.instance.collection("MyTodos").document(item);
    Map<String,String> todos={
      "todotitle" : updatedinput
    };
    documentReference.updateData(todos).whenComplete(() => ((){
      print("$updatedinput updated");
    })).catchError((e)=>print(e));
  }*/


  deleteTodos(item){
    DocumentReference documentReference= Firestore.instance.collection("MyTodos").document(item);
    documentReference.delete().whenComplete(() => ((){
      print("deleted");
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDoList'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context,builder: (BuildContext context){
            return AlertDialog(
              title: Text('Add Task'),
              content: TextField(
                onChanged: (value){
                  input=value;
                },
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: (){
                      createTodos();
                      Navigator.of(context).pop();
                    },
                    child: Text('ToDos')),
              ],
            );
          });
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection("MyTodos").snapshots(),
        builder: (context,snapshots){
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshots.data.documents.length,
              itemBuilder: (context,index){
                DocumentSnapshot documentSnapshot= snapshots.data.documents[index];
                return Dismissible(
                  onDismissed: (direction){
                    deleteTodos(documentSnapshot["todotitle"]);
                  },
                  key: Key(documentSnapshot["todotitle"]),
                  child: Container(
                    child: ListTile(
                      title: Text(documentSnapshot["todotitle"]),
                   /*   leading: IconButton(
                        icon: Icon(Icons.create),
                        onPressed: (){
                        showDialog(context: context,builder: (BuildContext context){
                          return AlertDialog(
                            title: Text('Update Task'),
                            content: TextField(
                              onChanged: (value){
                                updatedinput=value;
                              },
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: (){
                                    updateTodos(documentSnapshot["todotitle"]);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Update')),
                            ],
                          );
                        });
                        },
                      ),*/
                      trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: (){
                            setState(() {
                              deleteTodos(documentSnapshot["todotitle"]);
                            });
                          }),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}

