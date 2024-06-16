import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mylist.dart';
import 'youtube_video_page.dart';

class SongListPage extends StatefulWidget {
  final String date;
  SongListPage({required this.date});

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<List<dynamic>> _songs = [];
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, bool> _likedSongs = {};

  @override
  void initState() {
    super.initState();
    _loadCSV(widget.date);
    _loadLikedSongs();
  }

  void _loadCSV(String date) async {
    try {
      final rawData = await rootBundle.loadString('assets/$date.csv');
      List<List<dynamic>> listData = CsvToListConverter().convert(rawData);
      setState(() {
        _songs = listData;
      });
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }

  void _loadLikedSongs() async {
    if (user == null) return;
    final likedSongsSnapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('likes')
        .get();

    setState(() {
      for (var doc in likedSongsSnapshot.docs) {
        final songTitle = doc.data()['title'];
        _likedSongs[songTitle] = true;
      }
    });
  }

  Future<void> _toggleLike(String songTitle, String artist) async {
    if (user == null) return;

    try {
      final songDoc = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('likes')
          .doc('$songTitle-$artist');

      final docSnapshot = await songDoc.get();
      if (docSnapshot.exists) {
        // 좋아요 취소
        await songDoc.delete();
        setState(() {
          _likedSongs[songTitle] = false;
        });
      } else {
        // 좋아요 추가
        await songDoc.set({
          'title': songTitle,
          'artist': artist,
          'date': DateTime.now(), // 날짜 필드 추가
        });
        setState(() {
          _likedSongs[songTitle] = true;
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date} 선곡 리스트'),
      ),
      body: _songs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _songs.length - 1, // 첫 번째 행은 헤더이므로 제외
              itemBuilder: (context, index) {
                final songIndex = _songs[index + 1][0];
                final songTitle = _songs[index + 1][1];
                final artist = _songs[index + 1][2];
                final youtubeUrl = _songs[index + 1].length > 3 ? _songs[index + 1][3] : '';
                final isLiked = _likedSongs[songTitle] ?? false;

                return ListTile(
                  leading: Text('$songIndex'),
                  title: Text(songTitle), // 노래 제목
                  subtitle: Text(artist), // 가수
                  trailing: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: () {
                      _toggleLike(songTitle, artist);
                    },
                  ),
                  onTap: () {
                    if (youtubeUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YouTubeVideoPage(videoUrl: youtubeUrl),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('유효한 유튜브 URL이 없습니다.')),
                      );
                    }
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '방송 리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '나만의 플레이리스트',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyListPage()),
            );
          }
        },
      ),
    );
  }
}




// youtube_player_flutter사용
/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mylist.dart';
import 'youtube_video_page.dart';

class SongListPage extends StatefulWidget {
  final String date;
  SongListPage({required this.date});

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<List<dynamic>> _songs = [];
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, bool> _likedSongs = {};

  @override
  void initState() {
    super.initState();
    _loadCSV(widget.date);
    _loadLikedSongs();
  }

  void _loadCSV(String date) async {
    try {
      final rawData = await rootBundle.loadString('assets/$date.csv');
      List<List<dynamic>> listData = CsvToListConverter().convert(rawData);
      setState(() {
        _songs = listData;
      });
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }

  void _loadLikedSongs() async {
    if (user == null) return;
    final likedSongsSnapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('likes')
        .get();

    setState(() {
      for (var doc in likedSongsSnapshot.docs) {
        final songTitle = doc.data()['title'];
        _likedSongs[songTitle] = true;
      }
    });
  }

  Future<void> _toggleLike(String songTitle, String artist) async {
    if (user == null) return;

    try {
      final songDoc = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('likes')
          .doc('$songTitle-$artist');

      final docSnapshot = await songDoc.get();
      if (docSnapshot.exists) {
        // 좋아요 취소
        await songDoc.delete();
        setState(() {
          _likedSongs[songTitle] = false;
        });
      } else {
        // 좋아요 추가
        await songDoc.set({
          'title': songTitle,
          'artist': artist,
          'date': DateTime.now(), // 날짜 필드 추가
        });
        setState(() {
          _likedSongs[songTitle] = true;
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date} 선곡 리스트'),
      ),
      body: _songs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _songs.length - 1, // 첫 번째 행은 헤더이므로 제외
              itemBuilder: (context, index) {
                final songIndex = _songs[index + 1][0];
                final songTitle = _songs[index + 1][1];
                final artist = _songs[index + 1][2];
                final youtubeUrl = _songs[index + 1].length > 3 ? _songs[index + 1][3] : '';
                final isLiked = _likedSongs[songTitle] ?? false;

                return ListTile(
                  leading: Text('$songIndex'),
                  title: Text(songTitle), // 노래 제목
                  subtitle: Text(artist), // 가수
                  trailing: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: () {
                      _toggleLike(songTitle, artist);
                    },
                  ),
                  onTap: () {
                    if (youtubeUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YouTubeVideoPage(videoUrl: youtubeUrl),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('유효한 유튜브 URL이 없습니다.')),
                      );
                    }
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '방송 리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '나만의 플레이리스트',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyListPage()),
            );
          }
        },
      ),
    );
  }
}*/




