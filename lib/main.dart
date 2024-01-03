import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email/Mobile',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email/mobile';
                  }
                  // Add more email/mobile validation if needed
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  // Add more password validation if needed
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (formKey.currentState!.validate()) {
                    // Perform login logic here (e.g., check credentials)
                    // For simplicity, let's assume login is successful
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NextScreen(),
                      ),
                    );
                  }
                },
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class NextScreen extends StatefulWidget {
  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  late Future<List<Map<String, dynamic>>> news;
  String selectedCategory = "national";
  Set<String> bookmarks = Set<String>();

  @override
  void initState() {
    super.initState();
    news = fetchNews(selectedCategory);
  }

  Future<List<Map<String, dynamic>>> fetchNews(String category) async {
    final url = Uri.parse('https://inshortsapi.vercel.app/news?category=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> data = jsonData['data'];

      return data.cast<Map<String, dynamic>>(); // Convert to a list of maps
    } else {
      throw Exception('Failed to fetch news');
    }
  }

  void changeCategory(String newCategory) {
    setState(() {
      selectedCategory = newCategory;
      news = fetchNews(selectedCategory);
    });
  }

  void toggleBookmark(String newsId) {
    setState(() {
      if (bookmarks.contains(newsId)) {
        bookmarks.remove(newsId);
      } else {
        bookmarks.add(newsId);
      }
    });
  }

  bool isBookmarked(String newsId) {
    return bookmarks.contains(newsId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
        actions: [
          PopupMenuButton<String>(
            onSelected: changeCategory,
            itemBuilder: (BuildContext context) {
              return [
                'all',
                'national',
                'business',
                'sports',
                'world',
                'politics',
                'technology',
                'startup',
                'entertainment',
                'miscellaneous',
                'hatke',
                'science',
                'automobile',
              ].map((String category) {
                return PopupMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              // Handle bookmarks menu action
              // Navigate to the bookmarks screen or do something else
            },
            itemBuilder: (BuildContext context) {
              return [
                'Bookmarks',
              ].map((String action) {
                return PopupMenuItem<String>(
                  value: action,
                  child: Text(action),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: news,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to fetch news'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No news available'));
          } else {
            final List<Map<String, dynamic>> newsData = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  for (final newsItem in newsData)
                    NewsCard(
                      newsItem: newsItem,
                      onBookmark: () => toggleBookmark(newsItem['id']),
                      isBookmarked: isBookmarked(newsItem['id']),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final Map<String, dynamic> newsItem;
  final VoidCallback onBookmark;
  final bool isBookmarked;

  const NewsCard({
    required this.newsItem,
    required this.onBookmark,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(newsItem['imageUrl']),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Add this line
                      child: Text(
                        newsItem['title'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.blue : null,
                      ),
                      onPressed: onBookmark,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  newsItem['content'],
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
