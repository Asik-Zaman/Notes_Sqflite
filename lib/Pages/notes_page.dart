import 'package:flutter/material.dart';
import 'package:notes_sqflite/DBHelper/db_helper.dart';
import 'package:notes_sqflite/Models/notes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  DBHelper? dbHelper = DBHelper();
  late Future<List<Note>> _note;
  int _counter = 1;
  var _titleController = TextEditingController();
  var _descController = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  Future<List<Note>> getData() async {
    _note = dbHelper!.getNoteList();
    return _note;
  }

  @override
  void initState() {
    super.initState();
    getData();
    getCounter();
  }

  getCounter() async {
    var sp = await SharedPreferences.getInstance();
    var counter = sp.getInt('counter');
    _counter = counter ?? 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          showMyDialog();
        },
        child: Center(
          child: Icon(Icons.add),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          children: [
            FutureBuilder(
                future: getData(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: ((context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              height: 100,
                              width: 400,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: Colors.pink),
                              child: ListTile(
                                title: Text(
                                  'Title: ' +
                                      snapshot.data![index].title.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                subtitle: Text(
                                  'Description: ' +
                                      snapshot.data![index].desc.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                            );
                          })),
                    );
                  } else {
                    return Center(
                      child: Text('No Data'),
                    );
                  }
                }))
          ],
        ),
      ),
    );
  }

  Future showMyDialog() {
    DBHelper? dbHelper = DBHelper();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: Colors.pink,
              content: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            style: TextStyle(color: Colors.grey),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                hintText: 'Title',
                                hintStyle: TextStyle(color: Colors.black)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter title first';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            maxLines: 4,
                            controller: _descController,
                            style: TextStyle(color: Colors.grey),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                hintText: 'Description',
                                hintStyle: TextStyle(color: Colors.black)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter description first';
                              }
                              return null;
                            },
                          ),
                        ],
                      )),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    var sp = await SharedPreferences.getInstance();
                    dbHelper
                        .insert(Note(
                            id: _counter,
                            title: _titleController.text.toString(),
                            desc: _descController.text.toString()))
                        .then((value) {
                      final snackBar = SnackBar(
                          backgroundColor: Colors.pink,
                          duration: Duration(seconds: 2),
                          content: Text('Notes is added...'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                        _descController.clear();
                        _titleController.clear();
                        _counter++;
                        sp.setInt('counter', _counter);
                        Navigator.pop(context);
                      });
                    }).onError((error, stackTrace) {
                      final snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(error.toString()),
                          duration: Duration(seconds: 10));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        });
  }
}