/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mylist.dart';
import 'youtube_video_page.dart';

class SongListPage extends StatefulWidget {
  final String date;
  SongListPage({required this.date});

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<List<dynamic>> _songs = [];
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, bool> _likedSongs = {};

  @override
  void initState() {
    super.initState();
    _loadCSV(widget.date);
    _loadLikedSongs();
  }

  void _loadCSV(String date) async {
    final rawData = await rootBundle.loadString('assets/$date.csv');
    List<List<dynamic>> listData = CsvToListConverter().convert(rawData);
    setState(() {
      _songs = listData;
    });
  }

  void _loadLikedSongs() async {
    if (user == null) return;
    final likedSongsSnapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('likes')
        .get();

    setState(() {
      for (var doc in likedSongsSnapshot.docs) {
        final songTitle = doc.data()['title'];
        _likedSongs[songTitle] = true;
      }
    });
  }

  Future<void> _toggleLike(String songTitle, String artist) async {
    if (user == null) return;

    try {
      final songDoc = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('likes')
          .doc('$songTitle-$artist');

      final docSnapshot = await songDoc.get();
      if (docSnapshot.exists) {
        // 좋아요 취소
        await songDoc.delete();
        setState(() {
          _likedSongs[songTitle] = false;
        });
      } else {
        // 좋아요 추가
        await songDoc.set({
          'title': songTitle,
          'artist': artist,
          'date': DateTime.now(), // 날짜 필드 추가
        });
        setState(() {
          _likedSongs[songTitle] = true;
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  void _playYouTubeVideo(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YouTubeVideoPage(videoUrl: videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date} 선곡 리스트'),
      ),
      body: _songs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _songs.length - 1, // 첫 번째 행은 헤더이므로 제외
              itemBuilder: (context, index) {
                final songIndex = _songs[index + 1][0];
                final songTitle = _songs[index + 1][1];
                final artist = _songs[index + 1][2];
                final isLiked = _likedSongs[songTitle] ?? false;
                final videoUrl = _songs[index + 1][3]; // CSV 파일에 비디오 URL 포함

                return ListTile(
                  leading: Text('$songIndex'),
                  title: Text(songTitle), // 노래 제목
                  subtitle: Text(artist), // 가수
                  trailing: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: () {
                      _toggleLike(songTitle, artist);
                    },
                  ),
                  onTap: () {
                    _playYouTubeVideo(videoUrl);
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '방송 리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '나만의 플레이리스트',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyListPage()),
            );
          }
        },
      ),
    );
  }
}*/






/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mylist.dart';

class SongListPage extends StatefulWidget {
  final String date;
  SongListPage({required this.date});

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<List<dynamic>> _songs = [];
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, bool> _likedSongs = {};

  @override
  void initState() {
    super.initState();
    _loadCSV(widget.date);
    _loadLikedSongs();
  }

  void _loadCSV(String date) async {
    final rawData = await rootBundle.loadString('assets/$date.csv');
    List<List<dynamic>> listData = CsvToListConverter().convert(rawData);
    setState(() {
      _songs = listData;
    });
  }

  void _loadLikedSongs() async {
    if (user == null) return;
    final likedSongsSnapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('likes')
        .get();

    setState(() {
      for (var doc in likedSongsSnapshot.docs) {
        final songTitle = doc.data()['title'];
        _likedSongs[songTitle] = true;
      }
    });
  }

  Future<void> _toggleLike(String songTitle, String artist) async {
    if (user == null) return;

    try {
      final songDoc = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('likes')
          .doc('$songTitle-$artist');

      final docSnapshot = await songDoc.get();
      if (docSnapshot.exists) {
        // 좋아요 취소
        await songDoc.delete();
        setState(() {
          _likedSongs[songTitle] = false;
        });
      } else {
        // 좋아요 추가
        await songDoc.set({
          'title': songTitle,
          'artist': artist,
          'date': DateTime.now(), // 날짜 필드 추가
        });
        setState(() {
          _likedSongs[songTitle] = true;
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date} 선곡 리스트'),
      ),
      body: _songs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _songs.length - 1, // 첫 번째 행은 헤더이므로 제외
              itemBuilder: (context, index) {
                final songIndex = _songs[index + 1][0];
                final songTitle = _songs[index + 1][1];
                final artist = _songs[index + 1][2];
                final isLiked = _likedSongs[songTitle] ?? false;

                return ListTile(
                  leading: Text('$songIndex'),
                  title: Text(songTitle), // 노래 제목
                  subtitle: Text(artist), // 가수
                  trailing: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: () {
                      _toggleLike(songTitle, artist);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '방송 리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '나만의 플레이리스트',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyListPage()),
            );
          }
        },
      ),
    );
  }
}
*/


