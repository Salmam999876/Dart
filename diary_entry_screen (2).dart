// lib/screens/diary_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Import flutter_quill
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart'; // Import for FlutterQuillEmbeds
import '../font_provider.dart';
import '../font_picker_page.dart';
import '../models/diary_entry.dart'; // Import DiaryEntry
import '../services/diary_service.dart'; // Import DiaryService
import 'package:uuid/uuid.dart'; // Import Uuid
import 'package:image_picker/image_picker.dart'; // For image upload
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'; // For emoji picker
import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import kIsWeb
class DiaryEntryScreen extends StatefulWidget {
  final DiaryEntry? entry;
  final DiaryService diaryService;

  const DiaryEntryScreen({super.key, this.entry, required this.diaryService});

  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  final Uuid _uuid = const Uuid();
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    if (widget.entry != null && widget.entry!.content.isNotEmpty) {
      try {
        final doc = Document.fromJson(jsonDecode(widget.entry!.content));
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Fallback for old plain text content or malformed JSON
        _quillController = QuillController(
          document: Document()..insert(0, widget.entry!.content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCalendar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            child: TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
                Navigator.pop(context);
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final String imagePath = image.path;
      final int index = _quillController.selection.baseOffset;
      final length = _quillController.selection.extentOffset - index;
      _quillController.document.replace(
        index,
        length,
        BlockEmbed.image(imagePath),
      );
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _quillController.document.insert(_quillController.selection.end, emoji.emoji);
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            _onEmojiSelected(emoji);
            Navigator.pop(context);
          },
          config: const Config(),
        ),
      ),
    );
  }

  void _insertBulletPoint() {
    _quillController.formatSelection(Attribute.ul);
  }

  void _insertHashTag() {
    _quillController.document.insert(_quillController.selection.end, '#');
  }

  @override
  Widget build(BuildContext context) {
    final fontName = Provider.of<FontProvider>(context).selectedFont;
    final fontStyle = GoogleFonts.getFont(fontName);

    return Scaffold(
      backgroundColor: Colors.pink.shade50, // Soft pink background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Bar: Back, Date, Down Arrow, Save Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showCalendar,
                      child: Row(
                        // Changed to Row for date and down arrow
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                            style: fontStyle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onPressed: () {
                              Navigator.pop(context); // Close the page
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.entry == null) {
                        // Add new entry
                        widget.diaryService.addEntry(
                          _titleController.text,
                          jsonEncode(_quillController.document.toDelta().toJson()), // Save as JSON
                          _selectedDate,
                        );
                      } else {
                        // Update existing entry
                        widget.diaryService.updateEntry(
                          widget.entry!.id!, // ID is guaranteed to be non-null for existing entries
                          _titleController.text,
                          jsonEncode(_quillController.document.toDelta().toJson()), // Save as JSON
                          _selectedDate,
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diary entry saved!')),
                      );
                      Navigator.pop(context); // Go back after saving
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title Text Field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: GoogleFonts.dancingScript(
                      color: Colors.grey.shade400, fontSize: 22),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.dancingScript(
                    fontSize: 22,
                    fontWeight: FontWeight.bold), // Apply Dancing Script
              ),
              const Divider(color: Colors.pinkAccent),
              const SizedBox(height: 10),

              // Quill Toolbar
              QuillToolbar.basic(
                controller: _quillController,
                toolbarSectionSpacing: 4,
                toolbarIconSize: 24,
                toolbarIconAlignment: WrapAlignment.start,
                showImageButton: false, // We'll handle image picking separately
                showVideoButton: false,
                showCameraButton: false,
                multiRowsDisplay: false,
                customButtons: [
                  QuillToolbarCustomButton(
                    controller: _quillController, // Add controller here
                    options: QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.font_download),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FontPickerPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Content Text Field (QuillEditor)
              Expanded(
                child: QuillEditor.basic(
                  controller: _quillController,
                  scrollController: _scrollController,
                  focusNode: _focusNode,
                  readOnly: false,
                  expands: true,
                  padding: EdgeInsets.zero,
                  autoFocus: false,
                  scrollable: true,
                  embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.pink.shade100,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Removed image button as it's handled by QuillToolbar
              IconButton(
                icon: const Icon(Icons.emoji_emotions),
                onPressed: _showEmojiPicker,
              ),
              IconButton(
                icon: const Icon(Icons.tag),
                onPressed: _insertHashTag,
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: _insertBulletPoint,
              ),
              // Removed font_download button as it's handled by QuillToolbar
            ],
          ),
        ),
      ),
    );
  }
}
