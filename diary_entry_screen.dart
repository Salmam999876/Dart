import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class DiaryEntryScreen extends StatefulWidget {
  const DiaryEntryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  late QuillController _controller;


@override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Diary Entry'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: QuillEditor.basic(
                controller: _controller,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: QuillToolbar.basic(
        controller: _controller,
        showAlignmentButtons: true,
        showFontFamily: true,
        showFontSize: true,
        showColorButton: true,
        showBackgroundColorButton: true,
        showListNumbers: true,
        showListBullets: true,
        showCodeBlock: true,
        showQuote: true,
        showIndent: true,
        showLink: true,
        showSearchButton: true,
        showUndo: true,
        showRedo: true,
        showDirection: true,
        showClearFormat: true,
        showStrikeThrough: true,
        showInlineCode: true,
        showSubscript: true,
        showSuperscript: true,
        showSmallButton: true,
        showItalicButton: true,
        showUnderLineButton: true,
        showBoldButton: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement saving the diary entry
          print('Saving entry: ${_controller.document.toPlainText()}');
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
