import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'youtube_video_page.dart';

class MyListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('나만의 플레이리스트'),
        ),
        body: Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('나만의 플레이리스트'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('users').doc(user!.uid).collection('likes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final likes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: likes.length,
            itemBuilder: (context, index) {
              final like = likes[index];
              final data = like.data() as Map<String, dynamic>;
              final title = data['title'];
              final artist = data['artist'];
              final youtubeUrl = data.containsKey('youtubeUrl') ? data['youtubeUrl'] : ''; // YouTube URL 가져오기

              return ListTile(
                title: Text(title),
                subtitle: Text(artist),
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
                      SnackBar(content: Text('유효한 YouTube URL이 없습니다.')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}





/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('나만의 플레이리스트'),
        ),
        body: Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('나만의 플레이리스트'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('users').doc(user!.uid).collection('likes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final likes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: likes.length,
            itemBuilder: (context, index) {
              final like = likes[index];
              return ListTile(
                title: Text(like['title']),
                subtitle: Text(like['artist']),
              );
            },
          );
        },
      ),
    );
  }
}*/