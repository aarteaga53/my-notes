import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'note_list.dart';
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

  List<NoteList> notes = <NoteList>[];
  int noteCounter = 0;
  String viewType = 'Grid';

  @override
  void initState() {
    super.initState();
    loadNoteCounter();
    loadNoteList();
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
        NoteList note = NoteList(lines[i], lines[++i], lines[++i]);
        notes.add(note);
      }
    }
    setState(() {

    });
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
    NoteList note = NoteList(
      filepath + '/note_image' + noteCounter.toString() + '.jpeg',
      filename,
      'Note' + noteCounter.toString()
    );
    notes.add(note);
    saveNoteList();
  }

  void saveNoteList() async {
    String filepath = await getFilepath();
    final file = File('$filepath/noteList.txt');
    file.writeAsStringSync('Note List\n');
    for (var element in notes) {
      file.writeAsStringSync(element.imagePath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.pdfPath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.title + '\n', mode: FileMode.append);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
                height: 125,
                child: DrawerHeader(
                  child: Text(''),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
              ListTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(Icons.star, size: 18),
                        ),
                      ),
                      TextSpan(text: ' Favorite', style: Theme.of(context).textTheme.bodyText2),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(Icons.delete, size: 18),
                        ),
                      ),
                      TextSpan(text: ' Trash', style: Theme.of(context).textTheme.bodyText2),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          )
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
          title: Center(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          actions: [
            Center(
              child: DropdownButton<String>(
                icon: const Icon(Icons.more_vert),
                elevation: 16,
                underline: DropdownButtonHideUnderline(child: Container()),
                onChanged: (String? newValue) {
                  setState(() {
                    viewType = newValue!;
                  });
                },
                items: <String>['Grid', 'List',]
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            )
          ],
        ),
      ),
      body: viewType == 'Grid' ?
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 25,
            ),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotePage(notes[index])),
                  );
                  saveNoteList();
                },
                onLongPress: () {
                  showDialog(context: context, builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(notes[index].title),
                      actionsAlignment: MainAxisAlignment.center,
                      content: const Text(
                        'Are you sure you want to delete this note.',
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
                                deleteNote(notes[index].pdfPath, notes[index].imagePath);
                                notes.removeAt(index);
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
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: FileImage(File(notes[index].imagePath)),
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                    Expanded(
                      flex: 50,
                      child: Text(notes[index].title,
                          style: Theme.of(context).textTheme.bodyText2
                      ),
                    ),
                    Expanded(
                      flex: 50,
                      child: Text('10/26',
                          style: Theme.of(context).textTheme.bodyText2
                      ),
                    ),
                  ],
                ),
              );
            },
          ) :
          ListView.builder(
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotePage(notes[index])),
                  );
                  saveNoteList();
                },
                onLongPress: () {
                  showDialog(context: context, builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(notes[index].title),
                      actionsAlignment: MainAxisAlignment.center,
                      content: const Text(
                        'Are you sure you want to delete this note.',
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
                                deleteNote(notes[index].pdfPath, notes[index].imagePath);
                                notes.removeAt(index);
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
                title: SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        //margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: FileImage(File(notes[index].imagePath)),
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                      const Spacer(),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notes[index].title,
                                style: Theme.of(context).textTheme.bodyText2
                            ),
                            Text('10/26',
                                style: Theme.of(context).textTheme.bodyText2
                            )
                          ]
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.blueGrey,
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
          // SpeedDialChild(
          //   onTap: () {
          //
          //   },
          //   label: 'Create Folder',
          //   child: const Icon(Icons.create_new_folder_rounded),
          //   backgroundColor: Colors.lightBlueAccent,
          // ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
