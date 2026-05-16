import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro_app/navigator_key.dart';
import 'package:pomodoro_app/services/lock_screen_service.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:io';

class TimerService extends ChangeNotifier {
  // Constantes para los modos del temporizador (en segundos)
  static const int pomodoroTime = 20 * 60; // 20 minutos
  static const int shortBreakTime = 15 * 60; // 15 minutos
  static const int longBreakTime = 30 * 60; // 30 minutos
  static const int pomodorosBeforeLongBreakConstant = 4; // Ciclos antes de pausa larga
  static const int longBreakThreshold = 4;
  static const int pomodoroTimeMax = 1; // Para pruebas, 1 segundo = 1 pomodoro
  static const int shortBreakTimeMax = 2;
  static const int longBreakTimeMax = 3;
  static const int resetTime = 0;

  // Estados del temporizador
  final Stopwatch _elapsedTimer = Stopwatch(); // Tiempo transcurrido real
  Timer? _timer; // Timer periódico para actualizar UI
  Timer? _tickSoundTimer; // Timer para el sonido de tic-tac
   AudioPlayer? _audioPlayer; // Reproductor de audio principal
  AudioPlayer? _tickAudioPlayer; // Reproductor de audio para tic-tac
  // Contadores y estados
  int _remainingTime = pomodoroTime; // Tiempo restante en segundos
  int _completedPomodoros = 0; // Contador de pomodoros completados
  int _pomodorosBeforeLongBreak =
      pomodorosBeforeLongBreakConstant; // Ciclos restantes antes de pausa larga
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isBreak = false;
  bool _isLongBreak = false;
  bool _isTickSoundEnabled = true;
  bool _isWakelockEnabled = true;
  String _currentPhase = 'Pomodoro';
  bool _pomodoroCompleted = false;

  // Getters públicos
  bool get pomodoroCompleted => _pomodoroCompleted;
  int get remainingTime => _remainingTime; // Tiempo restante en segundos
  int get completedPomodoros => _completedPomodoros;
  int get pomodorosBeforeLongBreak => _pomodorosBeforeLongBreak; // Ciclos restantes
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isBreak => _isBreak;
  bool get isLongBreak => _isLongBreak;
  bool get isTickSoundEnabled => _isTickSoundEnabled;
  bool get isWakelockEnabled => _isWakelockEnabled;
  bool get isFocusMode => !_isBreak; // Modo enfoque = no es pausa
  String get currentPhase => _currentPhase;

