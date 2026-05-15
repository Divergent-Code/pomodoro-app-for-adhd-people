
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String _username;
  final String _password;

  EmailService(this._username, this._password);

  Future<void> sendEmail(String recipient, String subject, String body) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'Pomodoro App')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
