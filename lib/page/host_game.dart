import 'package:flutter/material.dart';
import 'package:deckopia/models/sketchy_button.dart';
import 'package:deckopia/models/sketchy_dropdown_button.dart';
import 'package:deckopia/helper/sketchy_painter.dart';
import 'package:deckopia/util/config_provider.dart';

class HostGameScreen extends StatefulWidget {
  const HostGameScreen({Key? key}) : super(key: key);

  @override
  State<HostGameScreen> createState() => _HostGameScreenState();
}

class _HostGameScreenState extends State<HostGameScreen> {
  int _players = 4, _decks = 2, _cards = 2;
  String _time = '30 sec';
  bool _fullDistribution = false, _advanced = false;
  final _cardsController = TextEditingController(text: '2');
  String? _cardsError;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _cardsController.addListener(_validateCards);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _cards = _maxCardsPerPlayer;
      _cardsController.text = _cards.toString();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _cardsController.dispose();
    super.dispose();
  }

  int get _maxCardsPerPlayer => (_decks * context.deckConfig.cardsPerDeck) ~/ _players;

  void _validateCards() {
    setState(() {
      if (_fullDistribution) {
        _cards = _maxCardsPerPlayer;
        _cardsError = null;
        return;
      }
      
      final input = _cardsController.text;
      if (input.isEmpty) {
        _cardsError = null;
        return;
      }

      try {
        final value = int.parse(input);
        _cards = value;
        _cardsError = value < 1 ? 'Minimum 1 card required' 
                    : value > _maxCardsPerPlayer ? 'Exceeds maximum' 
                    : null;
      } catch (e) {
        _cardsError = 'Enter valid number';
      }
    });
  }

  void _updateCards() {
    _cards = _maxCardsPerPlayer;
    _cardsController.text = _cards.toString();
    _validateCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appConfig.theme.backgroundColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildBackground(),
        _buildOverlay(),
        SafeArea(child: _buildContent()),
      ],
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(context.config.colors.whiteGradient.top),
            Colors.white.withOpacity(context.config.colors.whiteGradient.bottom),
          ],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: Image.asset(
          context.assetsConfig.images.homeBackground,
          fit: BoxFit.cover,
          opacity: AlwaysStoppedAnimation(context.config.background.imageOpacity),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: context.appConfig.theme.backgroundColor.withOpacity(context.config.colors.standardOverlay),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.appConfig.theme.backgroundColor.withOpacity(context.config.background.overlay.opacityTop),
              context.appConfig.theme.backgroundColor.withOpacity(context.config.background.overlay.opacityBottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(context.config.spacing.default_),
      child: Column(
        children: [
          _buildTitle(),
          SizedBox(height: context.config.spacing.large),
          _buildGameSettings(),
          SizedBox(height: context.config.spacing.default_),
          _buildLetsGoButton(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: _containerDecoration(),
      child: Text(
        'Host Game',
        style: TextStyle(
          fontSize: context.appConfig.theme.fonts.titleSize,
          fontWeight: FontWeight.bold,
          fontFamily: context.appConfig.theme.fonts.fontFamily,
        ),
      ),
    );
  }

  Widget _buildGameSettings() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(context.config.spacing.default_),
        decoration: _containerDecoration(),
        child: Column(
          children: [
            _buildDropdownRow('Players', _players, List.generate(10, (i) => i + 1), (v) => setState(() { _players = v!; _updateCards(); })),
            _buildSpacing(),
            _buildDropdownRow('Decks', _decks, List.generate(3, (i) => i + 1), (v) => setState(() { _decks = v!; _updateCards(); })),
            _buildSpacing(),
            _buildCardsRow(),
            _buildSpacing(),
            _buildDropdownRow('Time', _time, ['10 sec', '20 sec', '30 sec', '1 min', '2 mins'], (v) => setState(() => _time = v!)),
            _buildSpacing(),
            _buildCheckboxRow('Advanced', _advanced, (v) => setState(() => _advanced = v!)),
            if (_advanced) _buildAdvancedSettings(),
            const Divider(),
            _buildLayoutButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow<T>(String label, T value, List<T> options, void Function(T?) onChanged) {
    return Row(
      children: [
        Text(label, style: _labelStyle()),
        const Spacer(),
        SketchyDropdownButton<T>(
          width: context.layoutConfig.ui.boxWidth,
          height: context.layoutConfig.ui.boxHeight,
          menuWidth: context.layoutConfig.ui.menuWidth,
          value: value,
          seed: label.hashCode,
          fontFamily: 'CaveatBrush',
          style: _dropdownStyle(),
          onChanged: onChanged,
          items: options.map((T option) => DropdownMenuItem<T>(
            value: option,
            alignment: Alignment.center,
            child: Text(option.toString()),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCardsRow() {
    return Column(
      children: [
        Row(
          children: [
            Text('Cards', style: _labelStyle()),
            const Spacer(),
            _buildCardsInput(),
            _buildFullDistributionCheckbox(),
          ],
        ),
        if (_cardsError != null) _buildErrorText(),
      ],
    );
  }

  Widget _buildCardsInput() {
    return Container(
      width: context.layoutConfig.ui.boxWidth,
      height: context.layoutConfig.ui.boxHeight,
      child: Stack(
        children: [
          CustomPaint(
            painter: SketchyButtonPainter(
              context.config.colors.buttonColors.yellow,
              50,
              context.config.sketchyButton.noiseMagnitude,
              context.config.sketchyButton.curveNoiseMagnitude,
              context.config.sketchy,
            ),
            child: Container(
              width: context.layoutConfig.ui.boxWidth,
              height: context.layoutConfig.ui.boxHeight,
            ),
          ),
          Center(
            child: TextField(
              controller: _cardsController,
              enabled: !_fullDistribution,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: InputBorder.none),
              style: _dropdownStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDistributionCheckbox() {
    return _buildCheckboxRow('full', _fullDistribution, (v) => setState(() {
      _fullDistribution = v!;
      if (_fullDistribution) {
        _cards = _maxCardsPerPlayer;
        _cardsController.text = _cards.toString();
        _cardsError = null;
      }
    }));
  }

  Widget _buildCheckboxRow(String label, bool value, void Function(bool?) onChanged) {
    return Row(
      children: [
        Text(label, style: _labelStyle().copyWith(color: Colors.grey)),
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Advanced settings placeholder'),
    );
  }

  Widget _buildLayoutButtons() {
    return Row(
      children: [
        Text('Layout', style: _labelStyle()),
        const Spacer(),
        _buildActionButton('Load', context.config.colors.buttonColors.yellow, () {}),
        const SizedBox(width: 12),
        _buildActionButton('Create', context.config.colors.buttonColors.pink, () {}),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text, style: _dropdownStyle().copyWith(color: Colors.black87)),
      ),
    );
  }

  Widget _buildLetsGoButton() {
    return SketchyButton(
      text: 'Lets Go',
      color: context.config.colors.buttonColors.lightBlue,
      onPressed: _cardsError == null ? () {} : null,
      seed: 3,
      width: 240,
    );
  }

  Widget _buildErrorText() => Padding(
    padding: const EdgeInsets.only(left: 48.0),
    child: Text(_cardsError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
  );

  Widget _buildSpacing() => SizedBox(height: context.config.spacing.default_);

  BoxDecoration _containerDecoration() => BoxDecoration(
    color: context.appConfig.theme.backgroundColor.withOpacity(context.config.colors.lightOverlay),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(
      color: Colors.black.withOpacity(context.config.sketchyButton.shadow.opacity),
      blurRadius: context.config.sketchyButton.shadow.blur * 2,
      offset: Offset(context.config.sketchyButton.shadow.offsetX, context.config.sketchyButton.shadow.offsetY * 2),
    )],
  );

  TextStyle _labelStyle() => const TextStyle(fontSize: 24, fontFamily: 'CaveatBrush');
  TextStyle _dropdownStyle() => const TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'CaveatBrush');
}
