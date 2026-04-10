import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../services/ai/rag_service.dart';

// Наследуемся от виджета с состоянием,
// то есть виджет для изменения состояния которого не требуется пересоздавать его инстанс
class SplashScreen extends StatefulWidget {

  final String nextRoute;
  const SplashScreen({super.key, required this.nextRoute});

  // все подобные виджеты должны создавать своё состояние,
  // нужно переопределять данный метод
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

// Создаём состояние виджета
class _SplashScreenState extends State<SplashScreen>
  with  TickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;
  // Инициализация состояния
  @override
  void initState() {
    super.initState();
    
    // Запуск фонової ініціалізації RAG бази знань (ліниве завантаження)
    _initializeBackgroundServices();
  // Создаём таймер, который должен будет переключить SplashScreen на HomeScreen через 2 секунды
  Timer(const Duration(seconds: 7),
  // Для этого используется статический метод навигатора
  // Это очень похоже на передачу лямбда функции в качестве аргумента std::function в C++
  () {
  Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  });
  _controller = AnimationController(
  duration: const Duration(seconds: 5),
  vsync: this,
  )
  ..repeat(reverse:true);
  _animation = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeOutSine
  );
  }
  @override
  void dispose() {
  _controller.dispose();
  super.dispose();
  }

  Future<void> _initializeBackgroundServices() async {
    try {
      await RAGService().initialize();
    } catch (e) {
      debugPrint("Фонова ініціалізація RAG завершилась помилкою: $e");
    }
  }

  // Формирование виджета
  @override
  Widget build(BuildContext context) {
  // А вот это вёрстка виджета,
  // немного похоже на QML хотя явно не JSON структура

  return SafeArea(
      left: true,
      top: true,
      right: true,
      bottom: true,
     child: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Scaffold(
  body: Center(
  child: Device.orientation == Orientation.portrait
      ? Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/ua1.gif'),
              fit: BoxFit.fitHeight)
      ),

  child: FadeTransition(
  opacity: _animation,
  child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  Text("Молитовник воїна",style: TextStyle(
  color: '#FFFFFF'.toColor(),
      fontFamily: "Church",
  fontSize: 30,
  fontWeight: FontWeight.bold),
  ),
  Image.asset("images/OCU_logo.png"),
  ],
  ),
  ),

  ):
  Container(

    constraints: const BoxConstraints.expand(),
    decoration: const BoxDecoration(
        image: DecorationImage(
           image: AssetImage('images/ua1.gif'),
            fit: BoxFit.contain),
    ),
    child: FadeTransition(
      opacity: _animation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Молитовник воїна",style: TextStyle(
              color: '#FFFFFF'.toColor(),
              fontFamily: "Church",
              fontSize: 30,
              fontWeight: FontWeight.bold),
          ),
          Image.asset("images/OCU_logo.png",
          height: 60.h,),
        ],
      ),
    ),

  ),
  ),
  )
     )
  );

  }
  }

