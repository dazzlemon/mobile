
// @dart=2.9

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeSettings with ChangeNotifier{
  bool _dark=false;
  get mode=>_dark?ThemeMode.dark:ThemeMode.light;
  get isDark => _dark;

  swap(){
    _dark=!_dark;
    notifyListeners();
  }
  light()=> // ThemeData.light();
    ThemeData(
			// Define the default brightness and colors.
			brightness: Brightness.light,
			primaryColor: Colors.lightBlue[800],
			colorScheme: ColorScheme.fromSwatch().copyWith(
				secondary: Colors.cyan[600]
			)
		);

  dark(){
    return ThemeData.dark();
  }
}

ThemeSettings curTheme=ThemeSettings(); //global

void main()=>runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    curTheme.addListener(() {setState(() {
      //update all
    });});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lr4',
      debugShowCheckedModeBanner: false,
      themeMode: curTheme.mode,
      theme: curTheme.light(),
      darkTheme: curTheme.dark(),
      home: MyHomePage(title: 'Forum app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _folderList=[];
  var _currentFolder="";
  var _currentUser='noName';

  @override
  _MyHomePageState(){
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp().whenComplete(() {
      print("connected...");
      _getFolderList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_currentFolder),
          actions: [IconButton(icon:Icon(Icons.refresh), onPressed:_getFolderList)],
        ),
        body: Center(child:_folderItems(),),
        drawer: Drawer(
            child:ListView(
                children: [
                  DrawerHeader(child: Text(_currentUser), decoration: BoxDecoration(color: Colors.blue,),),
                  ListTile( title: Text('Folders:'), selected: true,
                    trailing:IconButton(icon:Icon(Icons.add), onPressed: _newFolder) ,),
                  for(var x in _folderList) ListTile(title:Text(x),
                    onTap:()=>  setState(() {
                      Navigator.pop(context);
                      _currentFolder=x;
                    }),
                  ),
                  ListTile( title: Text('Options:'), selected: true),
                  ListTile( title: Text('Dark theme:'),trailing: Switch(value: curTheme.isDark, onChanged:(x)=>curTheme.swap())),
                ])
        )
      ,floatingActionButton: FloatingActionButton(
          onPressed: _displayDialog,
          tooltip: 'new message',
          child: Icon(Icons.add),
      ),
    );

  }

  _folderItems() {
    if (_currentFolder == "") return Text('Select folder');

    //TODO відсортувати повідомлення за датою
    CollectionReference msgs = FirebaseFirestore.instance.collection('folders').doc(_currentFolder).collection('items');

    return StreamBuilder(
      stream: msgs.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Something went wrong');
        if (snapshot.connectionState == ConnectionState.waiting) return Text("Loading");

        print('items $_currentFolder');
        return ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            print('${document.id} ${document.data()['date'].toString()}');
            return ListTile(
              title: Text(document.data()['text']),
              subtitle: Text(document.data()['user']),
              trailing: Text(document.data()['date'].toDate().toString() ?? '',textScaleFactor: 0.5, ),
            );
          }).toList(),
        );
      },
    );
  }

  _getFolderList() async {
      var res=[];

      print('folders:');
      CollectionReference folders = FirebaseFirestore.instance.collection('folders');
      var querySnapshot= await folders.get();
      querySnapshot.docs.forEach((doc) {
            print(doc.id);
            res+=[doc.id];
          });

      setState(() {
        _folderList=res;
      });
  }

  _displayDialog() async {
    final  _textFieldController=TextEditingController();
    var valueText='';
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {},
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.4),
        barrierLabel: '',
        transitionBuilder: (context, anim1, anim2, child) {
          return Transform.rotate(
            angle: anim1.value*360 * (3.1416/180.0),
            child: Opacity(opacity: anim1.value,
              child: AlertDialog(
                  title: Text('New message'),
                  content: TextField(onChanged: (value) {setState(() {valueText = value;});},
                    controller: _textFieldController,
                    minLines: null, maxLines: null, expands: true,
                    decoration: InputDecoration(hintText: "Text"),
                  ),
                  actions: [TextButton(child: Text('Send'),
                      onPressed: () =>
                        setState(() {
                          _newMess(valueText);
                          Navigator.pop(context);
                        }),
                    ),],),),);
        },
        transitionDuration: Duration(milliseconds: 500));
  }

  //без анімації
  // _displayDialog() async {
  //   final  _textFieldController=TextEditingController();
  //   var valueText='';
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text('New message'),
  //           content: TextField(onChanged: (value) {setState(() {valueText = value;});},
  //             controller: _textFieldController,
  //             decoration: InputDecoration(hintText: "Text"),
  //           ),
  //           actions: [TextButton(child: Text('Send'),
  //               onPressed: () {
  //                 setState(() {
  //                   _newMess(valueText);
  //                   Navigator.pop(context);
  //                 });},),],);});
  // }


  _newMess(text) async{
    CollectionReference fld = FirebaseFirestore.instance.collection('folders').doc(_currentFolder).collection('items');

    //TODO вводити ім'я користувача(_currentUser)
    await fld.add({
        'user': _currentUser,
        'text': text,
        'date': DateTime.now()
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('message sent'),),);

      setState(() {
        //update
      });
    }

  _newFolder() async{
    CollectionReference fld = FirebaseFirestore.instance.collection('folders');
    //TODO вводити назву нової папки
    await fld.doc('New folder').set(
        { 'creator': _currentUser,
          'date': DateTime.now()
        });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('new folder'),),);

    _getFolderList();
  }

}

