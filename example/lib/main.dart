import 'dart:convert';
import 'dart:io';

import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

Future<void> main() async {
  RuntimeEnvir.initEnvirWithPackageName('com.example.android_api_server_client_example');
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ).copyWith(
          surface: const Color(0xfff3f4f9),
          surfaceContainer: const Color(0xffe8e9ee),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
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
  AASClient aasClient = AASClient(port: Platform.isMacOS ? 15000 : null);
  // AASClient aasClient = AASClient(port: 15000);
  Highlighter? highlighter;
  bool ready = false;
  @override
  void initState() {
    super.initState();
    init();
  }

  String deserializedynamic(dynamic data) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  Future<void> init() async {
    var theme = await HighlighterTheme.loadLightTheme();
    highlighter = Highlighter(
      language: 'json',
      theme: theme,
    );
    aasClient.initSymbol();
    ready = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppBar(
              title: const Text('Android API Server'),
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
            ),
            for (final entry in aasClient.apis.entries)
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
                    SizedBox(
                      width: double.infinity,
                      child: Builder(builder: (context) {
                        String route = entry.key;
                        Log.i('route -> $route');
                        Log.i('API -> ${entry.value}');
                        if (entry.key == '/icon') {
                          return FutureBuilder(
                            future: () async {
                              final argument = aasClient.apiArguments[entry.key];
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
                                  child: Image.network(
                                    snapshot.data.toString(),
                                    width: 100,
                                    height: 100,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          );
                        }

                        if (route == '/start_activity') {
                          return TextButton(
                            onPressed: () async {
                              final argument = aasClient.apiArguments[entry.key];
                              DefaultMap defaultMap = await Function.apply(entry.value, null, argument);
                              Log.i('defaultMap -> $defaultMap');
                            },
                            child: const Text('Start Activity'),
                          );
                        }

                        if (route == '/tasks_thumbnail') {
                          return FutureBuilder(
                            future: () async {
                              Tasks tasks = await aasClient.getTasks();
                              List<String> urls = [];
                              for (var task in tasks.datas) {
                                urls.add(aasClient.taskUrl(task.id));
                              }
                              return urls;
                            }(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return SizedBox(
                                  height: 300,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      for (var url in snapshot.data as List<String>)
                                        Image.network(
                                          url.toString(),
                                          errorBuilder: (context, error, stackTrace) {
                                            return const SizedBox();
                                          },
                                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.surfaceContainer,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      blurRadius: 8,
                                                      spreadRadius: 0,
                                                      offset: Offset.zero,
                                                    ),
                                                  ],
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          );
                        }
                        if (route == '/stop_activity') {
                          return TextButton(
                            onPressed: () async {
                              final argument = aasClient.apiArguments[entry.key];
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
                                final result = await Function.apply(entry.value, null, null);
                                return result;
                              }(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text.rich(
                                    highlighter!.highlight(deserializedynamic(snapshot.data)),
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      // decoration: TextDecoration.lineThrough,
                                      // decorationThickness: 2.85,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
