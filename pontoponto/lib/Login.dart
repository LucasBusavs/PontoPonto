import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  // Controladores de texto
  final TextEditingController emailAddressTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  bool passwordVisibility = false; // Controle de visibilidade da senha
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage; // Para armazenar mensagens de erro

  // Função para validação simples de e-mail
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite um email válido';
    }
    return null;
  }

  // Função para login
  Future<void> _login() async {
    if (validateEmail(emailAddressTextController.text) != null) {
      // Se o e-mail for inválido, não prosseguir
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailAddressTextController.text,
        password: passwordTextController.text,
      );

      // Verifique se userCredential.user não é nulo e obtenha o uid
      final userId = userCredential.user?.uid;

      if (userId != null) {
        // Manda o userId para o model
        Provider.of<UserModel>(context, listen: false).setUserId(userId);
        // Navegando para a Home
        Navigator.pushReplacementNamed(context, '/home', arguments: userId);
      } else {
        print("Erro: UID do usuário não encontrado.");
      }
    } catch (e) {
      print("Erro ao fazer login: $e");
    }
  }

  @override
  void dispose() {
    emailAddressTextController.dispose();
    passwordTextController.dispose();
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
                        Container(
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
                                validator: validateEmail,
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
                              if (_errorMessage != null) // Exibir a mensagem de erro se existir
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ElevatedButton(
                                onPressed: _login, // Chama a função de login
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(44),
                                  backgroundColor: const Color(0xFF3D2C8C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text(
                                  'Entrar',
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
                                      text: 'Não possui uma conta? ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: 'Cadastre aqui',
                                      style: const TextStyle(
                                        color: Color(0xFF3D2C8C),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(context, '/cadastro');
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