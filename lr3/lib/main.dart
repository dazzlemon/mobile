import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

///////// Data classes
class Note {
  String title;
  String level;
  DateTime dateCreate = DateTime.now();
  DateTime dateModify = DateTime.now();
  Note({this.title = '', this.level = 'none'});
  update(other) {
    this
      ..title = other.title
      ..level = other.level
      ..dateModify = DateTime.now();
  }
}

class Memo extends Note {
  String details = "";
  Memo({this.details = '', title = '', level = 'none'})
      : super(title: title, level: level);
  @override
  update(other) {
    super.update(other);
    this.details = other.details;
  }

  @override
  toString() => "memo||$title||$level||$details";
}

mixin Check {
  bool done = false;
}

class Todo extends Memo with Check {
  Todo({isDone = false, details = '', title = '', level = 'none'})
      : super(title: title, level: level) {
    done = isDone;
  }
  @override
  update(other) {
    super.update(other);
    this.done = other.done;
  }

  @override
  toString() => "todo||$done||$title||$level||$details";
}

//TODO class Event extend Todo with Date
//Container
class Notes {
  List<Note> items = [];
  var _curLevel = '*'; //filter value, * - all
  Notes() {
//test items
// items.add(Memo(details:'string1 \n string2', title:'memo 1'));
// items.add(Memo(details:'string1 \n string2', title:'memo 2'));
// items.add(Memo(details:'string1 \n string2', title:'memo3',level:'high'));
// items.add(Todo(isDone:false, details:'string1 \n string2', title:'todo1',level:'high'));
// items.add(Todo(isDone:true, details:'string1 \n string2',title:'todo2'));
// items.add(Memo(details:'string1 \n string2', title:'memo4',level:'high'));
  }
  get count => items.where(_filter).length;
  get item => (int i) => items.where(_filter).toList()[i];
  get levels => items.map((x) => x.level).toSet().toList();
  get filter => _curLevel == "" ? "*" : _curLevel;
  setFilter(lev) {
    _curLevel = lev;
  }

  bool _filter(x) {
    if (_curLevel == '*')
      return true;
    else
      return _curLevel == x.level;
  }

  load() async {
//TODO load from file
    final directory = await getApplicationDocumentsDirectory();
    print("load from $directory");
    final file = File(directory.path + "/notes.txt");
    items.clear();
    for (String x in file.readAsLinesSync()) {
      print(x);
      var s = x.split("||");
      switch (s[0]) {
        case "todo":
          items.add(Todo(
              isDone: s[1] == "true", title: s[2], level: s[3], details: s[4]));
          break;
        case "memo":
          items.add(Memo(title: s[1], level: s[2], details: s[3]));
      }
    }
    print("load end");
  }

  save() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      print("save to $directory");
      final file = File(directory.path + "/notes.txt");
      file.openWrite();
      for (var x in items) {
        file.writeAsStringSync(x.toString() + '\n', mode: FileMode.append);
      }
    } catch (e) {
      print("Error while saving the file: " + e.toString());
    }
  }

  remove(item) {
    items.remove(item);
  }

  add<T extends Note>() {
    final factories = <Type, Function>{Memo: () => Memo(), Todo: () => Todo()};
    final one = (factories[T]!)();
    items.add(one);
    return one;
  }
}

////////////////////// Widgets
class ItemPage extends StatefulWidget {
  final _item, _levels;
  const ItemPage(this._item, this._levels);
  @override
  _ItemPageState createState() => _ItemPageState(_item, _levels);
}

