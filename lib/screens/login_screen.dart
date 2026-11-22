import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /*
    Dados para entrar no sistema
    email: lilia@teste.com  | Senha: senha123
  */
  final _email = TextEditingController();
  final _senha = TextEditingController();
  User? _usuario;

  Future<void> _entrarComGoogle() async {
    try {
      late final UserCredential resultado;

      if (kIsWeb) {
        resultado = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();

        final conta = await googleSignIn.authenticate();
        final credencial = GoogleAuthProvider.credential(idToken: conta.authentication.idToken);

        resultado = await FirebaseAuth.instance.signInWithCredential(
          credencial,
        );
      }

      if (!mounted) return;
      setState(() => _usuario = resultado.user);

      //Se o login com o Google deu certo, vai para a tela Home
      if (_usuario != null) {
        Navigator.pushNamed(context, 'home');
      }
    } catch (e) {
      debugPrint('Erro ao autenticar: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar com o Google')),
      );
    }
  }

   Future<void> _sair() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
    setState(() => _usuario = null);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      //Consumer vai ler/ouvir o controller de Autenticação
      body: Consumer<AuthController>(
        builder: (context, controleAuth, _) => Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _email,
                decoration: InputDecoration(labelText: "E-mail"),
              ),
              TextField(
                controller: _senha,
                obscureText: true, //Esconde a senha
                decoration: InputDecoration(labelText: "Senha"),
              ),
              SizedBox(height: 16),
              //Fica vazio se não tiver erro
              Text(controleAuth.erro), 
              ElevatedButton(
                onPressed: () async {
                  //Tentar logar
                  final logou = await controleAuth.autenticarUsuario(_email.text, _senha.text);
                  if (logou && context.mounted) {
                    //pushNamed -> cria uma "setinha" que te permite voltar a tela anterior
                    Navigator.pushNamed(context, 'home');
                  }
                },
                child: Text("Entrar"),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _entrarComGoogle,
                icon: const Icon(Icons.login),
                label: const Text('Entrar com o Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}