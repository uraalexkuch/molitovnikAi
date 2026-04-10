import 'package:audio_session/audio_session.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const Player());

class Player extends StatefulWidget {
  static const routeName = '/category-player';

  const Player({super.key});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late AudioPlayer _player;
  final _playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("asset:///audio/morning.AAC"),
      tag: AudioMetadata(
        album: "РАНІШНІ МОЛИТВИ",
        title: "РАНІШНІ МОЛИТВИ",
        artwork: "images/morn.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/evning.AAC"),
      tag: AudioMetadata(
        album: "ВЕЧІРНІ МОЛИТВИ",
        title: "ВЕЧІРНІ МОЛИТВИ",
        artwork: "images/evning.jpg",
      ),
    )
  ]);
  final _playlistTwo = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("asset:///audio/zerkvaukraine.AAC"),
      tag: AudioMetadata(
        album: "Патріотичні молитви",
        title: "МОЛИТВА ЗА УКРАЇНСЬКУ ЦЕРКВУ",
        artwork: "images/ua.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/molukraine.AAC"),
      tag: AudioMetadata(
        album: "Патріотичні молитви",
        title: "БОЖЕ ВЕЛИКИЙ, ЄДИНИЙ",
        artwork: "images/ua.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/peopleukraine.AAC"),
      tag: AudioMetadata(
        album: "Патріотичні молитви",
        title: "МОЛИТВА ЗА КРАЩУ ДОЛЮ УКРАЇНСЬКОГО НАРОДУ",
        artwork: "images/ua.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/ukrainepeace.AAC"),
      tag: AudioMetadata(
        album: "Патріотичні молитви",
        title: "Молитва за Україну, Мир і Спокій ",
        artwork: "images/ua.gif",
      ),
    ),
  ]);
  final _playlistThree = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("asset:///audio/enemyukraine.AAC"),
      tag: AudioMetadata(
          album: "Молитви за Україну",
          title: "У ЧАС БІДИ ТА ПРИ НАПАДІ ВОРОГІВ",
          artwork: "images/ukraine.jpg"),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/mihail.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title: "ДО СВЯТОГО АРХИСТРАТИГА МИХАЇЛА",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm9.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title: "ПСАЛМИ ПІД ЧАС ЛИХА Й НАПАДУ ВОРОГІВ Ч.1",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm78.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title: "ПСАЛМИ ПІД ЧАС ЛИХА Й НАПАДУ ВОРОГІВ Ч.2",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm84.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title: "ПСАЛМИ ПІД ЧАС ЛИХА Й НАПАДУ ВОРОГІВ Ч.3",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm90.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title: "ПСАЛМИ ПІД ЧАС ЛИХА Й НАПАДУ ВОРОГІВ Ч.4",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm137.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title:
            "ПСАЛМИ, ЩОБ ГОСПОДЬ ВРОЗУМИВ ПРАВИТЕЛІВ РОБИТИ ТЕ, ЩО ПОТРІБНО НАРОДУ Ч.1",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm51.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title:
            "ПСАЛМИ, ЩОБ ГОСПОДЬ ВРОЗУМИВ ПРАВИТЕЛІВ РОБИТИ ТЕ, ЩО ПОТРІБНО НАРОДУ Ч.2",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm28.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title: "ПСАЛОМ ЗА МИР У КРАЇНІ",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm51.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title:
            "ПСАЛМИ, ЩОБ ГОСПОДЬ ВРОЗУМИВ ПРАВИТЕЛІВ РОБИТИ ТЕ, ЩО ПОТРІБНО НАРОДУ Ч.2",
        artwork: "images/ukraine.jpg",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm51.AAC"),
      tag: AudioMetadata(
        album: "Молитви за Україну",
        title:
            "ПСАЛМИ, ЩОБ ГОСПОДЬ ВРОЗУМИВ ПРАВИТЕЛІВ РОБИТИ ТЕ, ЩО ПОТРІБНО НАРОДУ Ч.2",
        artwork: "images/ukraine.jpg",
      ),
    ),
  ]);
  final _playlistFour = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm9.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 9",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm17.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 17",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm26.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 26",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm29.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 29",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm58.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 58",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm59.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 59",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm67.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 67",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm90.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 90",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm111.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 111",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm117.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 117",
        artwork: "images/psalm.gif",
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///audio/psalm137.AAC"),
      tag: AudioMetadata(
        album: "Псалми воїнів",
        title: "Псалом 137",
        artwork: "images/psalm.gif",
      ),
    ),
  ]);

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    final mealId = ModalRoute.of(context)!.settings.arguments as String;
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player.setAudioSource((mealId == 'm1' || mealId == 'm2')
          ? _playlist
          : (mealId == 'm3')
              ? _playlistTwo
              : (mealId == 'm4')
                  ? _playlistThree
                  : (mealId == 'm6')
                      ? _playlistFour
                      : _playlist);
    } catch (e) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: true,
        child: ResponsiveSizer(builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: SafeArea(
                  child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("images/paperold.jpg"),
                        fit: BoxFit.fill)),
                child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100.w,
                            height: 35.h,

                              child: StreamBuilder<SequenceState?>(
                                stream: _player.sequenceStateStream,
                                builder: (context, snapshot) {
                                  final state = snapshot.data;
                                  if (state?.sequence.isEmpty ?? true) {
                                    return const SizedBox();
                                  }
                                  final metadata =
                                      state!.currentSource!.tag as AudioMetadata;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Image.asset(
                                              metadata.artwork,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          metadata.album,
                                          style: TextStyle(
                                            fontFamily: "Church",
                                            fontSize: 18.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          metadata.title,
                                          style: TextStyle(
                                            fontFamily: "Church",
                                            fontSize: 14.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      ControlButtons(_player),
                                    const SizedBox(height: 8.0),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "СПИСОК МОЛИТВ",
                                              style: TextStyle(
                                                fontFamily: "Church",
                                                fontSize: 16.sp,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                  );
                                },
                              ),
                            ),


                          SizedBox(
                            width: 100.w,
                            height: 60.h,
                            child: Container(
                              child: StreamBuilder<SequenceState?>(
                                stream: _player.sequenceStateStream,
                                builder: (context, snapshot) {
                                  final state = snapshot.data;
                                  final sequence = state?.sequence ?? [];
                                  return ReorderableListView(
                                    onReorder: (int oldIndex, int newIndex) {
                                      if (oldIndex < newIndex) newIndex--;
                                      _playlist.move(oldIndex, newIndex);
                                    },
                                    children: [
                                      for (var i = 0; i < sequence.length; i++)
                                        Container(
                                          key: ValueKey(sequence[i]),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color:
                                                      i == state!.currentIndex
                                                          ? Colors.amberAccent
                                                          : null,
                                                  border: Border.all(
                                                      color: Colors.black54,
                                                      width: 5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: ListTile(
                                                leading: Image.asset(
                                                    sequence[i].tag.artwork),
                                                title: Text(
                                                    sequence[i].tag.title
                                                        as String,
                                                    style: TextStyle(
                                                      fontFamily: "Church",
                                                      fontSize: 18.sp,
                                                      color: Colors.indigo,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.fade),
                                                onTap: () {
                                                  _player.seek(Duration.zero,
                                                      index: i);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      )
              )
              ),
            ),
          );
        }
        ));
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
         IconButton(
            icon: const Icon(Icons.volume_up_sharp),
            onPressed: () {
              _showSliderDialog(
                context: context,
                title: "Гучність",
                divisions: 10,
                min: 0.0,
                max: 1.0,
                stream: player.volumeStream,
                onChanged: player.setVolume,
              );
            },
          ),
       StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: player.hasPrevious ? player.seekToPrevious : null,
            ),
          ),

 StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 24.0.sp,
                  height: 24.0.sp,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  iconSize: 35.0.sp,
                  onPressed: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause_circle_outline),
                  iconSize: 35.0.sp,
                  onPressed: player.pause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.reply_rounded),
                  iconSize: 24.0.sp,
                  onPressed: () => player.seek(Duration.zero,
                      index: player.effectiveIndices!.first),
                );
              }
            },
          ),

 StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: const Icon(Icons.skip_next_rounded),
              onPressed: player.hasNext ? player.seekToNext : null,
            ),
          ),


          StreamBuilder<double>(
            stream: player.speedStream,
            builder: (context, snapshot) => IconButton(
              icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                _showSliderDialog(
                  context: context,
                  title: "Швідкість відтворення",
                  divisions: 10,
                  min: 0.5,
                  max: 1.5,
                  stream: player.speedStream,
                  onChanged: player.setSpeed,
                );
              },
            ),
          ),

      ],
    );
  }
}





void _showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? 1.0,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AudioMetadata {
  final String album;
  final String title;
  final String artwork;

  AudioMetadata(
      {required this.album, required this.title, required this.artwork});
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;

  PositionData(this.position, this.bufferedPosition);
}
