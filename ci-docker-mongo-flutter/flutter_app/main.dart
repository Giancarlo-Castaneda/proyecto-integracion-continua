import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mongo + FastAPI + Flutter',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _message = 'Cargando...';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMessage();
  }

  Future<void> _fetchMessage() async {
    try {
      final res = await http.get(Uri.parse('/api/message'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _message = data['message'] ?? '';
        });
      } else {
        setState(() {
          _message = 'Error al consultar el backend (${res.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _saveMessage() async {
    try {
      final res = await http.post(
        Uri.parse('/api/message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': _controller.text}),
      );
      if (res.statusCode == 200) {
        _controller.clear();
        _fetchMessage();
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensaje desde MongoDB')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mensaje actual:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_message, style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nuevo mensaje',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveMessage(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveMessage,
                  child: const Text('Guardar en MongoDB'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _fetchMessage,
                  child: const Text('Refrescar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}