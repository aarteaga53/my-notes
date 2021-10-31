import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'note_list.dart';

//ignore: must_be_immutable
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

  void showBottom(int index) {
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
  }

  String timestampFormat(int index) {
    var time = DateTime.fromMillisecondsSinceEpoch(widget.trash[index].timestamp);
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75.0),
        child: AppBar(
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
              showBottom(index);
            },
            title: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: FileImage(File(widget.trash[index].imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            subtitle: Center(
              child: Column(
                children: [
                  Text(widget.trash[index].title,
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
        itemCount: widget.trash.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {

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
                        image: FileImage(File(widget.trash[index].imagePath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.trash[index].title,
                          style: Theme.of(context).textTheme.bodyText2
                      ),
                      Text(
                        timestampFormat(index),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.star_border),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
