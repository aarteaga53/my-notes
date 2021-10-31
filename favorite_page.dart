import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'note_list.dart';
import 'note_page.dart';

//ignore: must_be_immutable
class FavoritePage extends StatefulWidget {
  FavoritePage(this.notes, this.favorites, this.viewType, {Key? key}) : super(key: key);

  List<NoteList> notes;
  List<NoteList> favorites;
  String viewType;

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  void saveFavoriteList() async {
    widget.favorites.sort((a, b) => a.title.compareTo(b.title));

    String filepath = await getFilepath();
    final file = File('$filepath/favoriteList.txt');
    file.writeAsStringSync('Favorite List\n');

    for (var element in widget.favorites) {
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
              //flex: 50,
              child: TextButton(
                onPressed: () {
                  widget.notes[widget.notes.indexWhere((element) => element.imagePath == widget.favorites[index].imagePath)].favorite = 'no';
                  widget.favorites.removeAt(index);
                  saveFavoriteList();
                  Navigator.pop(context);
                },
                child: const Text('Unfavorite',
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
      MaterialPageRoute(builder: (context) => NotePage(widget.favorites[index])),
    );
    saveFavoriteList();
    widget.notes[widget.notes.indexWhere((element) => element.imagePath == widget.favorites[index].imagePath)].title = widget.favorites[index].title;
  }

  String timestampFormat(int index) {
    var time = DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp);
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
              'Favorites',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          actions: [
            Center(
              child: PopupMenuButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(10)
                  ),
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
        itemCount: widget.favorites.length,
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: FileImage(File(widget.favorites[index].imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            subtitle: Center(
              child: Column(
                children: [
                  Text(widget.favorites[index].title,
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
        itemCount: widget.favorites.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () async {
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
                        image: FileImage(File(widget.favorites[index].imagePath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.favorites[index].title,
                          style: Theme.of(context).textTheme.bodyText2
                      ),
                      Text(
                        timestampFormat(index),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.star),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
