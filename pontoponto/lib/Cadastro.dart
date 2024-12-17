import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroWidget extends StatefulWidget {
  const CadastroWidget({super.key});

  @override
  State<CadastroWidget> createState() => _CadastroWidgetState();
}

class _CadastroWidgetState extends State<CadastroWidget> {
  // Controladores de texto
  final TextEditingController emailAddressTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  bool passwordVisibility = false; // Controle de visibilidade da senha
  bool passwordConfirmVisibility = false; // Controle de visibilidade da senha

  // Função para exibir mensagens de erro ou sucesso
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Função de cadastro usando Firebase Authentication
  Future<void> signUp() async {
    final email = emailAddressTextController.text;
    final password = passwordTextController.text;
    final passwordConfirm = passwordConfirmController.text;

    if (password != passwordConfirm) {
      showMessage('As senhas não coincidem');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      showMessage('Cadastro realizado com sucesso');
      Navigator.pushNamed(context, '/login'); // Navega para a tela de login
    } catch (e) {
      showMessage('Erro no cadastro: $e');
    }
  }

  @override
  void dispose() {
    emailAddressTextController.dispose();
    passwordTextController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  width: 100.0,
                  height: double.infinity,
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 140.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'PONTO',
                                style: TextStyle(
                                  color: Color(0xFF3D2C8C),
                                  fontSize: 36.0,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF3D2C8C),
                                size: 50.0,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'PONTO',
                                style: TextStyle(
                                  color: Color(0xFF3D2C8C),
                                  fontSize: 36.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: emailAddressTextController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  filled: true,
                                  fillColor: Color(0xFFF1F4F8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: passwordTextController,
                                obscureText: !passwordVisibility,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  filled: true,
                                  fillColor: const Color(0xFFF1F4F8),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordVisibility
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisibility = !passwordVisibility;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: passwordConfirmController,
                                obscureText: !passwordConfirmVisibility,
                                decoration: InputDecoration(
                                  labelText: 'Confirmar',
                                  filled: true,
                                  fillColor: const Color(0xFFF1F4F8),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordConfirmVisibility
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordConfirmVisibility = !passwordConfirmVisibility;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: signUp, // Chama a função de cadastro
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(44),
                                  backgroundColor: const Color(0xFF3D2C8C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Possui uma conta? ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: 'Entre aqui',
                                      style: const TextStyle(
                                        color: Color(0xFF3D2C8C),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(context, '/login');
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }
}