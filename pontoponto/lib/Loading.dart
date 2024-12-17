import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  void initState() {
    super.initState();

    // Atraso de 5 segundos antes de redirecionar para a tela de login
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF3D2C8C),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 0.0),
                child: Container(
                  width: double.infinity,
                  height: 100.0,
                  decoration: const BoxDecoration(),
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: const BoxDecoration(),
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: const Text(
                          'PONTO',
                          style: TextStyle(
                              fontSize: 44, // Tamanho da fonte
                              color: Color(0xFFEDEDED), // Cor do texto
                              letterSpacing: 0.0,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.1,
                        height: MediaQuery.sizeOf(context).width * 0.1,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3D2C8C),
                          shape: BoxShape.circle,
                        ),
                        child: Lottie.network(
                          'https://lottie.host/2f8f1e7b-15fd-4352-8612-280d476e39ba/ndRtcuAAwc.json',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.contain,
                          animate: true,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(),
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: const Text(
                          'PONTO',
                          style: TextStyle(
                            fontSize: 44, // Tamanho da fonte
                            color: Color(0xFFEDEDED), // Cor do texto
                            letterSpacing: 0.0,
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
      ),
    );
  }
}