import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

class Todo {
  DateTime dateCreate = DateTime.now();
  DateTime dateModify = DateTime.now();
	String details;
	String title;
  String level;
  bool done;

  Todo({
		this.done = false, this.details = '', this.title = '', this.level = 'none'
	});

  update(other) {
		this..title   = other.title
        ..level   = other.level
    	  ..done    = other.done
    	  ..details = other.details
        ..dateModify = DateTime.now();
  }

  @override
  toString() => "todo||$done||$title||$level||$details";
}

//Container
class Notes {
  List<Todo> items = [
		// test items
		Todo(done: false, details: 'string1 \n string2', title:'todo1',
			level: 'high'),
		Todo(done: true, details: 'string1 \n string2', title:'todo2'),
	];
  var _curLevel = '*'; //filter value, * - all
  get count => items.where(_filter).length;
  get item => (int i) => items.where(_filter).toList()[i];
  get levels => items.map((x) => x.level).toSet().toList();
  get filter => _curLevel == "" ? "*" : _curLevel;
  setFilter(lev) {
    _curLevel = lev;
  }

  bool _filter(x) => _curLevel == '*' || _curLevel == x.level;

  load() async {
		//TODO load from file
    final directory = await getApplicationDocumentsDirectory();
    log("load from $directory");
    final file = File(directory.path + "/notes.txt");
    items.clear();
    for (String x in file.readAsLinesSync()) {
      log(x);
      var s = x.split("||");
      switch (s[0]) {
        case "todo":
          items.add(Todo(
            done: s[1] == "true", title: s[2], level: s[3], details: s[4]));
          break;
      }
    }
    log("load end");
  }

  save() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      log("save to $directory");
      final file = File(directory.path + "/notes.txt");
      file.openWrite();
      for (var x in items) {
        file.writeAsStringSync(x.toString() + '\n', mode: FileMode.append);
      }
    } catch (e) {
      log("Error while saving the file: " + e.toString());
    }
  }

  remove(item) {
    items.remove(item);
  }

  add() {
    final one = Todo();
    items.add(one);
    return one;
  }
}

////////////////////// Widgets
class ItemPage extends StatefulWidget {
  final Todo _item;
	final List<String> _levels;
  const ItemPage(this._item, this._levels, {Key? key}) : super(key: key);

  @override
  _ItemPageState createState() => _ItemPageState(_item, _levels);
}

class _ItemPageState extends State<ItemPage> {
  final Todo _item;
  final List<String> _levels;
  final cntTitle = TextEditingController();
  final cntLevel = TextEditingController();
  final cntDetails = TextEditingController();
	
  bool _check = false;

  _ItemPageState(this._item, this._levels) {
    cntTitle.text = _item.title;
    cntLevel.text = _item.level;
    cntDetails.text = _item.details;
    _check = _item.done;
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
      title: const Text("Confirm"),
      content: const Text("Would you like to remove item?"),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
        TextButton(
          child: const Text("Yes"),
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
          IconButton(
              icon: const Icon(Icons.done_outline_rounded),
              onPressed: () {
                Navigator.pop(context, _upd());
              }),
          IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => showDelDialog(context))
        ],
      ),
      body: Center(
        child: Column(
          children: [
						CheckboxListTile(
							value: _check,
							title: const Text("Done"),
							onChanged: (chk) {
								setState(() {
									_check = chk!;
								});
							},
						),
            TextField(
              controller: cntTitle,
              decoration: const InputDecoration(labelText: 'Title'),
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
                decoration: const InputDecoration(labelText: 'Level'),
              ),
            ),
            Expanded(
                child: TextField(
              controller: cntDetails,
              decoration: const InputDecoration(labelText: 'Details'),
              minLines: 5,
              maxLines: 10,
            )),
          ],
        ),
      ),
    );
  }

  _upd() => Todo( done: _check
		            , details: cntDetails.text
							  , title: cntTitle.text
							  , level: cntLevel.text
							  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Simple notes'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.title = ""}) : super(key: key);
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
    if (result != null) {
      setState(() {
        if (result == "del") {
          notes.remove(item);
				} else {
          item.update(result);
				}
      });
		}
  }

  listItem(i, context) {
    final one = notes.item(i);
    if (one is Todo) {
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
		}
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
            const DrawerHeader(
              child: Text('Main menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            const ListTile(title: Text('LEVELS')),
            for (var x in ["*", ...notes.levels])
              ListTile(
                title: Text(x),
                contentPadding: const EdgeInsets.only(left: 50),
                dense: true,
                selected: notes.filter == x,
                onTap: () => setState(() {
                  Navigator.pop(context);
                  notes.setFilter(x);
                }),
              ),
            const Divider(),
            ListTile(
                title: const Text('Save'),
                leading: const Icon(Icons.save_outlined),
                onTap: () {
                  notes.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved.'),
                    ),
                  );
                }),
            ListTile(
                title: const Text('Load'),
                leading: const Icon(Icons.file_upload),
                onTap: () async {
                  await notes.load();
                  setState(() {});
                }),
            const Divider(),
            const ListTile(title: Text('About...')),
          ],
        )),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            FloatingActionButton(
              onPressed: () => showItem(notes.add()),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              heroTag: 'todo',
              tooltip: 'new todo item',
              child: const Text('+todo'),
            )
          ])
        ]));
  }
}

///////////////////////
void main() {
  runApp(const MyApp());
}
