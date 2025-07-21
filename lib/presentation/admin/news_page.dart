import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsPage extends StatefulWidget {
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _newsList = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final response = await Supabase.instance.client.from('news').select();
    setState(() {
      _newsList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addNews() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.from('news').insert({'text': text});
      _controller.clear();
      await _fetchNews();
    } catch (e) {
      setState(() {
        _error = 'Failed to add news.';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _deleteNews(int id) async {
    await Supabase.instance.client.from('news').delete().eq('id', id);
    await _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage News'),
        backgroundColor: const Color.fromARGB(255, 238, 219, 111),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add News',
                errorText: _error,
                suffixIcon: IconButton(
                  icon:
                      _loading ? CircularProgressIndicator() : Icon(Icons.send),
                  onPressed: _loading ? null : _addNews,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _newsList.length,
                itemBuilder: (context, index) {
                  final news = _newsList[index];
                  return Card(
                    child: ListTile(
                      title: Text(news['text'] ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNews(news['id'] as int),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