  // Método de inicialización
  void initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Inicializar audio en modo silencioso para preparar el sistema
      //_audioPlayer = AudioPlayer();
      _tickAudioPlayer = AudioPlayer();
      //await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      await _tickAudioPlayer!.setReleaseMode(ReleaseMode.loop);
      // Activar wakelock por defecto en móviles
      _isWakelockEnabled = true;
      WakelockPlus.enable();
    }
  }

  // Formatear tiempo en formato HH:MM:SS o MM:SS
  String getFormattedTime({bool showHours = false}) {
    int hours = _remainingTime ~/ 3600;
    int minutes = (_remainingTime % 3600) ~/ 60;
    int seconds = _remainingTime % 60;

    if (showHours || hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Obtener el progreso actual como fracción (0.0 a 1.0)
  double getProgress() {
    int totalTime;
    if (_isBreak && _isLongBreak) {
      totalTime = longBreakTime;
    } else if (_isBreak) {
      totalTime = shortBreakTime;
    } else {
      totalTime = pomodoroTime;
    }
    return (_remainingTime / totalTime).clamp(0.0, 1.0);
  }

  // Obtener color según la fase actual
  Color getPhaseColor() {
    if (_isBreak && _isLongBreak) {
      return const Color(0xFF4CAF50); // Verde para pausa larga
    } else if (_isBreak) {
      return const Color(0xFFFF9800); // Naranja para pausa corta
    } else {
      return const Color(0xFFFF5252); // Rojo para pomodoro
    }
  }

 // Iniciar o reanudar el temporizador
void startTimer() async {
 if (_isRunning && !_isPaused) return; // Ya está corriendo
 
   // Inicializar audio en modo silencioso para preparar el sistema
 _tickAudioPlayer = AudioPlayer();
 await _tickAudioPlayer!.setReleaseMode(ReleaseMode.loop);  

 if (Platform.isAndroid || Platform.isIOS) {
     _isWakelockEnabled = true;
     WakelockPlus.enable();
   }

  if (!_isPaused) {
    // Si no estaba pausado, iniciar desde el principio
    _elapsedTimer.start();
  } else {
    // Si estaba pausado, reanudar
    _elapsedTimer.start();
  }

  _isRunning = true;
  _isPaused = false;
  
  // Iniciar el timer que actualiza la UI cada segundo
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    _updateTimer();
  });
  
  // Iniciar el sonido de tic-tac
  _startTickSound();
  
  notifyListeners();
}

  // Pausar el temporizador
  void pauseTimer() {
    if (!_isRunning || _isPaused) return;

    _elapsedTimer.stop();
    _timer?.cancel();
    _stopTickSound();

    _isPaused = true;
    notifyListeners();
  }

  // Reanudar después de pausa
  void resumeTimer() {
    if (!_isPaused) return;

    _elapsedTimer.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimer();
    });
    _startTickSound();

    _isPaused = false;
    notifyListeners();
  }

  // Detener y reiniciar el temporizador completamente
  void stopTimer() {
    _elapsedTimer.stop();
    _elapsedTimer.reset();
    _timer?.cancel();
    _stopTickSound();

    _isRunning = false;
    _isPaused = false;

    // Restablecer al tiempo según la fase actual
    if (_isBreak && _isLongBreak) {
      _remainingTime = longBreakTime;
    } else if (_isBreak) {
      _remainingTime = shortBreakTime;
    } else {
      _remainingTime = pomodoroTime;
    }

    notifyListeners();
  }

  // Saltar al siguiente modo (pomodoro → break o break → pomodoro)
  void skipPhase() {
    _timer?.cancel();
    _tickSoundTimer?.cancel();
    _elapsedTimer.stop();
    _elapsedTimer.reset();

    if (_isBreak) {
      // Si está en pausa, volver a pomodoro
      _isBreak = false;
      _isLongBreak = false;
      _remainingTime = pomodoroTime;
      _currentPhase = 'Pomodoro';
    } else {
      // Si está en pomodoro, ir a pausa
      _completedPomodoros++;
      _pomodorosBeforeLongBreak--;
      if (_pomodorosBeforeLongBreak <= 0) {
        _isLongBreak = true;
        _isBreak = true;
        _remainingTime = longBreakTime;
        _currentPhase = 'Long Break';
        _pomodorosBeforeLongBreak = pomodorosBeforeLongBreakConstant;
      } else {
        _isBreak = true;
        _remainingTime = shortBreakTime;
        _currentPhase = 'Short Break';
      }
    }

    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  // Activar/desactivar sonido de tic-tac
  void toggleTickSound() {
    _isTickSoundEnabled = !_isTickSoundEnabled;
    if (_isTickSoundEnabled && _isRunning && !_isPaused) {
      _startTickSound();
    } else {
      _stopTickSound();
    }
    notifyListeners();
  }

  // Activar/desactivar WakeLock (mantener pantalla encendida)
  void toggleWakelock() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (_isWakelockEnabled) {
        await WakelockPlus.disable();
        _isWakelockEnabled = false;
      } else {
        await WakelockPlus.enable();
        _isWakelockEnabled = true;
      }
      notifyListeners();
    }
  }

  // Método para iniciar el sonido de tic-tac
  void _startTickSound() async {
    if (!_isTickSoundEnabled) return;
    
    if (_isBreak) {
      // No reproducir tic-tac durante las pausas
      _audioPlayer?.stop();
      return;
    }

    // Detener cualquier sonido anterior
    _tickAudioPlayer?.stop();
    _tickSoundTimer?.cancel();
    
    // Reproducir el tic-tac en bucle
    try {
      String assetPath = 'audio/clock_ticking.mp3';
      await _tickAudioPlayer!.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing tick sound: $e');
    }
  }

  // Método para detener el sonido de tic-tac
  void _stopTickSound() async {
    _tickSoundTimer?.cancel();
    _tickAudioPlayer?.stop();
  }

  // Actualizar el temporizador (llamado cada segundo por el Timer)
  void _updateTimer() {
    // Actualizar el tiempo restante basado en el tiempo transcurrido real
    int totalTime = _getTotalTime();
    _remainingTime = totalTime - _elapsedTimer.elapsed.inSeconds;
    //print('Actualizando temporizador - Tiempo restante: $_remainingTime segundos');
    // Verificar si el temporizador ha llegado a cero
    if (_remainingTime <= 0) {
      _handleTimerComplete();
    }

    notifyListeners();
  }

  // Obtener el tiempo total según la fase actual
  int _getTotalTime() {
    if (_isBreak && _isLongBreak) {
      return longBreakTime;
    } else if (_isBreak) {
      return shortBreakTime;
    } else {
      return pomodoroTime;
    }
  }

  // Manejar la finalización del temporizador
  void _handleTimerComplete() async {
    final context = navigatorKey.currentContext!;
    _timer?.cancel();
    _tickSoundTimer?.cancel();
    _elapsedTimer.stop();
    _elapsedTimer.reset();

    if (_isBreak) {
      // Transición de pausa a pomodoro
      _isBreak = false;
      _isLongBreak = false;
      _remainingTime = pomodoroTime;
      _currentPhase = 'Pomodoro';
      await playAlarmSound();
    } else {
      // Transición de pomodoro a pausa
      _completedPomodoros++;
      _pomodoroCompleted = true;
      _pomodorosBeforeLongBreak--;
      if (_pomodorosBeforeLongBreak <= 0) {
        _isLongBreak = true;
        _isBreak = true;
        _remainingTime = longBreakTime;
        _currentPhase = 'Long Break';
        _pomodorosBeforeLongBreak = pomodorosBeforeLongBreakConstant;
        await playAlarmSound();
        if (context.mounted) {
          Provider.of<LockScreenService>(context, listen: false).lock();
        }
      } else {
        _isBreak = true;
        _remainingTime = shortBreakTime;
        _currentPhase = 'Short Break';
        await playAlarmSound();
        if (context.mounted) {
          Provider.of<LockScreenService>(context, listen: false).lock();
        }
      }
    }

    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  // Reproducir sonido de alarma al completar una fase
  Future<void> playAlarmSound() async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      }
      await _audioPlayer!.play(AssetSource('audio/clock_ticking_two.mp3'));
       } catch (e) {
      debugPrint('Error playing alarm: $e');
    }
  }

  // Detener el sonido de alarma
  Future<void> stopAlarmSound() async {
    await _audioPlayer?.stop();
  }

  void resetPomodoroCompleted() {
    _pomodoroCompleted = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tickSoundTimer?.cancel();
    _audioPlayer?.dispose();
    _tickAudioPlayer?.dispose();
    _elapsedTimer.stop();
    super.dispose();
  }
}
