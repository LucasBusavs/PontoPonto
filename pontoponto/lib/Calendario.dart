import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalenWidget extends StatefulWidget {
  final String userId;

  const CalenWidget({super.key, required this.userId});

  @override
  State<CalenWidget> createState() => _CalenWidgetState();
}

class _CalenWidgetState extends State<CalenWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, int> recordsPerDay = {};
  Duration totalMonthHours = Duration.zero;
  int workedDays = 0;
  int pendingDays = 0;
  int noWorkDays = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthlyData();
    });
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _loadMonthlyData() async {
    DateTime firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('pontos')
        .where('userId', isEqualTo: widget.userId)
        .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .where('dataHora', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
        .orderBy('dataHora')
        .get();

    Map<DateTime, int> tempRecordsPerDay = {};
    Duration tempTotalMonthHours = Duration.zero;
    DateTime? lastEntry;

    for (var doc in snapshot.docs) {
      DateTime pointTime = (doc['dataHora'] as Timestamp).toDate();
      DateTime day = _normalizeDate(pointTime);
      String pointType = doc['tipo'];

      if (tempRecordsPerDay.containsKey(day)) {
        tempRecordsPerDay[day] = tempRecordsPerDay[day]! + 1;
      } else {
        tempRecordsPerDay[day] = 1;
      }

      if (pointType == "Entrada") {
        lastEntry = pointTime;
      } else if (pointType == "Saída" && lastEntry != null) {
        Duration workedDuration = pointTime.difference(lastEntry);
        tempTotalMonthHours += workedDuration;
        lastEntry = null;
      }
    }

    if (mounted) {
      setState(() {
        recordsPerDay = tempRecordsPerDay;
        totalMonthHours = tempTotalMonthHours;
        _calculateSummary();
      });
    }
  }

  void _calculateSummary() {
    workedDays = recordsPerDay.entries.where((e) => e.value >= 4).length;
    pendingDays = recordsPerDay.entries.where((e) => e.value == 2).length;

    int totalDaysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    noWorkDays = totalDaysInMonth - workedDays - pendingDays;
  }

  Color _getDayColor(DateTime day) {
    int? recordCount = recordsPerDay[_normalizeDate(day)];
    if (recordCount == null) {
      return Colors.red;
    } else if (recordCount < 4) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  void _showDayRecords(DateTime day) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('pontos')
        .where('userId', isEqualTo: widget.userId)
        .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(day))
        .where('dataHora', isLessThanOrEqualTo: Timestamp.fromDate(day.add(Duration(days: 1))))
        .orderBy('dataHora')
        .get();

    List<QueryDocumentSnapshot> records = snapshot.docs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Registros de ${DateFormat('dd/MM/yyyy').format(day)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      var record = records[index];
                      DateTime recordTime = (record['dataHora'] as Timestamp).toDate();
                      String recordType = record['tipo'];

                      return ListTile(
                        title: Text(
                          '$recordType - ${DateFormat.Hm().format(recordTime)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await record.reference.delete();
                            _loadMonthlyData();
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                ElevatedButton(
                  onPressed: () => _addNewRecord(day),
                  child: const Text("Adicionar Novo Registro"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNewRecord(DateTime day) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      DateTime newPointTime = DateTime(day.year, day.month, day.day, selectedTime.hour, selectedTime.minute);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Selecione o Tipo de Registro"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('pontos').add({
                    'userId': widget.userId,
                    'dataHora': Timestamp.fromDate(newPointTime),
                    'tipo': 'Entrada',
                  });
                  _loadMonthlyData();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Entrada"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('pontos').add({
                    'userId': widget.userId,
                    'dataHora': Timestamp.fromDate(newPointTime),
                    'tipo': 'Saída',
                  });
                  _loadMonthlyData();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Saída"),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String totalHoursString =
        "${totalMonthHours.inHours}:${(totalMonthHours.inMinutes % 60).toString().padLeft(2, '0')}";

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              "Calendário de Pontos",
                  style: TextStyle(
                    color: Colors.white,
                  ),
          ),
          backgroundColor: const Color(0xFF3D2C8C),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  color: Colors.transparent,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 350,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F4F8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                if (selectedDay.isBefore(DateTime.now()) || isSameDay(selectedDay, DateTime.now())) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                    _showDayRecords(selectedDay);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Você só pode editar dias passados."),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  if (day.isAfter(DateTime.now())) {
                                    // Dias futuros sem cores
                                    return Container(
                                      margin: const EdgeInsets.all(6.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  } else if (day.month == _focusedDay.month) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getDayColor(day),
                                      ),
                                      margin: const EdgeInsets.all(6.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                              calendarStyle: const CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                  color: Color(0xFF3D2C8C),
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: Color(0xFFEDEDED),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Card de Resumo do Mês
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Resumo do Mês',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3D2C8C),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 20,
                                  runSpacing: 10,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Dias Trabalhados: $workedDays'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Dias Pendentes: $pendingDays'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Dias Não Trabalhados: $noWorkDays'),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text(
                                      'Horas Trabalhadas: ',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      totalHoursString,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF3D2C8C),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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