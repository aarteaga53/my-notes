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
import 'favorite_page.dart';
import 'note_list.dart';
import 'note_page.dart';
import 'trash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  List<NoteList> trash = <NoteList>[];
  List<NoteList> favorites = <NoteList>[];
  int noteCounter = 0;
  String viewType = 'Grid';
  String sortType = 'Date';

  @override
  void initState() {
    super.initState();
    setState(() {
      loadData();
      loadNoteList();
      loadFavoriteList();
      loadTrashList();
    });
  }

  Future<void> deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if(appDir.existsSync()){
      appDir.deleteSync(recursive: true);
    }
  }

  void resetApp() async {
    deleteAppDir();
    deleteCacheDir();
    noteCounter = 0;
    viewType = 'Grid';
    sortType = 'Date';
    notes = <NoteList>[];
    trash = <NoteList>[];
    favorites = <NoteList>[];
    saveNoteList();
    saveTrashList();
    saveFavoriteList();
    setState(() {

    });
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    noteCounter = prefs.getInt('noteCounter') ?? 0;
    viewType = prefs.getString('viewType') ?? 'Grid';
    sortType = prefs.getString('sortType') ?? 'Date';
    setState(() {

    });
  }

  void loadNoteList() async {
    String filepath = await getFilepath();
    if(File('$filepath/noteList.txt').existsSync()) {
      final file = File('$filepath/noteList.txt');
      List<NoteList> temp = <NoteList>[];

      List<String> lines = file.readAsLinesSync();

      for(int i = 1; i < lines.length - 4; i++) {
        NoteList note = NoteList(lines[i], lines[++i], lines[++i], int.parse(lines[++i]), lines[++i]);
        temp.add(note);
      }
      setState(() {
        notes = temp;
      });
    }
  }

  void loadFavoriteList() async {
    String filepath = await getFilepath();
    if(File('$filepath/favoriteList.txt').existsSync()) {
      final file = File('$filepath/favoriteList.txt');
      List<NoteList> temp = <NoteList>[];

      List<String> lines = file.readAsLinesSync();

      for(int i = 1; i < lines.length - 4; i++) {
        NoteList note = NoteList(lines[i], lines[++i], lines[++i], int.parse(lines[++i]), lines[++i]);
        temp.add(note);
      }
      setState(() {
        favorites = temp;
      });
    }
  }

  void loadTrashList() async {
    String filepath = await getFilepath();
    if(File('$filepath/trashList.txt').existsSync()) {
      final file = File('$filepath/trashList.txt');
      List<NoteList> temp = <NoteList>[];

      List<String> lines = file.readAsLinesSync();

      for(int i = 1; i < lines.length - 4; i++) {
        NoteList note = NoteList(lines[i], lines[++i], lines[++i], int.parse(lines[++i]), lines[++i]);
        var date = DateTime.fromMillisecondsSinceEpoch(note.timestamp).add(const Duration(days: 30));
        var now = DateTime.now();
        if(date.isAfter(now)) {
          temp.add(note);
        }
        else {
          deletePermanently(note.pdfPath, note.imagePath);
          saveTrashList();
        }
      }
      setState(() {
        trash = temp;
      });
    }
  }

  void incrementNoteCounter() async {
    final prefs = await SharedPreferences.getInstance();
    noteCounter++;
    prefs.setInt('noteCounter', noteCounter);
    setState(() {

    });
  }

  void setViewType() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('viewType', viewType);
    setState(() {

    });
  }

  void setSortType() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sortType', sortType);
    setState(() {
      if(sortType == 'Date') {
        sortDate();
      }
      else {
        sortTitle();
      }
    });
  }

  void saveNoteList() async {
    setSortType();
    String filepath = await getFilepath();
    final file = File('$filepath/noteList.txt');
    file.writeAsStringSync('Image Path, Pdf Path, Title, Timestamp, Favorite\n');
    
    for (var element in notes) {
      file.writeAsStringSync(element.imagePath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.pdfPath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.title + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.timestamp.toString() + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.favorite + '\n', mode: FileMode.append);
    }
    setState(() {

    });
  }

  void saveFavoriteList() async {
    favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    String filepath = await getFilepath();
    final file = File('$filepath/favoriteList.txt');
    file.writeAsStringSync('Image Path, Pdf Path, Title, Timestamp, Favorite\n');

    for (var element in favorites) {
      file.writeAsStringSync(element.imagePath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.pdfPath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.title + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.timestamp.toString() + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.favorite + '\n', mode: FileMode.append);
    }
    setState(() {

    });
  }

  void saveTrashList() async {
    trash.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    String filepath = await getFilepath();
    final file = File('$filepath/trashList.txt');
    file.writeAsStringSync('Image Path, Pdf Path, Title, Timestamp, Favorite\n');

    for (var element in trash) {
      file.writeAsStringSync(element.imagePath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.pdfPath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.title + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.timestamp.toString() + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.favorite + '\n', mode: FileMode.append);
    }
    setState(() {

    });
  }

  Future<String> getFilepath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
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

  void createNote(String filepath, String filename) {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    NoteList note = NoteList(
      filepath + '/note_image' + noteCounter.toString() + '.jpeg',
      filename,
      'Note' + noteCounter.toString(),
      timestamp,
      'no',
    );
    notes.add(note);
    saveNoteList();
  }

  void deletePermanently(String pdfPath, String imagePath) async {
    File file = File(pdfPath);
    file.delete;
    file = File(imagePath);
    file.delete;
  }

  void sortDate() {
    notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void sortTitle() {
    notes.sort((a, b) => a.title.compareTo(b.title));
  }

  void showBottom(int index) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Row(
          children: [
            Expanded(
              flex: 50,
              child: TextButton(
                onPressed: () {
                  if(notes[index].favorite == 'yes') {
                    favorites.removeWhere((element) => element.imagePath == notes[index].imagePath);
                    notes[index].favorite = 'no';
                  }
                  notes[index].timestamp = DateTime.now().millisecondsSinceEpoch;
                  trash.add(notes[index]);
                  notes.removeAt(index);
                  saveNoteList();
                  saveFavoriteList();
                  saveTrashList();
                  Navigator.pop(context);
                },
                child: const Text('Delete',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 50,
              child: TextButton(
                onPressed: () {
                  if(notes[index].favorite == 'no') {
                    notes[index].favorite = 'yes';
                    favorites.add(notes[index]);
                  }
                  else {
                    favorites.removeWhere((element) => element.imagePath == notes[index].imagePath);
                    notes[index].favorite = 'no';
                  }
                  saveNoteList();
                  saveFavoriteList();
                  Navigator.pop(context);
                },
                child: notes[index].favorite == 'no' ?
                const Text('Favorite',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ) :
                const Text('Unfavorite',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void noteTap(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotePage(notes[index])),
    );
    saveNoteList();
    favorites[favorites.indexWhere((element) => element.imagePath == notes[index].imagePath)] = notes[index];
    saveFavoriteList();
  }

  String timestampFormat(int index) {
    var time = DateTime.fromMillisecondsSinceEpoch(notes[index].timestamp);
    var current = DateTime.now();
    if(time.day == current.day && time.year == current.year) {
      if(time.hour > 12) {
        return (time.hour - 12).toString() + ':' + time.minute.toString() + ' pm';
      }
      else {
        return time.hour.toString() + ':' + time.minute.toString() + ' am';
      }
    }
    else if(time.year == time.year) {
      return time.month.toString() + '/' + time.day.toString();
    }
    else {
      return time.month.toString() + '/' + time.day.toString() + '/' + time.year.toString();
    }
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
              SizedBox(
                height: 110,
                child: DrawerHeader(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () {
                          showMenu<String>(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)
                                )
                            ),
                            context: context,
                            position: const RelativeRect.fromLTRB(0, 0, 10, 0),
                            items: ['Reset'].map((String sortValue) {
                              return PopupMenuItem<String>(
                                value: sortValue,
                                child: Text(sortValue),
                              );
                            }).toList(),
                          ).then((String? value) {
                            if(value != null) {
                              resetApp();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  decoration: const BoxDecoration(
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
                          child: Icon(Icons.notes, size: 18),
                        ),
                      ),
                      TextSpan(text: ' My Notes', style: Theme.of(context).textTheme.bodyText2),
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
                          child: Icon(Icons.star, size: 18),
                        ),
                      ),
                      TextSpan(text: ' Favorites', style: Theme.of(context).textTheme.bodyText2),
                    ],
                  ),
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritePage(notes, favorites, viewType)),
                  );
                  loadFavoriteList();
                  saveNoteList();
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
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrashPage(notes, trash, viewType)),
                  );
                  loadTrashList();
                  saveNoteList();
                  Navigator.pop(context);
                },
              ),
            ],
          )
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75.0),
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
              child: PopupMenuButton<String>(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10)
                  )
                ),
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) {
                  return ['Sort', 'View'].map((String value) {
                    return PopupMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList();
                },
                onSelected: (String? newValue) {
                  setState(() {
                    if(newValue == 'Sort') {
                      showMenu<String>(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(10)
                            )
                        ),
                        context: context,
                        position: const RelativeRect.fromLTRB(100, 0, 0, 0),
                        items: ['Date', 'Title'].map((String sortValue) {
                          return PopupMenuItem<String>(
                            value: sortValue,
                            child: Text(sortValue),
                          );
                        }).toList(),
                      ).then((String? value) {
                        if(value != null) {
                          setState(() {
                            sortType = value;
                            setSortType();
                          });
                        }
                      });
                    }
                    else {
                      showMenu<String>(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(10)
                            )
                        ),
                        context: context,
                        position: const RelativeRect.fromLTRB(100, 0, 0, 0),
                        items: ['Grid', 'List'].map((String viewValue) {
                          return PopupMenuItem<String>(
                            value: viewValue,
                            child: Text(viewValue),
                          );
                        }).toList(),
                      ).then((String? value) {
                        if(value != null) {
                          setState(() {
                            viewType = value;
                            setViewType();
                          });
                        }
                      });
                    }
                  });
                }
              )
            ),
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
                onTap: () {
                  noteTap(index);
                },
                onLongPress: () {
                  showBottom(index);
                },
                title: Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: FileImage(File(notes[index].imagePath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                subtitle: Center(
                  child: Column(
                    children: [
                      Text(notes[index].title,
                          style: Theme.of(context).textTheme.bodyText2
                      ),
                      Text(
                        timestampFormat(index),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ) :
          ListView.builder(
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  noteTap(index);
                },
                onLongPress: () {
                  showBottom(index);
                },
                title: SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        margin: const EdgeInsets.only(right: 25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: FileImage(File(notes[index].imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(notes[index].title,
                              style: Theme.of(context).textTheme.bodyText2
                          ),
                          Text(
                            timestampFormat(index),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(notes[index].favorite == 'yes' ? Icons.star : Icons.star_border),
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
            foregroundColor: Theme.of(context).cardColor,
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
            foregroundColor: Theme.of(context).cardColor,
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
