import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_page.dart';
import 'note.dart';
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

  List<Note> notes = <Note>[];
  List<Note> trash = <Note>[];
  List<Note> favorites = <Note>[];
  int noteCounter = 1;
  String viewType = 'Grid';
  String sortType = 'Date';
  bool isFabVisible = true;

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

  /// Deletes all data and files to start new
  void resetApp() async {
    deleteAppDir();
    deleteCacheDir();
    noteCounter = 1;
    viewType = 'Grid';
    sortType = 'Date';
    notes = <Note>[];
    trash = <Note>[];
    favorites = <Note>[];
    saveNoteList();
    saveTrashList();
    saveFavoriteList();
    setState(() {

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

  /// Loads the noteCounter, viewType, and sortType variables if they are saved
  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    noteCounter = prefs.getInt('noteCounter') ?? 1;
    viewType = prefs.getString('viewType') ?? 'Grid';
    sortType = prefs.getString('sortType') ?? 'Date';
    setState(() {

    });
  }

  /// Reads a text file that contains data for the notes
  /// Creates a new note from the data being read and adds
  /// it to the notes variable
  void loadNoteList() async {
    String filepath = await getFilepath();
    if(File('$filepath/noteList.txt').existsSync()) {
      final file = File('$filepath/noteList.txt');
      List<Note> temp = <Note>[];

      List<String> lines = file.readAsLinesSync();

      for(int i = 1; i < lines.length; i++) {
        List line = lines[i].split(',');
        Note note = Note(line[0], line[1], line[2], int.parse(line[3]), line[4]);
        temp.add(note);
      }

      setState(() {
        notes = temp;
      });
    }
  }

  /// Reads a text file that contains data for the notes
  /// Creates a new note from the data being read and adds
  /// it to the favorites variable
  void loadFavoriteList() async {
    String filepath = await getFilepath();
    if(File('$filepath/favoriteList.txt').existsSync()) {
      final file = File('$filepath/favoriteList.txt');
      List<Note> temp = <Note>[];

      List<String> lines = file.readAsLinesSync();

      for(int i = 1; i < lines.length; i++) {
        List line = lines[i].split(',');
        Note note = Note(line[0], line[1], line[2], int.parse(line[3]), line[4]);
        temp.add(note);
      }

      setState(() {
        favorites = temp;
      });
    }
  }

  /// Reads a text file that contains data for the notes
  /// Creates a new note from the data being read and adds
  /// it to the trash variable
  void loadTrashList() async {
    String filepath = await getFilepath();
    if(File('$filepath/trashList.txt').existsSync()) {
      final file = File('$filepath/trashList.txt');
      List<Note> temp = <Note>[];

      List<String> lines = file.readAsLinesSync();

      for(int i = 1; i < lines.length; i++) {
        List line = lines[i].split(',');
        var date = DateTime.fromMillisecondsSinceEpoch(int.parse(line[3])).add(const Duration(days: 30));
        var now = DateTime.now();
        if(date.isAfter(now)) {
          Note note = Note(line[0], line[1], line[2], int.parse(line[3]), line[4]);
          temp.add(note);
        }
        else {
          deletePermanently(line[1], line[0]);
        }
      }

      saveTrashList();
      setState(() {
        trash = temp;
      });
    }
  }

  /// Increments the note counter and saves the value
  void incrementNoteCounter() async {
    final prefs = await SharedPreferences.getInstance();
    noteCounter++;
    prefs.setInt('noteCounter', noteCounter);
    setState(() {

    });
  }

  /// Saves the value in the viewType variable
  void setViewType() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('viewType', viewType);
    setState(() {

    });
  }

  /// Saves the value in the sortType variable
  /// Sorts the data according to the sortType
  void setSortType() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sortType', sortType);
    setState(() {
      if(sortType == 'Date') {
        notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      else if(sortType == 'Title') {
        notes.sort((a, b) => a.title.compareTo(b.title));
      }
    });
  }

  /// Saves the notes variable into a text file
  void saveNoteList() async {
    setSortType();
    String filepath = await getFilepath();
    final file = File('$filepath/noteList.txt');
    file.writeAsStringSync('Image Path,Folder Path,Title,Timestamp,Favorite\n');

    for (var element in notes) {
      file.writeAsStringSync(element.imagepath + ',' + element.folderpath + ',' +
          element.title + ',' + element.timestamp.toString() + ',' + element.favorite + '\n',
          mode:  FileMode.append
      );
    }
    setState(() {

    });
  }

  /// Saves the favorites variable into a text file
  void saveFavoriteList() async {
    favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    String filepath = await getFilepath();
    final file = File('$filepath/favoriteList.txt');
    file.writeAsStringSync('Image Path,Folder Path,Title,Timestamp,Favorite\n');

    for (var element in favorites) {
      file.writeAsStringSync(element.imagepath + ',' + element.folderpath + ',' +
          element.title + ',' + element.timestamp.toString() + ',' + element.favorite + '\n',
          mode:  FileMode.append
      );
    }

    setState(() {

    });
  }

  /// Saves the trash variable into a text file
  void saveTrashList() async {
    trash.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    String filepath = await getFilepath();
    final file = File('$filepath/trashList.txt');
    file.writeAsStringSync('Image Path,Folder Path,Title,Timestamp,Favorite\n');

    for (var element in trash) {
      file.writeAsStringSync(element.imagepath + ',' + element.folderpath + ',' +
          element.title + ',' + element.timestamp.toString() + ',' + element.favorite + '\n',
          mode:  FileMode.append
      );
    }
    setState(() {

    });
  }

  /// Gets the path to the app's directory
  Future<String> getFilepath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Creates a new directory to store a set of notes in
  Future<void> createDirectory(File picture) async {
    String filepath = await getFilepath();
    String folderpath = '$filepath/note$noteCounter/';
    if(Directory(folderpath).existsSync()) {
      final dir = Directory(folderpath);
      dir.deleteSync(recursive: true);
    }
    Directory folder = await Directory(folderpath).create(recursive: true);
    createNote(folder.path, picture);
  }

  /// Creates a new note with properties
  void createNote(String folderpath, File picture) {
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    final file = File('$folderpath/$timestamp.jpeg');
    file.writeAsBytes(picture.readAsBytesSync());

    Note note = Note(
      file.path,
      folderpath,
      'Note$noteCounter',
      DateTime.now().millisecondsSinceEpoch,
      'no',
    );
    notes.add(note);
    saveNoteList();
  }

  /// Deletes a note, first removes it from the favorites list if in there
  /// then updates the timestamp and adds it to the trash, finally removes
  /// it from the notes list
  /// Saves all three lists
  void deleteNote(int index) {
    if(notes[index].favorite == 'yes') {
      favorites.removeWhere((element) => element.folderpath == notes[index].folderpath);
      notes[index].favorite = 'no';
    }

    notes[index].timestamp = DateTime.now().millisecondsSinceEpoch;
    trash.add(notes[index]);
    notes.removeAt(index);
    saveNoteList();
    saveFavoriteList();
    saveTrashList();
  }

  /// Deletes the image and pdf files of a note
  void deletePermanently(String folderpath, String imagepath) {
   Directory(folderpath).deleteSync(recursive: true);
   File(imagepath).delete;
  }

  /// Changes a note's favorite property and adds or
  /// removes from the favorite list accordingly
  /// Then saves the notes list and favorites list
  void toggleFavoriteNote(int index) {
    if(notes[index].favorite == 'no') {
      notes[index].favorite = 'yes';
      favorites.add(notes[index]);
    }
    else if(notes[index].favorite == 'yes') {
      favorites.removeWhere((element) => element.imagepath == notes[index].imagepath);
      notes[index].favorite = 'no';
    }

    saveNoteList();
    saveFavoriteList();
  }

  /// Widget that displays the Modal Bottom Sheet
  void showBottom(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Row(
          children: [
            Expanded(
              flex: 50,
              child: TextButton(
                onPressed: () {
                  deleteNote(index);
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
                  toggleFavoriteNote(index);
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

  /// Goes into the note page when a note is tapped
  void noteTap(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotePage(notes[index])),
    );
    if(!Directory(notes[index].folderpath).existsSync()) {
      if(notes[index].favorite == 'yes') {
        favorites.removeWhere((element) => element.folderpath == notes[index].folderpath);
        notes[index].favorite = 'no';
        saveFavoriteList();
      }
      notes.removeAt(index);
    }
    else {
      if(notes[index].favorite == 'yes') {
          favorites[favorites.indexWhere((element) => element.folderpath == notes[index].folderpath)] = notes[index];
          saveFavoriteList();
      }
    }
    saveNoteList();
  }

  /// Handles how the date will be displayed on the note
  String timeFormat(int index) {
    var time = DateTime.fromMillisecondsSinceEpoch(notes[index].timestamp);
    var current = DateTime.now();

    if(time.day == current.day && time.year == current.year) {
      return DateFormat('h:mm a').format(time);
    }
    else if(time.year == time.year) {
      return DateFormat.Md().format(time);
    }
    else {
      return DateFormat.yMd().format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 90,
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
                              Navigator.pop(context);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
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
                onTap: () => Navigator.pop(context),
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
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if(notification.direction == ScrollDirection.forward) {
            if(!isFabVisible) setState(() => isFabVisible = true);
          }
          else if(notification.direction == ScrollDirection.reverse) {
            if(isFabVisible) setState(() => isFabVisible = false);
          }

          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.blueGrey,
              iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
              floating: true,
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
                        Radius.circular(10),
                      ),
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
                                Radius.circular(10),
                              ),
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
                                Radius.circular(10),
                              ),
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
                    },
                  ),
                ),
              ],
            ),
            //const SliverPadding(padding: EdgeInsets.only(top: 5)),
            viewType == 'Grid' ?
            SliverPadding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 25,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 1.65),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Card(
                      // child: GridTile(
                      //   child: null,
                      // ),
                      child: ListTile(
                        onTap: () => noteTap(index),
                        onLongPress: () => showBottom(index),
                        title: Container(
                          height: 100,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: FileImage(File(notes[index].imagepath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        subtitle: Center(
                          child: Column(
                            children: [
                              notes[index].title.length <= 9 ? Text(notes[index].title,
                                style: Theme.of(context).textTheme.bodyText2,
                              ) :
                              Text(
                                notes[index].title.substring(0, 9) + '...',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              Text(timeFormat(index),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: notes.length,
                ),
              ),
            ) :
            SliverPadding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Card(
                      child: ListTile(
                        onTap: () => noteTap(index),
                        onLongPress: () => showBottom(index),
                        title: SizedBox(
                          height: 100,
                          child: Row(
                            children: [
                              Container(
                                width: 85,
                                height: 100,
                                margin: const EdgeInsets.only(right: 25),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: FileImage(File(notes[index].imagepath)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  notes[index].title.length <= 15 ? Text(notes[index].title,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ) :
                                  Text(
                                    notes[index].title.substring(0, 15) + '...',
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),
                                  Text(timeFormat(index),
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteNote(index),
                              ),
                              IconButton(
                                icon: Icon(notes[index].favorite == 'yes' ? Icons.star : Icons.star_border),
                                onPressed: () => toggleFavoriteNote(index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: notes.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isFabVisible ?
      SpeedDial(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Theme.of(context).cardColor,
        icon: Icons.create,
        children: [
          SpeedDialChild(
            onTap: () async {
              XFile? picture = await ImagePicker().pickImage(
                  source: ImageSource.camera
              );

              final pictureFile = File(picture!.path);
              await createDirectory(pictureFile);
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
              await createDirectory(imageFile);
              incrementNoteCounter();
            },
            label: 'Add Image',
            child: const Icon(Icons.add_photo_alternate),
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Theme.of(context).cardColor,
          ),
        ],
      ) : null,
    );
  }
}
