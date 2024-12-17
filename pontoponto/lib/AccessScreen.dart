import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart'; // Import Realtime Database

class AccessScreen extends StatefulWidget {
  @override
  _AccessScreenState createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  String dynamicCode = "000000"; // Código inicial
  int timeRemaining = 30; // Tempo restante para expirar o código
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateCode(); // Gera o primeiro código
    _startTimer(); // Inicia o timer
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o timer quando a tela for descartada
    super.dispose();
  }

  void _generateCode() async {
    // Chave secreta para o TOTP (pode ser gerada dinamicamente)
    const String secretKey = "MY_SECRET_KEY";
    setState(() {
      dynamicCode = OTP.generateTOTPCodeString(
        secretKey,
        DateTime.now().millisecondsSinceEpoch,
        interval: 30,
      );
    });

    // Envia o código gerado para o Firebase Realtime Database
    await _sendCodeToRealtimeDatabase(dynamicCode);
  }

  Future<void> _sendCodeToRealtimeDatabase(String code) async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref();

      // Salva o código no Firebase Realtime Database
      await databaseReference.child('accessCodes/currentCode').set({
        'code': code,
        'timestamp': DateTime.now().toString(), // Adiciona o horário de geração
      });

      print("Código salvo no Firebase Realtime Database com sucesso!");
    } catch (e) {
      print("Erro ao salvar código no Firebase Realtime Database: $e");
    }
  }

  void _startTimer() {
    // Cria um timer que executa a cada segundo
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
        if (timeRemaining <= 0) {
          _generateCode(); // Gera um novo código
          timeRemaining = 30; // Reseta o tempo
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Acesso",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3D2C8C),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Código de Acesso:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              dynamicCode,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              "Expira em: $timeRemaining segundos",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
