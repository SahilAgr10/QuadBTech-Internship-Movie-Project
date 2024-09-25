// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Test',
        theme: ThemeData(
          brightness: Brightness.dark,  // Set dark theme
          primarySwatch: Colors.red,     // Netflix's red accent
          scaffoldBackgroundColor: Colors.black, // Black background
        ),
      home: SplashScreen()
    );
  }
}

class BottomNavigationBarScreen extends StatefulWidget {
  @override
  _BottomNavigationBarScreenState createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

// splash_screen.dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationBarScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset('assets/images/popcornA.png', width: 150), // Add Netflix-like logo
      ),
    );
  }
}


// home_screen.dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=all'));

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      setState(() {
        _movies = jsonData.map((json) => Movie.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          return MovieCard(
            movie: _movies[index],
          );
        },
      ),
    );
  }
}

// movie_card.dart
// Updated MovieCard Widget for a Netflix-like appearance
class MovieCard extends StatelessWidget {
  final Movie movie;

  MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 10,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(movie: movie),
            ),
          );
        },

        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: movie.image.isNotEmpty
                  ? Image.network(
                movie.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              )
                  : Image.asset(
                'assets/images/discover1.jpg',  // Add a default image in case image is missing
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    movie.summary,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// search_screen.dart
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

// Fix the search screen search functionality
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];

  Future<void> _searchMovies() async {
    final searchQuery = _searchController.text;
    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$searchQuery'));

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      setState(() {
        _searchResults = jsonData.map((json) => Movie.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Dark background like Netflix
      appBar: AppBar(
        title: Text('Search Movies'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              onSubmitted: (query) {
                _searchMovies();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return MovieCard(
                  movie: _searchResults[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// details_screen.dart
class DetailsScreen extends StatelessWidget {
  final Movie movie;

  DetailsScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(movie.image,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Image.asset('assets/images/discover1.jpg'); // Path to your default image
              },),
            Text(movie.title),
            Text(movie.summary),
          ],
        ),
      ),
    );
  }
}

// movie_model.dart
class Movie {
  final String image;
  final String title;
  final String summary;

  Movie({required this.image, required this.title, required this.summary});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      image: json['show']['image'] != null
          ? json['show']['image']['medium'] ?? ''
          : '',
      title: json['show']['name'] ?? '',
      summary: json['show']['summary'] ?? '',
    );
  }
}