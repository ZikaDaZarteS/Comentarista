import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';

class ProvidersConfig {
  static List<Provider> get providers => [
        Provider<EventService>(
          create: (context) => EventService(),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(),
        ),
      ];

  static EventService appProvider(BuildContext context) {
    return Provider.of<EventService>(context, listen: false);
  }

  static AuthService authProvider(BuildContext context) {
    return Provider.of<AuthService>(context, listen: false);
  }
}
