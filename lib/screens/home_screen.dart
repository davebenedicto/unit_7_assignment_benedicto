import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureCharacters;

  @override
  void initState() {
    super.initState();
    futureCharacters = fetchCharacters();
  }

  Future<List<dynamic>> fetchCharacters() async {
    const url = 'https://api.disneyapi.dev/character';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder(
        future: futureCharacters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final characters = snapshot.data!;
            return ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                final controller = ExpandedTileController();

                return ExpandedTile(
                  controller: controller,
                  title: Text(character['name']),
                  trailing: Text(
                    character['films'].isNotEmpty
                        ? "Appeared in: ${character['films'].join(', ')}"
                        : "No films listed",
                  ),
                  leading: character['imageUrl'] != null
                      ? Image.network(
                          character['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TV Shows: ${character['tvShows'].join(', ')}"),
                      Text(
                          "Video Games: ${character['videoGames'].join(', ')}"),
                      Text("Source: ${character['sourceUrl']}"),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}
