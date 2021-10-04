import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
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
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
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

  int noteCounter = 0;
  List noteList = [];

  @override
  void initState() {
    super.initState();
    loadNoteCounter();
    loadNoteList();
    setState(() {

    });
  }

  void loadNoteCounter() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('noteCounter');
    noteCounter = prefs.getInt('noteCounter') ?? 0;
  }

  void loadNoteList() async {
    String filepath = await getFilepath();
    if(File('$filepath/noteList.txt').existsSync()) {
      final file = File('$filepath/noteList.txt');

      List<String> lines = file.readAsLinesSync();

      for(int i = 1; i < lines.length - 2; i++) {
        var note = {
          'imagePath' : lines[i],
          'pdfPath' : lines[++i],
          'title' : lines[++i],
        };
        noteList.add(note);
      }
    }
  }

  void incrementNoteCounter() async {
    final prefs = await SharedPreferences.getInstance();
    noteCounter++;
    prefs.setInt('noteCounter', noteCounter);
    setState(() {

    });
  }

  Future<String> getFilepath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void createNote(String filepath, String filename) {
    var note = {
      'imagePath' : filepath + '/note_image' + noteCounter.toString() + '.jpeg',
      'pdfPath' : filename,
      'title' : 'Note' + noteCounter.toString(),
    };
    noteList.add(note);
    saveNoteList();
  }

  void saveNoteList() async {
    sortNoteList();
    String filepath = await getFilepath();
    final file = File('$filepath/noteList.txt');
    file.writeAsStringSync('Note List\n');
    for (var element in noteList) {
      file.writeAsStringSync(element['imagePath'] + '\n', mode: FileMode.append);
      file.writeAsStringSync(element['pdfPath'] + '\n', mode: FileMode.append);
      file.writeAsStringSync(element['title'] + '\n', mode: FileMode.append);
    }
    setState(() {

    });
    //file.delete();
  }

  void createPDF(File picture) async {
    PdfDocument document = PdfDocument();
    Uint8List imageData = picture.readAsBytesSync();
    PdfBitmap image = PdfBitmap(imageData);
    document.pageSettings.setMargins(0);
    PdfPage page = document.pages.add();
    page.graphics.drawImage(
        image,
        Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height)
    );
    page = document.pages.add();

    savePDF(document, picture);
  }

  void savePDF(PdfDocument document, File picture) async {
    String filepath = await getFilepath();
    String filename = filepath + '/note' + noteCounter.toString() + '.pdf';
    final file = File(filename);
    file.writeAsBytes(document.save());
    document.dispose();

    createImage(filepath, picture);
    createNote(filepath, filename);
  }

  void createImage(String filepath, File picture) {
    final file = File(filepath + '/note_image' + noteCounter.toString() + '.jpeg');
    file.writeAsBytes(picture.readAsBytesSync());
  }

  void deleteNote(String pdfPath, String imagePath) {
    var file = File(pdfPath);
    file.delete();
    file = File(imagePath);
    file.delete();
  }

  void sortNoteList() {
    var tempList = noteList;
    for(int i = 0; i < tempList.length-1; i++) {
      for(int j = i+1; j < tempList.length; j++) {
        if(tempList[i]['title'].toLowerCase().compareTo(tempList[j]['title'].toLowerCase()) >= 0) {
          var tempNote = tempList[i];
          tempList[i] = tempList[j];
          tempList[j] = tempNote;
        }
      }
    }
    noteList = tempList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
        ),
        itemCount: noteList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotePage(noteList[index])),
                  );
                  noteList[index]['title'] = result;
                  saveNoteList();
                },
                onLongPress: () {
                  showDialog(context: context, builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(noteList[index]['title']),
                      actionsAlignment: MainAxisAlignment.center,
                      content: Text(
                        'Are you sure you want to delete ' + noteList[index]['title'] + '.',
                        textAlign: TextAlign.left,
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteNote(noteList[index]['pdfPath'].toString(), noteList[index]['imagePath'].toString());
                                noteList.removeAt(index);
                                saveNoteList();
                                Navigator.pop(context);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
                },
                title: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: FileImage(File(noteList[index]['imagePath'])),
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(noteList[index]['title']),
                  ]
              ),
            ],
          );
        },

      ),
      floatingActionButton: SpeedDial(
        icon: Icons.create,
        children: [
          SpeedDialChild(
            onTap: () async {
              XFile? picture = await ImagePicker().pickImage(
                  source: ImageSource.camera
              );

              final pictureFile = File(picture!.path);
              createPDF(pictureFile);
              incrementNoteCounter();
            },
            label: 'Take Picture',
            child: const Icon(Icons.add_a_photo),
            backgroundColor: Colors.lightBlueAccent,
          ),
          SpeedDialChild(
            onTap: () async {
              XFile? image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );

              final imageFile = File(image!.path);
              createPDF(imageFile);
              incrementNoteCounter();
            },
            label: 'Add Image',
            child: const Icon(Icons.add_photo_alternate),
            backgroundColor: Colors.lightBlueAccent,
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
