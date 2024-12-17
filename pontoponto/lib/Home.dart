import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeWidget extends StatefulWidget {
  final String email;
  final String userId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  HomeWidget({super.key, required this.email, required this.userId});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  DateTime? lastPoint;
  Duration workedToday = Duration.zero;
  List<Map<String, dynamic>> recentPoints = [];

  // Função para registrar o ponto
  void _registerPoint(String pointType) async {
    setState(() {
      lastPoint = DateTime.now();
    });

    await widget.firestore.collection('pontos').add({
      'userId': widget.userId,
      'email': widget.email,
      'tipo': pointType,
      'dataHora': Timestamp.now(),
    }).then((value) {
      print('Ponto salvo com ID: ${value.id}');
      _loadRecentPoints();
    }).catchError((error) {
      print('Erro ao salvar ponto: $error');
    });
  }

  // Exibe o pop-up para selecionar o tipo de ponto
  void _showPointDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Ponto'),
          content: const Text('Selecione o tipo de ponto que deseja registrar:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o pop-up
                _registerPoint("Entrada");
              },
              child: const Text('Entrada'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o pop-up
                _registerPoint("Saída");
              },
              child: const Text('Saída'),
            ),
          ],
        );
      },
    );
  }

  // Função para carregar os últimos pontos do usuário
  void _loadRecentPoints() async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    QuerySnapshot querySnapshot = await widget.firestore
        .collection('pontos')
        .where('userId', isEqualTo: widget.userId)
        .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(todayMidnight))
        .orderBy('dataHora', descending: true)
        .get();

    setState(() {
      recentPoints = querySnapshot.docs
        .map((doc) => {
          'tipo': doc['tipo'],
          'dataHora': (doc['dataHora'] as Timestamp).toDate(),
        })
        .toList();

      _calculateWorkedTime();
    });
  }

  // Função para calcular o tempo trabalhado hoje
  void _calculateWorkedTime() {
    workedToday = Duration.zero;
    DateTime? lastEntry;

    for (var point in recentPoints.reversed) {
      if (point['tipo'] == 'Entrada') {
        lastEntry = point['dataHora'];
      } else if (point['tipo'] == 'Saída' && lastEntry != null) {
        workedToday += point['dataHora'].difference(lastEntry);
        lastEntry = null;
      }
    }
    print("Horas trabalhadas hoje: $workedToday");
  }

  @override
  void initState() {
    super.initState();
    _loadRecentPoints();
  }

  @override
  Widget build(BuildContext context) {
    final String displayDateTime = lastPoint != null
        ? DateFormat('dd \'de\' MMMM, yyyy – HH:mm').format(lastPoint!)
        : 'Nenhum ponto registrado ainda';
    final String workedHours = "${workedToday.inHours}:${(workedToday.inMinutes % 60).toString().padLeft(2, '0')}";

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 3.0, 0.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Olá, ${widget.email}!',
                              style: const TextStyle(
                                fontSize: 28.0,
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Material(
                              color: Colors.transparent,
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 300.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F4F8),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        displayDateTime,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(75.0),
                                        ),
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3D2C8C),
                                            borderRadius: BorderRadius.circular(75.0),
                                          ),
                                          child: IconButton(
                                            iconSize: 80.0,
                                            icon: const Icon(
                                              Icons.fingerprint,
                                              color: Colors.white,
                                            ),
                                            onPressed: _showPointDialog,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Horas trabalhadas hoje: $workedHours',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Card de Últimos Registros
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F4F8),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Últimos Registros',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3D2C8C),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      SizedBox(
                                        height: 190.0,
                                        child: ListView.builder(
                                          itemCount: recentPoints.length,
                                          itemBuilder: (context, index) {
                                            final point = recentPoints[index];
                                            final isEntry = point['tipo'] == 'Entrada';
                                            return ListTile(
                                              title: Text(
                                                point['tipo'],
                                                style: TextStyle(
                                                  color: isEntry ? Colors.green : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                DateFormat('dd/MM/yyyy – HH:mm').format(point['dataHora']),
                                              ),
                                            );
                                          },
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
                    Material(
                      color: Colors.transparent,
                      elevation: 8.0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 65.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F4F8),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/calendario'),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF3D2C8C),
                                  size: 28.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/access'),
                                child: const Icon(
                                  Icons.lock,
                                  color: Color(0xFF3D2C8C),
                                  size: 28.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/notes'),
                                child: const Icon(
                                  Icons.note,
                                  color: Color(0xFF3D2C8C),
                                  size: 28.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/menu'),
                                child: const Icon(
                                  Icons.menu,
                                  color: Color(0xFF3D2C8C),
                                  size: 28.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}