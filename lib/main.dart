import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/root_shell.dart';
import 'theme/app_theme.dart';
import 'widgets/pando_provider.dart';

void main() {
  runApp(const HiPandoApp());
}

class HiPandoApp extends StatelessWidget {
  const HiPandoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PandoProvider(),
      child: MaterialApp(
        title: 'Hi Pando',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const RootShell(),
      ),
    );
  }
}
