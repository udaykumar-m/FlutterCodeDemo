import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      print(current);
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(value) {
    favorites.remove(value);
    notifyListeners();
  }

  void showToast(BuildContext context, WordPair value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              text: "Removed ",
              children: <TextSpan>[
                TextSpan(
                    text: value.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: " from favourites"),
              ],
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      behavior: SnackBarBehavior.floating,
      // width: 260.0,
      duration: const Duration(milliseconds: 800),
      elevation: 0,
    ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  Widget? page;

  @override
  void initState() {
    super.initState();
    changePages(0);
  }

  void changePages(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        setState(() {
          page = GeneratorPage();
        });
      case 1:
        setState(() {
          page = FavoritesPage();
        });
        print('FavoritesPage');
      default:
      // setState(() {
      //   page = GeneratorPage();
      // });
      // throw UnimplementedError('no widget for $selectedIndex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: page,
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
            print(selectedIndex);
            changePages(selectedIndex);
          });
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    var favList = appState.favorites.toList();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ListView.builder(
          //     itemCount: appState.favorites.length,
          //     itemBuilder: (context, i) =>
          //         Text(appState.favorites[i].toString())),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                favList.isEmpty
                    ? Text('Tap on Like to Add Favorites')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: favList.length > 4 ? 4 : favList.length,
                        itemBuilder: (BuildContext context, int index) {
                          int itemIndex = favList.length > 4
                              ? (favList.length - 4 + index)
                              : index;
                
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(favList[itemIndex].toString()),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BigCard(pair: pair),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        appState.toggleFavorite();
                      },
                      icon: Icon(
                        icon,
                        size: 20.0,
                      ),
                      label: Text('Like'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        appState.getNext();
                        print(favList.isEmpty);
                      },
                      child: Row(
                        children: [
                          Text('Next'),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final styleWord = theme.textTheme.displayMedium!.copyWith(
        color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Wrap(
          children: [
            Text(pair.first, style: style),
            Text(
              pair.second,
              style: styleWord,
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var appState = context.watch<MyAppState>();
    var messages = <WordPair>[];
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    } else {
      messages = appState.favorites;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("you have ${messages.length} favourites :",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: FavouritesGrid(messages: messages, theme: theme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavouritesGrid extends StatelessWidget {
  const FavouritesGrid({
    super.key,
    required this.messages,
    required this.theme,
  });

  final List<WordPair> messages;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0),
      // padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: messages.length,
      physics: ScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(25))),
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 24.0,
                  color: theme.colorScheme.primary,
                  shadows: <Shadow>[
                    Shadow(color: Colors.white, blurRadius: 10.0)
                  ],
                ),
                onPressed: () => {
                  appState.showToast(context, messages[index]),
                  appState.removeFavorite(messages[index]),
                },
              ),
              Text(
                messages[index].toString(),
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
