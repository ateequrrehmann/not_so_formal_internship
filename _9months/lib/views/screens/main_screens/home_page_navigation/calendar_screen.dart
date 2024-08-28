import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  final String phone;
  const CalendarScreen({super.key, required this.phone});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<String> _notes = [];
  final TextEditingController _noteController = TextEditingController();
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _notes=[];
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9EBEB),
      appBar: AppBar(
        title: Text('Calendar'),
        backgroundColor: Color(0xFFE9EBEB),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFFEC407A),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Colors.white,
                ),
                selectedTextStyle: TextStyle(
                  color: Colors.white,
                ),
                markerDecoration: BoxDecoration(
                  color: Color(0xFFEC407A),
                  shape: BoxShape.circle,
                ),
              ),
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _notes=[];
                  _loadNotes();
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _events[day] ?? [];
              },
            ),
            if (_selectedDay != null) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // just update the note input
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _saveNote,
                child: Text('Save Note'),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index]),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveNote() async {
    if (_selectedDay != null && _noteController.text.isNotEmpty) {
      // Append the new note to the list
      _notes.add(_noteController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phone)
          .collection('notes')
          .doc(_selectedDay.toString())
          .set({
        'date': _selectedDay.toString(),
        'notes': _notes,
      });

      setState(() {
        _noteController.clear();
        _loadNotes();
      });
    }
  }

  void _loadNotes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.phone)
        .collection('notes')
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _events = {};
        for (var doc in snapshot.docs) {
          DateTime date = DateTime.parse(doc.id);
          List<dynamic> notes = List<String>.from(doc['notes']);
          _events[date] = notes;
        }

        if (_selectedDay != null && _events[_selectedDay]!=null) {
          _notes = _events[_selectedDay] as List<String> ?? [];
        } else {
          _notes = [];
        }
      });
    } else {
      setState(() {
        _notes = [];
        _events = {};
      });
    }
  }
}
