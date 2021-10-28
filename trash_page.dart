import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_list.dart';

class TrashPage extends StatefulWidget {
  TrashPage(this.notes, this.trash, this.viewType, {Key? key}) : super(key: key);

  List<NoteList> notes;
  List<NoteList> trash;
  String viewType;

  @override
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {

  void saveTrashList() async {
    widget.trash.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    String filepath = await getFilepath();
    final file = File('$filepath/trashList.txt');
    file.writeAsStringSync('Trash List\n');

    for (var element in widget.trash) {
      file.writeAsStringSync(element.imagePath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.pdfPath + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.title + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.timestamp.toString() + '\n', mode: FileMode.append);
      file.writeAsStringSync(element.favorite + '\n', mode: FileMode.append);
    }
    setState(() {

    });
  }

  void deletePermanently(String pdfPath, String imagePath) async {
    File file = File(pdfPath);
    file.delete;
    file = File(imagePath);
    file.delete;
  }

  Future<String> getFilepath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context, widget.viewType);
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
          title: Center(
            child: Text(
              'Trash',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10.0),
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
                    widget.viewType = newValue!;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Grid',
                    child: Text('Grid'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'List',
                    child: Text('List'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: widget.viewType == 'Grid' ?
      GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 25,
        ),
        itemCount: widget.trash.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {

            },
            onLongPress: () {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))
                ),
                context: context,
                builder: (BuildContext context) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 50,
                        child: TextButton(
                          onPressed: () {
                            deletePermanently(widget.trash[index].pdfPath, widget.trash[index].imagePath);
                            widget.trash.removeAt(index);
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
                            widget.trash[index].timestamp = DateTime.now().millisecondsSinceEpoch;
                            widget.notes.add(widget.trash[index]);
                            widget.trash.removeAt(index);
                            saveTrashList();
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
            },
            title: Column(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: FileImage(File(widget.trash[index].imagePath)),
                        fit: BoxFit.cover,
                      )
                  ),
                ),
                Expanded(
                  flex: 50,
                  child: Text(widget.trash[index].title,
                      style: Theme.of(context).textTheme.bodyText2
                  ),
                ),
                Expanded(
                  flex: 50,
                  child: Text(
                      DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).year == DateTime.now().year ?
                      DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).month.toString() + '/' +
                          DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).day.toString() :
                      DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).month.toString() + '/' +
                          DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).day.toString() + '/' +
                          DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).year.toString(),
                      style: Theme.of(context).textTheme.bodyText2
                  ),
                ),
              ],
            ),
          );
        },
      ) :
      ListView.builder(
        itemCount: widget.trash.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {

            },
            onLongPress: () {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))
                ),
                context: context,
                builder: (BuildContext context) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 50,
                        child: TextButton(
                          onPressed: () {
                            deletePermanently(widget.trash[index].pdfPath, widget.trash[index].imagePath);
                            widget.trash.removeAt(index);
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
                            widget.trash[index].timestamp = DateTime.now().millisecondsSinceEpoch;
                            widget.notes.add(widget.trash[index]);
                            widget.trash.removeAt(index);
                            saveTrashList();
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
            },
            title: SizedBox(
              height: 100,
              child: Row(
                children: [
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: FileImage(File(widget.trash[index].imagePath)),
                          fit: BoxFit.cover,
                        )
                    ),
                  ),
                  const Spacer(),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.trash[index].title,
                            style: Theme.of(context).textTheme.bodyText2
                        ),
                        Text(DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).year == DateTime.now().year ?
                        DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).month.toString() + '/' +
                            DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).day.toString() :
                        DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).month.toString() + '/' +
                            DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).day.toString() + '/' +
                            DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp).year.toString(),
                            style: Theme.of(context).textTheme.bodyText2
                        )
                      ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