class _ItemPageState extends State<ItemPage> {
  final Memo _item;
  var _levels;
  bool _check = false;
  final cntTitle = TextEditingController();
  final cntLevel = TextEditingController();
  final cntDetails = TextEditingController();
  _ItemPageState(this._item, this._levels) {
    cntTitle.text = _item.title;
    cntLevel.text = _item.level;
    cntDetails.text = _item.details;
    if (_item is Todo) _check = (_item as Todo).done;
  }
  @override
  void dispose() {
// Clean up the controller when the Widget is disposed
    cntTitle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  showDelDialog(context) {
// set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm"),
      content: Text("Would you like to remove item?"),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
        TextButton(
          child: Text("Yes"),
          onPressed: () {
            Navigator.pop(
              context,
            );
            Navigator.pop(context, "del");
          },
        )
      ],
    );
// show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_item.runtimeType}'),
        actions: [
          new IconButton(
              icon: new Icon(Icons.done_outline_rounded),
              onPressed: () {
                Navigator.pop(context, _upd());
              }),
          new IconButton(
              icon: new Icon(Icons.cancel),
              onPressed: () => showDelDialog(context))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            if (_item is Todo)
              CheckboxListTile(
                value: _check,
                title: Text("Done"),
                onChanged: (chk) {
                  setState(() {
                    _check = chk!;
                  });
                },
              ),
            TextField(
              controller: cntTitle,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            ListTile(
              trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (String newValue) {
                    setState(() {
                      cntLevel.text = newValue;
                    });
                  },
                  itemBuilder: (context) => [
                        for (String x in _levels)
                          PopupMenuItem(
                            value: x,
                            child: Text(x),
                          )
                      ]),
              title: TextField(
                controller: cntLevel,
                decoration: InputDecoration(labelText: 'Level'),
              ),
            ),
            Expanded(
                child: TextField(
              controller: cntDetails,
              decoration: InputDecoration(labelText: 'Details'),
              minLines: 5,
              maxLines: 10,
            )),
          ],
        ),
      ),
    );
  }

  _upd() {
    if (_item is Todo)
      return Todo(
          isDone: _check,
          details: cntDetails.text,
          title: cntTitle.text,
          level: cntLevel.text);
    if (_item is Memo)
      return Memo(
          details: cntDetails.text, title: cntTitle.text, level: cntLevel.text);
  }
}

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Simple notes'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title = ""}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var notes = Notes();
  showItem(item) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ItemPage(item, notes.levels),
        ));
    if (result != null)
      setState(() {
        if (result == "del")
          notes.remove(item);
        else
          item.update(result);
      });
  }

  listItem(i, context) {
    final one = notes.item(i);
    if (one is Todo)
      return ListTile(
        leading: Icon(
          Icons.done,
          color: one.done ? Colors.lightGreen : Colors.white,
        ),
        title: Text(one.title),
        subtitle: Text(one.level),
        trailing: Text(one.dateCreate.toString().substring(0, 10)),
        dense: true,
        onTap: () => showItem(one),
      );
    if (one is Memo)
      return ListTile(
        title: Text(one.title),
        subtitle: Text(one.level),
        trailing: Text(one.dateCreate.toString().substring(0, 10)),
        dense: true,
        onTap: () => showItem(one),
      );
  }

  _HomePageState();
  @override
  void initState() {
    super.initState();
    (notes.load()).whenComplete(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: notes.count,
          itemBuilder: (context, i) => listItem(i, context),
        ),
        drawer: Drawer(
            child: ListView(
//itemExtent: 40.0,
          children: [
            DrawerHeader(
              child: Text('Main menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(title: Text('LEVELS')),
            for (var x in ["*", ...notes.levels])
              ListTile(
                title: Text(x),
                contentPadding: EdgeInsets.only(left: 50),
                dense: true,
                selected: notes.filter == x,
                onTap: () => setState(() {
                  Navigator.pop(context);
                  notes.setFilter(x);
                }),
              ),
            Divider(),
            ListTile(
                title: Text('Save'),
                leading: Icon(Icons.save_outlined),
                onTap: () {
                  notes.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Saved.'),
                    ),
                  );
                  ;
                }),
            ListTile(
                title: Text('Load'),
                leading: Icon(Icons.file_upload),
                onTap: () async {
                  await notes.load();
                  setState(() {});
                }),
            Divider(),
            ListTile(title: Text('About...')),
          ],
        )),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            FloatingActionButton(
              onPressed: () => showItem(notes.add<Memo>()),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              heroTag: 'memo',
              tooltip: 'new memo item',
              child: Text('+memo'),
            ),
            FloatingActionButton(
              onPressed: () => showItem(notes.add<Todo>()),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              heroTag: 'todo',
              tooltip: 'new todo item',
              child: Text('+todo'),
            )
          ])
        ]));
  }
}

///////////////////////
void main() {
  runApp(MyApp());
}
