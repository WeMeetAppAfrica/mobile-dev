import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/values/colors.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class ChatPlayerWidget extends StatefulWidget {

  final String url;
  final PlayerMode mode;

  ChatPlayerWidget(
      {Key key,
      @required this.url,
      this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>  _ChatPlayerWidgetState();
}

class _ChatPlayerWidgetState extends State<ChatPlayerWidget> {
  String url;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;
  StreamSubscription<PlayerControlCommand> _playerControlCommandSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  @override
  void initState() {
    super.initState();
    url = widget.url;
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  Widget buildTime() {

    String val = "";

    if(_position == null && _duration != null) {
      val = formatDate(DateTime.fromMillisecondsSinceEpoch(_duration.inMilliseconds), [mm, ':', ss]);
    }

    if(_position != null) {
      val = formatDate(DateTime.fromMillisecondsSinceEpoch(_duration.inMilliseconds), [mm, ':', ss]);
    }

    return Text(
      val ?? "",
      style: TextStyle(
        color: Colors.white,
        fontSize: 12.0
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryElement,
            borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.0,
                height: 60.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: Icon(FeatherIcons.music, color: AppColors.secondaryElement),
              ),
              SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Slider(
                        activeColor: Colors.white,
                        onChanged: _duration == null ? null : (v) {
                          final Position = v * _duration.inMilliseconds;
                          _audioPlayer
                              .seek(Duration(milliseconds: Position.round()));
                        },
                        inactiveColor: Colors.white,
                        value: (_position != null &&
                                _duration != null &&
                                _position.inMilliseconds > 0 &&
                                _position.inMilliseconds <
                                    _duration.inMilliseconds)
                            ? _position.inMilliseconds /
                                _duration.inMilliseconds
                            : 0.0,
                      ),
                      InkWell(
                        onTap: _duration == null ? null :  _isPlaying ? _pause : _play,
                        child: Icon(_isPlaying ? FeatherIcons.pauseCircle : FeatherIcons.playCircle, color: Colors.white, size: 30.0),
                      ),
                      SizedBox(width: 5.0)
                    ],
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 85.0,
            bottom: 5.0,
            child: buildTime(),
          )
        ],
      ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // TODO implemented for iOS, waiting for android impl
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
          title: 'Unknown',
          artist: 'Unknown',
          albumTitle: 'albulm',
          imageUrl: '',
          // forwardSkipInterval: const Duration(seconds: 30), // default is 30s
          // backwardSkipInterval: const Duration(seconds: 30), // default is 30s
          duration: duration,
          elapsedTime: Duration(seconds: 0),
          hasNextTrack: true,
          hasPreviousTrack: false,
        );
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
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _playerControlCommandSubscription =
        _audioPlayer.onPlayerCommand.listen((command) {
      print('command');
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;
  }

  Future<int> _play() async {
    if(!url.contains("http")){
      return 0;
    }


    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(widget.url, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    
    if(!url.contains("http")){
      return 0;
    }

    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1)
      setState(() => _playingRouteState =
          _playingRouteState == PlayingRouteState.speakers
              ? PlayingRouteState.earpiece
              : PlayingRouteState.speakers);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
