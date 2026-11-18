import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: substitua pela URL oficial do stream fornecida pela rádio.
const streamUrl = 'COLE_AQUI_A_URL_OFICIAL_DO_STREAM';

// Informe o WhatsApp da rádio com código do país + DDD + número.
// Exemplo fictício: 5511999999999 (somente números).
const numeroWhatsAppRadio = 'COLOQUE_O_NUMERO_DA_RADIO_AQUI';

// Cores aproximadas do print. Ajuste se quiser.
const corTopo = Color(0xFF3D4A8C);
const corEscura = Color(0xFF111827);

void main() => runApp(const RadioApp());

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rádio IPDA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: corTopo,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RadioHome(),
    );
  }
}

class RadioHome extends StatefulWidget {
  const RadioHome({super.key});

  @override
  State<RadioHome> createState() => _RadioHomeState();
}

class _RadioHomeState extends State<RadioHome> {
  final _player = AudioPlayer();
  bool _loaded = false;

  Future<void> _toggle(bool playing) async {
    if (playing) {
      await _player.pause();
      return;
    }
    try {
      if (!_loaded) {
        await _player.setUrl(streamUrl);
        _loaded = true;
      }
      await _player.play();
    } catch (_) {
      _aviso('Não foi possível conectar à rádio.');
    }
  }

  // Em transmissão ao vivo, voltar/avançar pode não ser suportado.
  Future<void> _pular(int segundos) async {
    try {
      await _player.seek(_player.position + Duration(seconds: segundos));
    } catch (_) {}
  }

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _abrirSecao(String titulo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SecaoPage(titulo: titulo)),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Topo(onSelecionar: _abrirSecao),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(alignment: Alignment.centerLeft, child: _ChipRadio()),
          ),
          // O conteúdo ocupa o espaço que sobrou e encolhe sozinho se a tela
          // for pequena, então nunca precisa de barra de rolagem.
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Controles(
                        player: _player,
                        onToggle: _toggle,
                        onPular: _pular,
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      const Text(
                        'Rádio IPDA\nSão José do Rio Preto',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: corEscura,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A programação será exibida aqui.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faixa azul do topo com a logo e o menu de três pontos.
class _Topo extends StatelessWidget {
  final void Function(String) onSelecionar;
  const _Topo({required this.onSelecionar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: corTopo,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            children: [
              Center(
                // Coloque a logo em assets/logo_cortada.png (veja as instruções).
                // Enquanto não existir, mostra o texto no lugar.
                child: Image.asset(
                  'assets/logo_cortada.png',
                  height: 60,
                  errorBuilder: (_, __, ___) => const Text(
                    'DEUS É AMOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: onSelecionar,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'Eventos', child: Text('Eventos')),
                    PopupMenuItem(value: 'Cultos', child: Text('Cultos')),
                    PopupMenuItem(
                      value: 'Endereços das igrejas',
                      child: Text('Endereços das igrejas'),
                    ),
                    PopupMenuItem(
                      value: 'Redes sociais',
                      child: Text('Redes sociais'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Caixinha "Home / Rádio".
class _ChipRadio extends StatelessWidget {
  const _ChipRadio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
  '🙏',
  style: TextStyle(fontSize: 20),
),
          SizedBox(width: 6),
          Text('/', style: TextStyle(color: Colors.black38, fontSize: 15)),
          SizedBox(width: 6),
          Text(
            'Pedido de oração',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: corEscura,
            ),
          ),
        ],
      ),
    );
  }
}

class _Compartilhe extends StatelessWidget {
  const _Compartilhe();

  Future<void> _abrirWhatsApp(BuildContext context) async {
    final numero = numeroWhatsAppRadio.replaceAll(RegExp(r'\D'), '');

    if (numero.isEmpty || numero == '551732234704') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configure o número do WhatsApp da rádio no main.dart.'),
        ),
      );
      return;
    }

    const mensagem = 'Olá! Meu pedido de oração:';
    final url = Uri.parse(
      'https://wa.me/$numero?text=${Uri.encodeComponent(mensagem)}',
    );

    final abriu = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _abrirWhatsApp(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Pedido de oração',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: corEscura,
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha com voltar 15, play/pause e avançar 15.
class _Controles extends StatelessWidget {
  final AudioPlayer player;
  final Future<void> Function(bool playing) onToggle;
  final Future<void> Function(int segundos) onPular;

  const _Controles({
    required this.player,
    required this.onToggle,
    required this.onPular,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;
        final carregando = state?.processingState == ProcessingState.loading ||
            state?.processingState == ProcessingState.buffering;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Pular(icone: Icons.replay, onTap: () => onPular(-15)),
            const SizedBox(width: 20),
            Material(
              color: corEscura,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: carregando ? null : () => onToggle(playing),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: Center(
                    child: carregando
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            _Pular(icone: Icons.refresh, onTap: () => onPular(15)),
          ],
        );
      },
    );
  }
}

class _Pular extends StatelessWidget {
  final IconData icone;
  final VoidCallback onTap;
  const _Pular({required this.icone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icone, size: 38, color: corEscura),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                '15',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: corEscura,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela genérica para as opções do menu. Troque por telas próprias depois.
class SecaoPage extends StatelessWidget {
  final String titulo;
  const SecaoPage({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: corTopo,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('$titulo — em construção')),
    );
  }
}