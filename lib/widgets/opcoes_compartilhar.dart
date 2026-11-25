import 'package:flutter/material.dart';
import 'package:guia_turismo/services/compartilhar_service.dart';

/*
  - "Enviar por E-mail"  -> abre direto o app de e-mail
  - "Outros apps" -> abre o menu nativo (WhatsApp, Telegram, etc)
*/
void mostrarOpcoesCompartilhar(BuildContext context, Conteudo conteudo) {
  final servico = CompartilharService();
  //Guardado antes de abrir o menu, pq o context do menu some quando ele fecha
  final mensageiro = ScaffoldMessenger.of(context);

  showModalBottomSheet(
    context: context,
    builder: (notificacaoEmail) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            title: Text("Compartilhar", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(conteudo.assunto),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Enviar por E-mail"),
            onTap: () async {
              final origem = servico.origem(notificacaoEmail);
              Navigator.pop(notificacaoEmail);
              final abriuEmail = await servico.enviarPorEmail(conteudo, origem: origem);
              //Avisa o usuário quando caiu no plano B
              if (!abriuEmail) {
                mensageiro.showSnackBar(SnackBar(
                  content: Text("Nenhum app de e-mail encontrado, escolha outro app"),
                ));
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text("Outros apps"),
            subtitle: Text("WhatsApp, Telegram, SMS..."),
            onTap: () {
              final origem = servico.origem(notificacaoEmail);
              Navigator.pop(notificacaoEmail);
              servico.compartilhar(conteudo, origem: origem);
            },
          ),
        ],
      ),
    ),
  );
}
