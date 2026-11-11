import 'package:flutter/material.dart';
import 'package:frasesapp/data/frases_db.dart';
import 'package:frasesapp/models/frase.dart';

class FormularioScreen extends StatefulWidget {
  final Frase? frase; // null = nueva, con valor = editar
  const FormularioScreen({super.key, this.frase});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fraseCtrl;
  late final TextEditingController _autorCtrl;
  bool get _esEdicion => widget.frase != null;

  @override
  void initState() {
    super.initState();
    _fraseCtrl = TextEditingController(text: widget.frase?.frase ?? '');
    _autorCtrl = TextEditingController(text: widget.frase?.autor ?? '');
  }

  @override
  void dispose() {
    _fraseCtrl.dispose();
    _autorCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final frase = Frase(
      id: widget.frase?.id,
      frase: _fraseCtrl.text.trim(),
      autor: _autorCtrl.text.trim(),
    );
    if (_esEdicion) {
      await FrasesDb.instancia.actualizar(frase);
    } else {
      await FrasesDb.instancia.insert(frase);
    }
    if (!mounted) return;
    Navigator.pop(context, true); // avisa que se guardó algo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar frase' : 'Nueva frase')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _fraseCtrl,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Frase',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.format_quote),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'Escribe al menos 5 caracteres'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _autorCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Autor',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe el autor' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Guardar frase'),
            ),
          ],
        ),
      ),
    );
  }
}