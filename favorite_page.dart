import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_list.dart';
import 'note_page.dart';

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
        itemCount: widget.favorites.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotePage(widget.favorites[index])),
              );
              saveFavoriteList();
              widget.notes[widget.notes.indexWhere((element) => element.imagePath == widget.favorites[index].imagePath)].title = widget.favorites[index].title;
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
                            )
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
                        image: FileImage(File(widget.favorites[index].imagePath)),
                        fit: BoxFit.cover,
                      )
                  ),
                ),
                Expanded(
                  flex: 50,
                  child: Text(widget.favorites[index].title,
                      style: Theme.of(context).textTheme.bodyText2
                  ),
                ),
                Expanded(
                  flex: 50,
                  child: Text(
                      DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).year == DateTime.now().year ?
                      DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).month.toString() + '/' +
                          DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).day.toString() :
                      DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).month.toString() + '/' +
                          DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).day.toString() + '/' +
                          DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).year.toString(),
                      style: Theme.of(context).textTheme.bodyText2
                  ),
                ),
              ],
            ),
          );
        },
      ) :
      ListView.builder(
        itemCount: widget.favorites.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotePage(widget.favorites[index])),
              );
              saveFavoriteList();
              widget.notes[widget.notes.indexWhere((element) => element.imagePath == widget.favorites[index].imagePath)].title = widget.favorites[index].title;
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
                            )
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
                          image: FileImage(File(widget.favorites[index].imagePath)),
                          fit: BoxFit.cover,
                        )
                    ),
                  ),
                  const Spacer(),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.favorites[index].title,
                            style: Theme.of(context).textTheme.bodyText2
                        ),
                        Text(DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).year == DateTime.now().year ?
                        DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).month.toString() + '/' +
                            DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).day.toString() :
                        DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).month.toString() + '/' +
                            DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).day.toString() + '/' +
                            DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp).year.toString(),
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
    );
  }
}
