import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class DiaryEntryScreen extends StatefulWidget {
  final DateTime? initialDate;

  const DiaryEntryScreen({Key? key, this.initialDate}) : super(key: key);

  @override
  _DiaryEntryScreenState createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _showCalendar = false;
  late QuillController _quillController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    _quillController = QuillController.basic();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final title = _titleController.text;
    final content = _quillController.document.toPlainText(); // Get content from Quill editor
    print('Title: $title');
    print('Date: $_selectedDate');
    print('Content: $content');
    // You would typically save this to a database or file
  }

  void _showDatePicker() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _showCalendar = false; // Close calendar after selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return QuillSharedConfigurations(
      configurations: QuillConfigurations(
        embedBuilders: [
          ...FlutterQuillEmbeds.editorBuilders(),
        ],
      ),
      child: Scaffold(
        backgroundColor: Colors.pink[50], // Soft pink background
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: Row(
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.black),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[300], // Pink button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showCalendar)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2050, 12, 31),
                    focusedDay: _selectedDate,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: _onDaySelected,
                    calendarFormat: CalendarFormat.month,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.pink[300],
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.pink[100],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: GoogleFonts.dancingScript(
                            fontSize: 24,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.dancingScript(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: QuillEditor.basic(
                            controller: _quillController,
                            focusNode: _focusNode,
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                          ),
                        ),
                      ),
                      // Add QuillToolbar here
                      QuillToolbar.basic(
                        controller: _quillController,
                        showAlignmentButtons: true,
                        showBackgroundColorButton: true,
                        showBoldButton: true,
                        showCenterAlignment: true,
                        showClearFormat: true,
                        showCodeBlock: true,
                        showColorButton: true,
                        showDirection: true,
                        showFontFamily: true,
                        showFontSize: true,
                        showFormulaButton: true,
                        showIndent: true,
                        showInlineCode: true,
                        showItalicButton: true,
                        showJustifyAlignment: true,
                        showLeftAlignment: true,
                        showLink: true,
                        showListCheck: true,
                        showListNumbers: true,
                        showListBullets: true,
                        showQuote: true,
                        showRedo: true,
                        showRightAlignment: true,
                        showSearchButton: true,
                        showSmallButton: true,
                        showStrikeThrough: true,
                        showSubscript: true,
                        showSuperscript: true,
                        showUnderLine: true,
                        showUndo: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
