import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Album>> fetchAlbum() async {
  var url = 'http://192.168.0.146/cross_plat_sharing/flutter_share.php';

  //  "http://10.0.0.233/cross_plat_sharing/flutter_share.php";

  //
  //
  final response = await http.post(Uri.parse(url));
  // print(response.body);
  // return compute(parseAlbums, response.body);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    // return <List<Album>>().fromJson(jsonDecode(response.body));
    Iterable l = json.decode(response.body);
    return List<Album>.from(l.map((model) => Album.fromJson(model)));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

List<Album> parseAlbums(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Album>((json) => Album.fromJson(json)).toList();
}

class Album {
  final int id;
  final String title;
  final String created;
  final String imageurl;

  const Album({
    required this.id,
    required this.title,
    required this.created,
    required this.imageurl,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    print(json);
    print(
        "${json['id']} ${json['title']} ${json['created']} ${json['imageurl']}");
    return Album(
      id: json['id'],
      title: json['title'],
      created: json['created'],
      imageurl: json['imageurl'] ??
          'https://images.pexels.com/photos/949592/pexels-photo-949592.jpeg?cs=srgb&dl=pexels-rovenimagescom-949592.jpg&fm=jpg',
    );
  }
}

class FetchFlutterPage extends StatefulWidget {
  const FetchFlutterPage({super.key});

  @override
  State<FetchFlutterPage> createState() => _FetchFlutterPageState();
}

class _FetchFlutterPageState extends State<FetchFlutterPage> {
  late Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: 'Fetch Data',
        theme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Color.fromARGB(255, 255, 0, 234),
        ),
        home: CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                // This title is visible in both collapsed and expanded states.
                // When the "middle" parameter is omitted, the widget provided
                // in the "largeTitle" parameter is used instead in the collapsed state.
                largeTitle: Text('Instant Feed'),
              ),
              CupertinoSliverRefreshControl(onRefresh: () async {
                print("pull refreshed");
                setState(() {
                  futureAlbum = fetchAlbum();
                });

                // print(l);
              }),
              SliverFillRemaining(
                child: FutureBuilder<List<Album>>(
                  future: futureAlbum,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        color: CupertinoColors.darkBackgroundGray,
                        child: ListView.builder(
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            print(snapshot.data![index].imageurl);
                            return Column(
                              children: [
                                Text(
                                    style: const TextStyle(
                                        color: CupertinoColors
                                            .lightBackgroundGray),
                                    snapshot.data![index].title),
                                Text(
                                    style: const TextStyle(
                                        color: CupertinoColors
                                            .lightBackgroundGray),
                                    snapshot.data![index].created),
                                snapshot.data![index].imageurl == ''
                                    ? const Text('No Album Art')
                                    : Image.network(
                                        snapshot.data![index].imageurl),
                                // Image.network(
                                //     'https://i.pinimg.com/736x/aa/fc/82/aafc8273fdf09f9a98f8127052e24cb7.jpg'),
                              ],
                            );
                          },
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return Text('${snapshot.data}');
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error} WHAHWHAHA');
                    }
                    return Text('Hey There');
                  },
                ),
              )
            ],
          ),
        )
        );
  }
}
