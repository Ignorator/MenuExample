// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../main.dart';
import '../model/model.dart';
import '../page/edit_page.dart';

class NotePage extends StatefulWidget {
  final int? noteId;
  final bool isLocked;

  const NotePage({Key? key, required this.noteId, required this.isLocked}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DbNote?>(
      stream: menuItemProvider.onNote(widget.noteId),
      builder: (context, snapshot) {
        var note = snapshot.data;

        void _edit() {
          if (note != null && !widget.isLocked) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return EditNotePage(
                initialNote: note, selected_lang: note.langName.value!,
              );
            }));
          }
        }

        return Scaffold(
            appBar: AppBar(
              title: Text(
                  note!.title.v!
              ),
              actions: <Widget>[
                if (note != null && !widget.isLocked)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _edit();
                    },
                  ),
              ],
            ),
            body: (note == null)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : GestureDetector(
                    onTap: () {
                      if(!widget.isLocked) {
                        _edit();
                      }
                    },
                    child: ListView(children: <Widget>[
                      SizedBox(
                        height: 12,
                      ),
                      ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 200,
                            minHeight: 200,
                            maxWidth: 440,
                            maxHeight: 440
                          ),
                          child: FadeInImage (
                            placeholder: AssetImage('assets/images/placeholder.png'),
                            image: Utility.imageFromBase64String(note.picture.v!).image,
                            fit: BoxFit.scaleDown
                          )
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      ListTile(title: Text(note.price.v ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                      ListTile(title: Text(note.content.v ?? '',)),
                    ]),
                  ));
      },
    );
  }
}
