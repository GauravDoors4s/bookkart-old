import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';

import '../main.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class AudioBookPlayer extends StatefulWidget {
  final String url;
  final PlayerMode mode;
  final String bookName;
  final String bookImage;

  AudioBookPlayer(
      {Key key,
      @required this.url,
      this.bookImage,
      this.bookName,
      this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  _AudioBookPlayerState createState() => _AudioBookPlayerState(url, mode);
}

class _AudioBookPlayerState extends State<AudioBookPlayer>
    with WidgetsBindingObserver {
  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
      switch (state) {
        case AppLifecycleState.resumed:
          _play();
          print("app in resumed");
          break;
        case AppLifecycleState.inactive:
          _pause();
          print("app in inactive");
          break;
        case AppLifecycleState.paused:
          _pause();
          print("app in paused");
          break;
        case AppLifecycleState.detached:
          print("app in detached");
          break;
      }
    });
  }

  String url;
  double prevPos = 0.0;
  PlayerMode mode;
  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;
  bool isRendering = true;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';

  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  _AudioBookPlayerState(this.url, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _pause();
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: widget.bookName),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 220,
              height: 308,
              child: Stack(
                children: <Widget>[
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: (isRendering)
                        ? Container(
                            width: 220, height: 308, child: bookLoaderWidget)
                        : CachedNetworkImage(
                            placeholder: (context, url) => Center(
                              child: Container(
                                  width: 220,
                                  height: 308,
                                  child: bookLoaderWidget),
                            ),
                            imageUrl: widget.bookImage,
                            fit: BoxFit.fill,
                          ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: spacing_standard_new,
              ),
              padding: EdgeInsets.only(
                  left: spacing_standard, right: spacing_standard),
              child: Text(
                widget.bookName,
                style: TextStyle(
                  fontSize: fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: appStore.appTextPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isPlaying
                    ? Container(
                        margin: EdgeInsets.only(top: 20),
                        width: 60.0,
                        height: 60.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment(6.123234262925839e-17, 1),
                              end: Alignment(-1, 6.123234262925839e-17),
                              colors: [
                                Color.fromRGBO(185, 205, 254, 1),
                                Color.fromRGBO(182, 178, 255, 1)
                              ],
                            )),
                        child: IconButton(
                          key: Key('pause_button'),
                          onPressed: _isPlaying ? () => _pause() : null,
                          iconSize: 42.0,
                          icon: Icon(Icons.pause),
                          color: primaryColor,
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 20),
                        width: 60.0,
                        height: 60.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment(6.123234262925839e-17, 1),
                              end: Alignment(-1, 6.123234262925839e-17),
                              colors: [
                                Color.fromRGBO(185, 205, 254, 1),
                                Color.fromRGBO(182, 178, 255, 1)
                              ],
                            )),
                        child: Center(
                          child: IconButton(
                            key: Key('play_button'),
                            onPressed: _isPlaying ? null : () => _play(),
                            iconSize: 42.0,
                            icon: Icon(Icons.play_arrow),
                            color: primaryColor,
                          ),
                        ),
                      ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: Colors.grey[300],
                        trackShape: RoundedRectSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        thumbColor: accentColor,
                        overlayColor: Colors.red.withAlpha(32),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 28.0),
                        tickMarkShape: RoundSliderTickMarkShape(),
                        activeTickMarkColor: Colors.red[700],
                        inactiveTickMarkColor: Colors.red[100],
                        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                        valueIndicatorColor: Colors.redAccent,
                        valueIndicatorTextStyle: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                      child: Slider(
                        onChanged: (v) {
                          final position = v * _duration.inMilliseconds;
                          _audioPlayer
                              .seek(Duration(milliseconds: position.round()));
                        },
                        value: showProgressBar(),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: Text(
                    displayDurationText(),
                    style: TextStyle(
                        fontSize: fontSizeSmall,
                        color: appStore.textSecondaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        _audioPlayer.startHeadlessService();
        _audioPlayer.setNotification(
            title: 'App Name',
            artist: 'Artist or blank',
            albumTitle: 'Name or blank',
            imageUrl: 'url or blank',
            forwardSkipInterval: const Duration(seconds: 30),
            // default is 30s
            backwardSkipInterval: const Duration(seconds: 30),
            // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
    });

    _play();
  }

  double showProgressBar() {
    if (_position != null &&
        _duration != null &&
        _position.inMilliseconds > 0 &&
        _position.inMilliseconds < _duration.inMilliseconds) {
      if (prevPos == 0.0) {
        prevPos = _position.inMilliseconds / _duration.inMilliseconds;
      } else {
        if (prevPos != _position.inMilliseconds / _duration.inMilliseconds) {
          prevPos = _position.inMilliseconds / _duration.inMilliseconds;
          isRendering = false;
        } else {
          print("prevPos---------------");
          isRendering = true;
        }
      }
      return _position.inMilliseconds / _duration.inMilliseconds;
    } else {
      return 0.0;
    }
  }

  String displayDurationText() {
    String text = "";
    if (_position != null) {
      text = '${_positionText ?? ''} / ${_durationText ?? ''}';
    } else {
      if (_duration != null) {
        text = _durationText;
      } else {
        text = '';
      }
    }
    return text;
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1)
      setState(() => _playerState = PlayerState.playing);
    else {
      print("_play -------");
    }
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
