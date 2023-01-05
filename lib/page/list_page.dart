import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import '../main.dart';
import '../model/model.dart';
import '../page/edit_page.dart';
import '../page/menu_page.dart';
import 'package:group_list_view/group_list_view.dart';
import '../page/listview_elements.dart';

import 'package:file_picker/file_picker.dart';

import 'dart:io';

GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

class NoteListPage extends StatefulWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  _NoteListPageState createState() => _NoteListPageState();
}


class _NoteListPageState extends State<NoteListPage>{

  TextEditingController passwordController = TextEditingController();


  var languageName = 'Italiana';
  var languageIndex = 0;

  bool isLocked = true;

  void _selectLanguage(String langName, int langIndex)
  {
    setState((){
      languageName = langName;
      languageIndex = langIndex;
    });
  }

  void _setLock(bool set)
  {
    setState((){
      isLocked = set;
    });
  }

 int _getItemCountInSection (int sectionIndex, var snapshot, int snapshotLength){
   int count = 0;
   var notequery = snapshot.data;
    for(var i = 0; i < snapshotLength; i++){
      var note = notequery[i];
      if(note.type.v == listview_Groups[sectionIndex][0] && note.langName.v == languageName) {
        count++;
      }
    }
    return count;
  }

 List<int> _getItemIndicesInSections (int sectionIndex, var snapshot, int snapshotLength){
   List<int> retVal = new List<int>.empty(growable: true);
   var notequery = snapshot.data;
   for(var i = 0; i < snapshotLength; i++){
     var note = notequery[i];
     if(note.type.v == listview_Groups[sectionIndex][0] && note.langName.v == languageName) {
       retVal.add(i);
     }
   }
   return retVal;
 }
 List<int> iterableList = List<int>.empty();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      appBar: AppBar(title: Text('Hotel Miramare', style: TextStyle(color: Colors.white)), centerTitle: true, backgroundColor: Colors.brown,
        leading: IconButton(
            icon: Icon(Icons.menu, color:Colors.white),
            onPressed: () => _drawerKey.currentState!.openDrawer()
        ),
        actions: [
          Visibility(
              visible:!isLocked,
              child:IconButton(
                icon: Icon(Icons.call_made, color: Colors.white),
                onPressed: () async {
                  final dbFolder = await getDatabasesPath();
                  var source = File('$dbFolder/note.db');
                  var selectedDirectory = await FilePicker.platform.getDirectoryPath();

                  if (selectedDirectory == null) {
                    // User canceled the picker
                  }
                  else {
                    var newPath = '$selectedDirectory/dish_database.db';
                    await source.copy(newPath);
                    setState(() {});
                  }
                },
              )),
          Visibility(
              visible:!isLocked,
              child:IconButton(
                icon: Icon(Icons.call_received, color: Colors.white),
                onPressed: () async {
                  final dbFolder = await getDatabasesPath();
                  var dbPath = '$dbFolder/note.db';
                  var fileToDelete = File('$dbFolder/note.db');
                  var result =
                  await FilePicker.platform.pickFiles();
                  if (result != null) {
                    var source = File(result.files.single.path!);
                    await fileToDelete.delete();
                    await source.copy(dbPath);
                  } else {
                    // User canceled the picker
                  }
                  setState(() {});
                },
              )),
          IconButton(
          onPressed: () {
            if (isLocked) {
              (showDialog<bool>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Inserire la password'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          onChanged: (value) {

                          },
                        ),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  passwordController.clear();
                                  Navigator.pop(context, false);
                                },
                                child: Text('ANNULLA'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if(passwordController.text == '') {
                                    _setLock(false);
                                  }
                                  passwordController.clear();
                                  Navigator.pop(context, false);
                                },
                                child: Text('OK'),
                              ),
                            ])
                      ],
                    );
                  }) as FutureOr<bool>?) ??
                  false;
            }
            else {
              _setLock(true);
            }},
          icon: Icon(isLocked ? Icons.lock : Icons.lock_open, color: Colors.white)
      ),

    ],
      ),
      body: StreamBuilder<List<DbNote?>>(
        stream: menuItemProvider.onNotes(),
        builder: (context, snapshot) {
          var notes = snapshot.data;
          if (notes == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return GroupListView (
              sectionsCount: listview_Groups.length,
              countOfItemInSection: (int section) {
                return _getItemCountInSection(section, snapshot, notes.length);
              },
              itemBuilder: (context, index) {
                iterableList = _getItemIndicesInSections(index.section, snapshot, notes.length);
                var note = notes[(iterableList[index.index])]!;
                ImageProvider image = AssetImage('assets/images/placeholder.png');
                if(note.picture.v != null){
                   image = Utility.imageFromBase64String(note.picture.v!).image;
                  }
                Padding(padding: EdgeInsets.all(2.0));
                return GestureDetector(
                    onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return NotePage(
                            noteId: note.id.v, isLocked: isLocked,
                          );
                        }));
                      },
                child: Container(
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                boxShadow: const [
                BoxShadow(
                color: Colors.black12,
                spreadRadius: 2.0,
                blurRadius: 5.0
                ),
                ]
                ),
                margin: EdgeInsets.all(5.0),
                    child: Row (
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),bottomLeft: Radius.circular(10.0)),
                          child: FadeInImage (
                              width: 80,height: 80,fit: BoxFit.cover,
                              placeholder: AssetImage('assets/images/placeholder.png'),
                              image: image,
                        )
                  ),
                      SizedBox(
                        width: 250,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(note.title.v!),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0,bottom: 2.0),
                                child: Text(note.content.v ?? '',style: TextStyle(fontSize: 12.0,color: Colors.black54,),maxLines: 2,),
                              ),
                              Text(note.price.v ?? '',style: TextStyle(fontSize: 12.0,color: Colors.black54),)
                            ],
                          ),
                        ),
                      )
                    ]
                )));
              },
              groupHeaderBuilder: (context, section){
                return Container (
                    decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Text (
                      listview_Groups[section][languageIndex],
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                  )
                );
          },
              );
        },
      ),
      drawer: Drawer(
        child: ListView (
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Text('Seleziona la lingua', style: TextStyle(fontSize: 26)),
            ),
            ListView.builder(
              itemCount: language_Names.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemExtent: 50,
              itemBuilder: (BuildContext context, int index) {
                return ListTile (
                  title: Text(language_Names[index], style: TextStyle(fontSize: 16),),
                  onTap: () {
                    _selectLanguage(language_Names[index], index);
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: !isLocked,
        child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return EditNotePage(
              initialNote: null, selected_lang: languageName,
            );
          }));
        },
        child: Icon(Icons.add),
        ),
      ),
    );
  }
}
