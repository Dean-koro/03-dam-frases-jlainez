import 'package:flutter/material.dart';
import 'package:frasesapp/data/frases_db.dart';
import 'package:frasesapp/models/frase.dart';
import 'package:frasesapp/screens/formulario_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = FrasesDb.instancia;
  List<Frase> _frases = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // pide las frases a la bd y crea la pantalla.
  Future<void> _cargar() async {
    final lista = await _db.obtenerTodas();
    if (!mounted) return;
    setState(() {
      _frases = lista;
      _cargando = false;
    });
  }

  Future<void> _abrirFormulario([Frase? existente]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormularioScreen(frase: existente)),
    );
    if (guardado == true) {
      await _cargar();
    }
  }

  Future<void> _confirmarEliminar(Frase frase) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar frase'),
        content: Text('¿Eliminar la frase de "${frase.autor}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await _db.eliminar(frase.id!);
    await _cargar();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Frase eliminada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis frases (${_frases.length})')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: _cuerpo(),
    );
  }

  Widget _cuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_frases.isEmpty) {
      return const Center(
        child: Text(
          'Aún no hay frases.\nToca + para agregar la primera.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: _frases.length,
      itemBuilder: (context, i) {
        final f = _frases[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            onTap: () => _abrirFormulario(f),
            title: Text(
              '"${f.frase}"',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            subtitle: Text('- ${f.autor}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
              onPressed: () => _confirmarEliminar(f),
            ),
          ),
        );
      },
    );
  }
}