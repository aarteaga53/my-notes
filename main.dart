
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/take_picture_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'My Notes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int noteCounter = 1;
  var noteList = [];

  

  void incrementNoteCounter() {
    setState(() {
      noteCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: ListView.builder(
        itemCount: noteList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotePage(noteList[index]['title'])),
              );
            },
            onLongPress: () {

            },
            title: Container(
              height: 100,
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 75,
                    height: 100,
                    child: Image(
                      image: FileImage(File(noteList[index]['image'])),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(noteList[index]['title']),
                    ]
                  ),
                ],
              ),
            ),
          );
        },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

           final cameras = await availableCameras();
           final firstCamera = cameras.first;

           final result = await Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera))
           );
           final picturePath = File(result);

           var filename = 'note' + noteCounter.toString() + '.jpeg';
           final directory = await getApplicationDocumentsDirectory();
           final path = directory.path;

           final file = File('$path/' + filename);
           file.writeAsBytesSync(picturePath.readAsBytesSync());

           var note = {
             'image' : '$path/note' + noteCounter.toString() + '.jpeg',
             'title' : 'Note' + noteCounter.toString(),
           };
           noteList.add(note);
           incrementNoteCounter();
         },
         child: const Icon(Icons.photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
