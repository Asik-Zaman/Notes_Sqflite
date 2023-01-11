import 'dart:math';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/DBHelper/db_helper.dart';
import 'package:notes_sqflite/Models/notes_model.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late DBHelper dbHelper;
  late Future<List<Note>> _note;
  //int _counter = 1;
  var _titleController = TextEditingController();
  var _descController = TextEditingController();
  var _updateTitleController = TextEditingController();
  var _updateDescController = TextEditingController();
  int? _updateId = 0;
  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    dbHelper.db.whenComplete(() async {
      setState(() {
        _note = getData();
      });
    });
    //getCounter();
  }

  Future<List<Note>> getData() async {
    _note = dbHelper.getNoteList();
    return _note;
  }

  /*  Future getCounter() async {
    var sp = await SharedPreferences.getInstance();
    var counter = sp.getInt('counter');
    _counter = counter ?? 1;
    setState(() {});
  } */

  Future<void> _onRefresh() async {
    setState(() {
      _note = getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
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
            FutureBuilder<List<Note>>(
              future: _note,
              builder: ((context, AsyncSnapshot<List<Note>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final items = snapshot.data ?? <Note>[];
                  return items.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/empty_cart.png'),
                                ),
                                Text(
                                    'Your notes is empty 😌\n To add notes click on the button',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline5),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Scrollbar(
                              child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: ((context, index) {
                                  final title = items[index].title.toString();
                                  final desc = items[index].desc.toString();
                                  int? id = items[index].id;
                                  return Dismissible(
                                    direction: DismissDirection.startToEnd,
                                    background: Container(
                                      color: Colors.pinkAccent,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: const Icon(Icons.delete_forever),
                                    ),
                                    key: ValueKey<int?>(id),
                                    onDismissed: (direction) async {
                                      await dbHelper.deleteItem(id);
                                      setState(() {
                                        items.remove(items[index]);
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      height: 100,
                                      width: 400,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          color: Colors.pink),
                                      child: ListTile(
                                          title: Text(
                                            'Title: ' +
                                                snapshot.data![index].title
                                                    .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          subtitle: Text(
                                            'Description: ' +
                                                snapshot.data![index].desc
                                                    .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          trailing: PopupMenuButton(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: Colors.white,
                                              ),
                                              itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: '1',
                                                      child: ListTile(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          showUpdateDialog(
                                                              id, title, desc);
                                                        },
                                                        leading:
                                                            Icon(Icons.edit),
                                                        title: Text('Edit'),
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: '2',
                                                      child: ListTile(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          showDeleteDialog(id);
                                                        },
                                                        leading:
                                                            Icon(Icons.delete),
                                                        title: Text('Delete'),
                                                      ),
                                                    ),
                                                  ])),
                                    ),
                                  );
                                })),
                          )),
                        );
                }
              }),
            )
          ],
        ),
      ),
    );
  }

  Future<void> showDeleteDialog(int? id) async {
    _updateId = id;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'You are sure to delete this note ?',
            textAlign: TextAlign.center,
          )),
          content: Container(
              height: 80,
              width: 150,
              child: Column(
                children: [],
              )),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel')),
            TextButton(
              onPressed: () {
                dbHelper.deleteItem(_updateId).then((value) {
                  final snackBar = SnackBar(
                      backgroundColor: Colors.pink,
                      duration: Duration(seconds: 2),
                      content: Text('Notes is Deleted...'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.pop(context);
                  _onRefresh();
                }).onError((error, stackTrace) {
                  final snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text('Notes is not Deleted...'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.pop(context);
                  _onRefresh();
                });
              },
              child: Text('Delete'),
            )
          ],
        );
      },
    );
  }

  Future<void> showUpdateDialog(int? id, String desc, String title) async {
    _updateTitleController.text = title;
    _updateDescController.text = desc;
    _updateId = id;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'Update Note Dialog',
            textAlign: TextAlign.center,
          )),
          content: Container(
            height: 250,
            width: 250,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          hintText: 'title', border: OutlineInputBorder()),
                      onChanged: ((value) {
                        setState(() {
                          _updateTitleController.text = value;
                        });
                      }),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          hintText: 'desc', border: OutlineInputBorder()),
                      onChanged: ((value) {
                        setState(() {
                          _updateDescController.text = value;
                        });
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel')),
            TextButton(
              onPressed: () {
                dbHelper
                    .updateQuantity(Note(
                        id: _updateId,
                        title: _updateTitleController.text.toString(),
                        desc: _updateDescController.text.toString()))
                    .then((value) {
                  final snackBar = SnackBar(
                      backgroundColor: Colors.pink,
                      duration: Duration(seconds: 2),
                      content: Text('Notes is Updated...'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.pop(context);
                  _onRefresh();
                }).onError((error, stackTrace) {
                  final snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text('Notes is not Updated...'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.pop(context);
                  setState(() {});
                });
              },
              child: Text('Update'),
            )
          ],
        );
      },
    );
  }

  Future showMyDialog() {
    DBHelper dbHelper = DBHelper();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: Colors.pink,
              content: Center(
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
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
                    //var sp = await SharedPreferences.getInstance();
                    if (_formKey.currentState!.validate()) {
                      await dbHelper
                          .insert(Note(
                              id: Random().nextInt(100),
                              title: _titleController.text.toString(),
                              desc: _descController.text.toString()))
                          .then((value) {
                        final snackBar = SnackBar(
                            backgroundColor: Colors.pink,
                            duration: Duration(seconds: 2),
                            content: Text('Notes is added...'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        _descController.clear();
                        _titleController.clear();
                        Navigator.pop(context);
                        _onRefresh();
                        /*  setState(() {
                          //_counter++;
                          //sp.setInt('counter', _counter);
                          //_onRefresh();
                          //
                        }); */
                      }).onError((error, stackTrace) {
                        final snackBar = SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(error.toString()),
                            duration: Duration(seconds: 10));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        });
  }
}
