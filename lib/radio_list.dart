import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'mylist.dart';
import 'song_list.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class RadioListPage extends StatefulWidget {
  @override
  _RadioListPageState createState() => _RadioListPageState();
}

class _RadioListPageState extends State<RadioListPage> {
  List<List<dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  void _loadCSV() async {
    final rawData = await rootBundle.loadString('assets/radio_list.csv');
    List<List<dynamic>> listData = CsvToListConverter().convert(rawData);
    setState(() {
      _data = listData;
    });
  }

  void _goToMyListPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyListPage()),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('방송 리스트'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: user != null
          ? _data.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _data.length - 1, // 첫 번째 행은 헤더이므로 제외
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.radio),
                      title: Text(_data[index + 1][0]), // 제목
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('날짜: ${_data[index + 1][1]}'),
                          Text('게스트: ${_data[index + 1][2]}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SongListPage(date: _data[index + 1][1]),
                          ),
                        );
                      },
                    );
                  },
                )
          : Center(child: Text('로그인이 필요합니다.')),
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
            _goToMyListPage();
          }
        },
      ),
    );
  }
}



