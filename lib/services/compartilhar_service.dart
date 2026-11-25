/*
  share_plus   -> Abre o menu de compartilhamento NATIVO do celular
  (WhatsApp, E-mail, Telegram, SMS, etc).
  url_launcher -> Abre um link "mailto:" que vai DIRETO para o app de e-mail
  (Gmail, Outlook...) com assunto e texto já preenchidos.
*/
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/*
  Representa O QUE vai ser compartilhado (assunto + texto).
  Assim o mesmo conteúdo pode ir pelo menu nativo OU direto por e-mail.
*/
class Conteudo {
  final String assunto;
  final String corpo;
  Conteudo(this.assunto, this.corpo);
}

class CompartilharService {
  static const String _assinatura = 'Enviado pelo app Guia Turismo';

  /*
    Gera um link do Google Maps com a coordenada.
    Qualquer pessoa que receber consegue abrir, mesmo sem ter o nosso app.
  */
  String linkMapa(num latitude, num longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  /*
    No iPad o menu de compartilhamento abre como um "balão" e precisa saber
    de onde ele sai (posição do botão). No Android isso é ignorado.
  */
  Rect? origem(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  //Texto de um estabelecimento/lugar cadastrado
  Conteudo conteudoLugar(LugaresModel lugar) {
    final texto = StringBuffer()..writeln(' ${lugar.nome}');
    if ((lugar.categoria ?? '').isNotEmpty) {
      texto.writeln('Categoria: ${lugar.categoria}');
    }
    if ((lugar.descricao ?? '').isNotEmpty) {
      texto.writeln(lugar.descricao);
    }
    texto
      ..writeln()
      ..writeln('Ver no mapa: ${linkMapa(lugar.latitude, lugar.longitude)}')
      ..writeln()
      ..write(_assinatura);
    return Conteudo('Conheça: ${lugar.nome}', texto.toString());
  }

  //Texto de uma localização qualquer (ex: onde o usuário está agora)
  Conteudo conteudoLocalizacao(LatLng ponto, {String titulo = 'Minha localização'}) {
    return Conteudo(
      titulo,
      '$titulo\n${linkMapa(ponto.latitude, ponto.longitude)}\n\n$_assinatura',
    );
  }

  //Texto da avaliação (nota de 1 a 5 + comentário) de um lugar
  Conteudo conteudoAvaliacao(LugaresModel lugar, int nota, String comentario) {
    //Monta as estrelas: nota 4 = ★★★★☆
    final estrelas = '★' * nota + '☆' * (5 - nota);
    final texto = StringBuffer()
      ..writeln('Minha avaliação de ${lugar.nome}')
      ..writeln('$estrelas ($nota/5)');
    if (comentario.trim().isNotEmpty) {
      texto.writeln('"${comentario.trim()}"');
    }
    texto
      ..writeln()
      ..writeln('Ver no mapa: ${linkMapa(lugar.latitude, lugar.longitude)}')
      ..writeln()
      ..write(_assinatura);
    return Conteudo('Avaliação: ${lugar.nome}', texto.toString());
  }

  //Menu nativo: o usuário escolhe o app (WhatsApp, E-mail, etc)
  Future<ShareResult> compartilhar(Conteudo conteudo, {Rect? origem}) {
    return SharePlus.instance.share(ShareParams(
      text: conteudo.corpo,
      subject: conteudo.assunto, //Vira o assunto quando o app escolhido é de e-mail
      sharePositionOrigin: origem,
    ));
  }

  /*
    Tenta abrir DIRETO o app de e-mail com assunto e corpo preenchidos.
    Se o celular não tiver app de e-mail, cai no menu nativo (plano B).
    Retorna true se conseguiu abrir o e-mail.
  */
  Future<bool> enviarPorEmail(Conteudo conteudo, {String destinatario = '', Rect? origem}) async {
  
      //uri.encodeComponent deixa o texto em formato compativel com url

    final link = Uri.parse(
      'mailto:$destinatario'
      '?subject=${Uri.encodeComponent(conteudo.assunto)}'
      '&body=${Uri.encodeComponent(conteudo.corpo)}',
    );
    try {
      if (await launchUrl(link)) return true;
    } catch (e) {
      debugPrint('Não abriu o e-mail: $e');
    }
    //Plano B: menu nativo, o assunto continua indo junto
    await compartilhar(conteudo, origem: origem);
    return false;
  }

  /*
    Foto: o "mailto:" não aceita anexo, então a foto sempre vai pelo menu nativo.
    O assunto vai junto, então se o usuário escolher Gmail/Outlook já chega
    com assunto + anexo.
  */
  Future<ShareResult> compartilharFoto(File foto, {String? legenda, Rect? origem}) {
    return SharePlus.instance.share(ShareParams(
      files: [XFile(foto.path)],
      text: legenda,
      subject: 'Foto - Guia Turismo',
      sharePositionOrigin: origem,
    ));
  }
}
