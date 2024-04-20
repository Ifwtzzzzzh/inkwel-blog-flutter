import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConncectionChecker {
  Future<bool> get isConnected;
}

class ConncectionCheckerImpl implements ConncectionChecker {
  final InternetConnection internetConnection;
  ConncectionCheckerImpl(this.internetConnection);

  @override
  Future<bool> get isConnected async =>
      await internetConnection.hasInternetAccess;
}
