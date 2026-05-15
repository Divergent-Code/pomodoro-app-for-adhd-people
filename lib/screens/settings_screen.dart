
import 'package:flutter/material.dart';
import 'package:pomodoro_app/services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _preferencesService = PreferencesService();

  String? _partnerPhoneNumber;
  String? _partnerCarrier;
  String? _userEmail;
  String? _userPassword;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    _partnerPhoneNumber = await _preferencesService.getPartnerPhoneNumber();
    _partnerCarrier = await _preferencesService.getPartnerCarrier();
    _userEmail = await _preferencesService.getUserEmail();
    _userPassword = await _preferencesService.getUserPassword();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _partnerPhoneNumber,
              decoration: InputDecoration(labelText: 'Partner Phone Number'),
              onSaved: (value) => _partnerPhoneNumber = value,
            ),
            TextFormField(
              initialValue: _partnerCarrier,
              decoration: InputDecoration(labelText: 'Partner Carrier'),
              onSaved: (value) => _partnerCarrier = value,
            ),
            TextFormField(
              initialValue: _userEmail,
              decoration: InputDecoration(labelText: 'Your Email'),
              onSaved: (value) => _userEmail = value,
            ),
            TextFormField(
              initialValue: _userPassword,
              decoration: InputDecoration(labelText: 'Your Email Password'),
              obscureText: true,
              onSaved: (value) => _userPassword = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _preferencesService.setPartnerPhoneNumber(_partnerPhoneNumber!);
                  _preferencesService.setPartnerCarrier(_partnerCarrier!);
                  _preferencesService.setUserEmail(_userEmail!);
                  _preferencesService.setUserPassword(_userPassword!);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
