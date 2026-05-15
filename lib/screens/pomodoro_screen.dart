import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../widgets/custom_button.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late TimerService _timerService;
  AudioPlayer? _alarmAudioPlayer;

  @override
  void initState() {
    super.initState();
    _timerService = Provider.of<TimerService>(context, listen: false);
    _timerService.initialize();
    // Inicializar el reproductor de audio para las alarmas
    _alarmAudioPlayer = AudioPlayer();
    _alarmAudioPlayer!.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _alarmAudioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_timerService.isRunning,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _showRunningAlert(context);
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpeg'),
              fit: BoxFit.cover, // Ajusta la imagen para cubrir toda la pantalla
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicador de fase
                Text(
                  _timerService.currentPhase,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _timerService.getPhaseColor(),
                  ),
                ),
                SizedBox(height: 20),
                // Temporizador circular
                _buildTimerDisplay(),
                SizedBox(height: 30),
                // Controles principales
                _buildMainControls(),
                SizedBox(height: 20),
                // Controles secundarios (saltar, sonido, wakelock)
                _buildSecondaryControls(),
                SizedBox(height: 30),
                // Contador de pomodoros y progreso hacia pausa larga
                _buildPomodoroProgress(),
                SizedBox(height: 20),
                // Botón para detener alarma (visible solo cuando suena)
                _buildAlarmControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRunningAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
              "Timer is on. You can't leave until alarm goes off. Please stay focused!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimerDisplay() {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: timerService.getProgress(),
                    strokeWidth: 8,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timerService.getPhaseColor(),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerService.getFormattedTime(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainControls() {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón de Iniciar/Pausar/Reanudar
            CustomButton(
              onPressed: () {
                if (!timerService.isRunning) {
                  timerService.startTimer();
                } else if (timerService.isPaused) {
                  timerService.resumeTimer();
                } else {
                  timerService.pauseTimer();
                }
              },
              icon: timerService.isRunning && !timerService.isPaused
                  ? Icons.pause
                  : Icons.play_arrow,
              label: timerService.isRunning && !timerService.isPaused
                  ? 'Pause'
                  : (timerService.isPaused ? 'Resume' : 'Start'),
              color: timerService.isRunning && !timerService.isPaused
                  ? timerService.getPhaseColor()
                  : Colors.grey,
            ),
            SizedBox(width: 16),
            // Botón de Detener (solo visible cuando está corriendo)
            if (timerService.isRunning)
              CustomButton(
                onPressed: () {
                  timerService.stopTimer();
                },
                icon: Icons.stop,
                label: 'Stop',
                color: Colors.red,
              ),
          ],
        );
      },
    );
  }

  Widget _buildSecondaryControls() {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón de Saltar fase
            CustomButton(
              onPressed: () {
                timerService.skipPhase();
              },
              icon: Icons.skip_next,
              label: 'Skip',
              color: Colors.grey,
            ),
            SizedBox(width: 12),
            // Botón de WakeLock (mantener pantalla encendida)
            CustomButton(
              onPressed: () {
                timerService.toggleWakelock();
              },
              icon: timerService.isWakelockEnabled
                  ? Icons.screen_lock_portrait
                  : Icons.screen_lock_portrait_outlined,
              label: timerService.isWakelockEnabled ? 'WL On' : 'WL Off',
              color: timerService.isWakelockEnabled
                  ? Color.fromARGB(255, 92, 179, 95)
                  : Colors.grey,
            ),
            SizedBox(width: 12),
            // Botón de sonido de tic-tac
            CustomButton(
              onPressed: () {
                timerService.toggleTickSound();
              },
              icon: timerService.isTickSoundEnabled
                  ? Icons.volume_up
                  : Icons.volume_off,
              label: timerService.isTickSoundEnabled ? 'Sound On' : 'Sound Off',
              color: timerService.isTickSoundEnabled
                  ? Color.fromARGB(255, 74, 140, 206)
                  : Colors.grey,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPomodoroProgress() {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        return Column(
          children: [
            Text(
              'Completed: ${timerService.completedPomodoros}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Next long break in: ${timerService.pomodorosBeforeLongBreak}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlarmControls() {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        // Mostrar botón de detener alarma solo si no está corriendo
        // (asumimos que la alarma suena cuando el timer se completa)
        if (!timerService.isRunning &&
            (timerService.isBreak ||
                timerService.currentPhase == 'Pomodoro')) {
          return ElevatedButton.icon(
            onPressed: () {
              timerService.stopAlarmSound();
            },
            icon: Icon(Icons.alarm_off),
            label: Text('Stop Alarm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
