import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await DatabaseHelper.instance.fetchAll();
    setState(() {
      notes = data; // Agora armazena o mapa completo com id e conteúdo
    });
  }

  void _addOrEditNoteDialog({int? index}) {
    final note = index != null ? notes[index] : null;
    TextEditingController noteController = TextEditingController(
      text: note?['content'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "Nova Anotação" : "Editar Anotação"),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(hintText: "Escreva sua anotação"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (noteController.text.isNotEmpty) {
                  if (index == null) {
                    await DatabaseHelper.instance.insert(noteController.text);
                  } else {
                    final id = note!['id']; // Ajustar ao ID real no banco
                    await DatabaseHelper.instance.update(id, noteController.text);
                  }
                  _loadNotes();
                  Navigator.of(context).pop();
                }
              },
              child: Text(index == null ? "Adicionar" : "Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Anotações",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF3D2C8C),
          iconTheme: IconThemeData(
            color: Colors.white,
          )
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(note['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _addOrEditNoteDialog(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final id = notes[index]['id'];
                      await DatabaseHelper.instance.delete(id);
                      _loadNotes();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNoteDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFF3D2C8C),
      ),
    );
  }
}