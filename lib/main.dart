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
    print("------------");
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

  void removeFavorite(value){
    favorites.remove(value);
    notifyListeners();
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
    // TODO: implement initState
    super.initState();
    changePages(0);
  }

  void changePages(int selectedIndex){
    
    switch (selectedIndex) {
      case 0:
        setState(() {
          page = GeneratorPage();
        });
        break;
      case 1:
        setState(() {
          page = FavoritesPage();
        });
        print('FavoritesPage');
        break;
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
            label:'Home',
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

class GeneratorPage  extends StatelessWidget {
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                icon: Icon(icon,size: 20.0,),
                label: Text('Like'),
              ),
              SizedBox(width: 10),

              ElevatedButton(
                onPressed: () {
                  appState.getNext();
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

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(pair.asLowerCase, style: style),
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
    var messages =  <WordPair>[];
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }
    else{
      messages = appState.favorites;
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left:20.0, top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("you have ${messages.length} favourites :", style: const TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: FavouritesGrid(messages: messages, theme: theme),
              ),
            ],
          ),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0),
      // padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.primary, width: 2)),
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18.0,
                    color: theme.colorScheme.primary,
                    shadows: <Shadow>[Shadow(color: theme.colorScheme.primary , blurRadius: 3.0)],
                  ),
                  onPressed: () =>{ 
                    appState.removeFavorite(messages[index])
                  },
                ),
                Text(messages[index].toString()),
              ],
            ),
        );
      },
    );
  }
}