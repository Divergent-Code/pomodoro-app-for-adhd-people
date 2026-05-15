
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_app/services/email_service.dart';
import 'package:pomodoro_app/services/preferences_service.dart';

class LockScreenService extends ChangeNotifier {
  static const platform = MethodChannel('com.divergentcode.pomodoro/lockdown');

  bool _isLocked = false;
  String? _unlockCode;

  bool get isLocked => _isLocked;

  void lock() {
    _isLocked = true;
    _unlockCode = _generateUnlockCode();
    _sendUnlockCode();
    _minimizeWindows();
    notifyListeners();
  }

  Future<void> _minimizeWindows() async {
    try {
      await platform.invokeMethod('minimizeWindows');
    } on PlatformException catch (e) {
      print("Failed to minimize windows: '${e.message}'.");
    }
  }

  void unlock() {
    _isLocked = false;
    _unlockCode = null;
    notifyListeners();
  }

  bool verifyUnlockCode(String code) {
    if (code == _unlockCode) {
      unlock();
      return true;
    }
    return false;
  }

  String _generateUnlockCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> _sendUnlockCode() async {
    final preferencesService = PreferencesService();
    final emailService = EmailService(
      await preferencesService.getUserEmail() ?? '',
      await preferencesService.getUserPassword() ?? '',
    );

    final partnerPhoneNumber = await preferencesService.getPartnerPhoneNumber();
    final partnerCarrier = await preferencesService.getPartnerCarrier();

    if (partnerPhoneNumber != null && partnerCarrier != null) {
      final recipient = _getRecipientEmail(partnerPhoneNumber, partnerCarrier);
      await emailService.sendEmail(
        recipient,
        'Pomodoro App Unlock Code',
        'Your unlock code is: $_unlockCode',
      );
    }
  }

  String _getRecipientEmail(String phoneNumber, String carrier) {
    switch (carrier) {
      case 'Verizon':
        return '$phoneNumber@vtext.com';
      case 'T-Mobile':
        return '$phoneNumber@tmomail.net';
      case 'AT&T':
        return '$phoneNumber@txt.att.net';
      case 'Sprint':
        return '$phoneNumber@messaging.sprintpcs.com';
      case 'Spectrum':
        return '$phoneNumber@vtext.com';
      default:
        return '';
    }
  }
}
