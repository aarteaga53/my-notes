import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'note.dart';

//ignore: must_be_immutable
class TrashPage extends StatefulWidget {
  TrashPage(this.notes, this.trash, this.viewType, {Key? key}) : super(key: key);

  List<Note> notes;
  List<Note> trash;
  String viewType;

  @override
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {

  void saveTrashList() async {
    widget.trash.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    String filepath = await getFilepath();
    final file = File('$filepath/trashList.txt');
    file.writeAsStringSync('Image Path,Folder Path,Title,Timestamp,Favorite\n');

    for (var element in widget.trash) {
      file.writeAsStringSync(element.imagepath + ',' + element.folderpath + ',' +
          element.title + ',' + element.timestamp.toString() + ',' + element.favorite + '\n',
          mode:  FileMode.append
      );
    }
    setState(() {

    });
  }

  void deletePermanently(String folderpath, String imagepath) async {
    Directory(folderpath).deleteSync(recursive: true);
    File(imagepath).delete();
  }

  Future<String> getFilepath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void deleteNote(int index) {
    deletePermanently(widget.trash[index].folderpath, widget.trash[index].imagepath);
    widget.trash.removeAt(index);
    saveTrashList();
  }

  void restoreNote(int index) {
    widget.trash[index].timestamp = DateTime.now().millisecondsSinceEpoch;
    widget.notes.add(widget.trash[index]);
    widget.trash.removeAt(index);
    saveTrashList();
  }

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
                  restoreNote(index);
                  Navigator.pop(context);
                },
                child: const Text('Restore',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String timeFormat(int index) {
    var time = DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp);
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.blueGrey,
            iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
            title: Center(
              child: Text(
                'Trash',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(15),
                child: Text(
                  'Notes will be permanently deleted after 30 days.',
                  style: Theme.of(context).textTheme.bodyText2,
                )
            ),
            actions: [
              Center(
                child: PopupMenuButton(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(10)
                      )
                  ),
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String? newValue){
                    setState(() {
                      if(newValue == 'Empty') {
                        for(int i = widget.trash.length-1; i >= 0; i--) {
                          deleteNote(i);
                        }
                      }
                      else {
                        for(int i = widget.trash.length-1; i >= 0; i--) {
                          restoreNote(i);
                        }
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Restore',
                      child: Text('Restore All'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Empty',
                      child: Text('Empty Trash'),
                    ),
                  ],
                ),
              )
            ],
          ),
          widget.viewType == 'Grid' ?
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
                    child: ListTile(
                      onLongPress: () => showBottom(index),
                      title: Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: FileImage(File(widget.trash[index].imagepath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      subtitle: Center(
                        child: Column(
                          children: [
                            widget.trash[index].title.length <= 9 ? Text(widget.trash[index].title,
                              style: Theme.of(context).textTheme.bodyText2,
                            ) :
                            Text(
                              widget.trash[index].title.substring(0, 9) + '...',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            Text(
                              timeFormat(index),
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.trash.length,
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
                      onLongPress: () => showBottom(index),
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
                                  image: FileImage(File(widget.trash[index].imagepath)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.trash[index].title.length <= 15 ? Text(widget.trash[index].title,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ) :
                                Text(
                                  widget.trash[index].title.substring(0, 15) + '...',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Text(
                                  timeFormat(index),
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => deleteNote(index),
                              icon: const Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () => restoreNote(index),
                              icon: const Icon(Icons.restore_from_trash),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.trash.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
