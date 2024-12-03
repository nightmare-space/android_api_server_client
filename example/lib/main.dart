import 'dart:io';

import 'package:app_channel/api/aas_api.dart';
import 'package:app_channel/app_channel.dart';
import 'package:app_channel/model/default_map.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

Future<void> main() async {
  RuntimeEnvir.initEnvirWithPackageName('com.nightmare.app_channel');
  WidgetsFlutterBinding.ensureInitialized();
  await Highlighter.initialize(['json']);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ).copyWith(
          surface: const Color(0xfff3f4f9),
          surfaceContainer: const Color(0xffe8e9ee),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppChannel appChannel = AppChannel(port: Platform.isMacOS ? 15000 : null);
  Highlighter? highlighter;
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    var theme = await HighlighterTheme.loadLightTheme();
    highlighter = Highlighter(
      language: 'json',
      theme: theme,
    );
    Displays displays = await appChannel.getDisplays();
    Log.w('displays -> $displays');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Android API Server'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (final entry in apis.entries)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      String route = entry.key;
                      Log.i('entry.key -> ${entry.key}');
                      Log.i('entry.value -> ${entry.value}');
                      if (entry.key == '/icon') {
                        return FutureBuilder(
                          future: () async {
                            final argument = apiArguments[entry.key];
                            String url = await Function.apply(entry.value, null, argument);
                            return url;
                          }(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black,
                                  //     blurRadius: 12,
                                  //     spreadRadius: 4,
                                  //   ),
                                  // ],
                                ),
                                child: Image.network(snapshot.data.toString()),
                              );
                            }
                            return const SizedBox();
                          },
                        );
                      }

                      if (route == '/start_activity') {
                        return TextButton(
                          onPressed: () async {
                            final argument = apiArguments[entry.key];
                            DefaultMap defaultMap = await Function.apply(entry.value, null, argument);
                            Log.i('defaultMap -> $defaultMap');
                          },
                          child: const Text('Start Activity'),
                        );
                      }

                      if (route == '/stop_activity') {
                        return TextButton(
                          onPressed: () async {
                            final argument = apiArguments[entry.key];
                            DefaultMap defaultMap = await Function.apply(entry.value, null, argument);
                            Log.i('defaultMap -> $defaultMap');
                          },
                          child: const Text('Stop Activity'),
                        );
                      }
                      return Material(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder(
                            future: () async {
                              final argument = apiArguments[entry.key];
                              // Log.i('argument -> $argument');
                              final result = await Function.apply(entry.value, null, argument);
                              // Log.i('result -> $result');
                              return result;
                            }(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: Text.rich(
                                    highlighter!.highlight(deserializedynamic(snapshot.data)),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
