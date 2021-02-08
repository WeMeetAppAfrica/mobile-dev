import 'dart:async';
import 'package:just_audio/just_audio.dart';

import 'package:wemeet/models/song.dart';

class WeMeetAudioService {

  WeMeetAudioService._internal() {
    _init();
  }

  static final WeMeetAudioService _audioService = WeMeetAudioService._internal();

  factory WeMeetAudioService(){
    return _audioService;
  }

  void _init() {
    if(_player == null) {
      _player = AudioPlayer();
      print("Initializing player");
    } else {
      print("Player already running");
    }
  }

  AudioPlayer _player = AudioPlayer();

  void dispose() {
    _player?.dispose();
  }

  List<String> _controls = [];
  String _playerMode = "none";
  String get playerMode => _playerMode;
  List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;
  SongModel _currentSong;
  String _currentUrl;
  String get currentUrl => _currentUrl;
  SongModel get currentMedia => _currentSong;
  StreamSubscription<AudioPlaybackState> _playerStateSubscription;
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;
  StreamController<List<String>> _controlsController =
      StreamController<List<String>>.broadcast();
  Stream<List<String>> get controlsStream =>
      _controlsController.stream;
  
  StreamController<String> _playerModeController =
      StreamController<String>.broadcast();
  Stream<String> get playerModeStream =>
      _playerModeController.stream;

  StreamController<SongModel> _songController =
      StreamController<SongModel>.broadcast();
  Stream<SongModel> get mediaStream =>
      _songController.stream;

  // check if player is running

  void _setControls({List<String> add, List<String> remove, bool force = false}) {

    if(force) {
      _controls = add;
      _controlsController.add(_controls);
      return;
    }

    (add ?? []).forEach((e){
      _controls.add(e);
    });

    _controls = _controls.toSet().toList();

    (remove ?? []).forEach((e){
      _controls.remove(e);
    });

    _controlsController.add(_controls);
  }

  void _setCurrentSong(SongModel val) {
    _currentSong = val;
    _songController.add(val);
  }

  // set the playlist
  void setQueue(List<SongModel> val) {
    val.forEach((e) {
      int i = _songs.indexWhere((j) => j.id == e.id);
      if(i < 0) {
        _songs.add(e);
      }
    });

    _setControls(add: ["none"]);
    _currentUrl = null;
    _playerModeController.add("playlist");
  }

  // clear Queue
  void clearQueue() {
    _songs.clear();
    _currentUrl = null;
    _playerModeController.add("none");
    _setCurrentSong(null);
  }

  bool get canNext {
    return _hasNext();
  }

  bool get canPrevious {
    return _hasPrevious();
  }

  // if can play next song
  bool _hasNext() {
    if(_songs.isEmpty && currentMedia == null) {
      return false;
    }

    if(currentMedia == null && _songs.length > 1) {
      return true;
    }

    int i = _songs.indexWhere((j) => j.id == currentMedia.id);  
    if(i < 0) {
      return false;
    }
    
    if(_songs.length <= (i + 1)) {
      return false;
    }

    return true;

  }

  // if can play previous song
  bool _hasPrevious() {
    if(_songs.isEmpty && currentMedia == null) {
      return false;
    }

    if(currentMedia == null) {
      return false;
    }

    int i = _songs.indexWhere((j) => j.id == currentMedia.id);  
    
    if(i >= 1) {
      return true;
    }

    return false;
  }

  // play from url
  void playFromUrl(String val) async {
    _currentUrl = val;
    await _player?.setUrl(val);
    _player?.play();
    _playerModeController.add("single");
    _playerMode = "single";
  }

  // Play a song from model
  void playSong(SongModel val) async {
    await _init();

    if(currentMedia == null) {
      start();
      print("Starting player service");
    }

    if(currentMedia == val) {
      _player.play();
      return;
    }

    await _player.setUrl(val.url);
     _setCurrentSong(val);
    _player.play();
    

    if(_hasNext()) _setControls(add: ["next"]);
    if(_hasPrevious()) _setControls(add: ["prev", "previous"]);
    _playerModeController.add("playlist");
  }

  void pause() async {
    await _player?.pause();
    _setControls(add: ["paused"], remove: ["playing", "play"]);
  }

  // stop player
  void stop() async {
    _playerModeController.add("none");
    _playerMode = "none";
    _controlsController.add([]);
    await _player?.stop();
    _playerStateSubscription?.cancel();
    _eventSubscription?.cancel();
  }

  void start({List<SongModel> queue, bool play = false}) async {

    _init();

    if(queue != null) {
      _songs = [];
      _playerModeController.add("playlist");
    }

    _playerStateSubscription = _player.playbackStateStream.listen((state) {
      switch (state) {
        case AudioPlaybackState.completed:
          print("completed");
          _setControls(add: ["completed"], force: true);
          _handlePlaybackCompleted();
          break;
        case AudioPlaybackState.connecting:
          _setControls(add: ["buffering"], remove: ["none", "completed"]);
          break;
        case AudioPlaybackState.paused:
          _setControls(add: ["paused"], force: true);
          break;
        case AudioPlaybackState.playing:
          _setControls(add: ["playing"], force: true);
          break;
        default:
          if(_songs.isNotEmpty && _currentUrl == null) {
            _playerModeController.add("playlist");
            return;
          } 

          if(_currentUrl != null) {
            _playerModeController.add("single");
            return;
          } 
          _playerModeController.add("none");
          
      }
    });

    _eventSubscription = _player.playbackEventStream.listen((event) {
      
    });

    if(play && _songs.isNotEmpty) {
      await _player.setUrl(_songs.first.url);
      _player.play();
      _setCurrentSong(_songs.first);
    }
  }

  void skipToNext() async {
    if(!_hasNext()) {
      return;
    }

    if(currentMedia == null) {
      await _player?.setUrl(_songs.first.url);
      await _player.play();
      _setCurrentSong(_songs.first);
      return;
    }

    int i = _songs.indexWhere((j) => j.id == currentMedia.id);  
    if(i < 0) {
      return;
    }

    await _player?.setUrl(_songs[i + 1].url);
    _setCurrentSong(_songs[i + 1]);
    _player.play();
    

  }

  void skipToPrevious() async {
    if(!_hasPrevious()) {
      return;
    }

    int i = _songs.indexWhere((j) => j.id == currentMedia.id);  
    if(i < 0) {
      return;
    }

    await _player?.setUrl(_songs[i - 1].url);
    _setCurrentSong(_songs[i - 1]);
    _player.play();
    
  }

  _handlePlaybackCompleted() {
    if (_hasNext()) {
      skipToNext();
    } else {
      _playerModeController.add("none");
      //stop();
    }
  }

}