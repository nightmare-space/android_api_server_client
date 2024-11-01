// ignore_for_file: avoid_print

import 'dart:io';
import 'package:app_channel/api/api.dart';
import 'package:app_channel/foundation/app.dart' as app;
import 'package:app_channel/model/model.dart';
import 'package:dio/dio.dart';
import 'package:global_repository/global_repository_dart.dart';
import 'package:signale/signale.dart';

class AppChannel {
  AppChannel({this.port}) {
    Log.i('AppChannel new instance port:$port');
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      port ??= 0;
    }
    BaseOptions options = BaseOptions(
      receiveDataWhenStatusError: true,
      contentType: Headers.jsonContentType,
      headers: {
        'Accept': '*/*',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) {
        return status != null;
        // return status != null && status >= 200 && status < 300;
      },
      followRedirects: true,
    );
    Dio dio = Dio(options);
    // dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) {
    //       print(options.extra);
    //       print('');
    //       Log.v('>>>>>>>>HTTP LOG');
    //       Log.v('>>>>>>>>URI: ${options.uri}');
    //       Log.v('>>>>>>>>Method: ${options.method}');
    //       Log.v('>>>>>>>>Headers: ${options.headers}');
    //       JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    //       String prettyprint = encoder.convert(options.data);
    //       Log.v('>>>>>>>>Body: $prettyprint');
    //       Log.v('<<<<<<<<');
    //       print('');
    //       // log response
    //       handler.next(options);
    //     },
    //   ),
    // );
    baseUrl = 'http://127.0.0.1:${port ?? (port = getPort())}';
    Log.i('AppChannel api init port:$port');
    api = Api(dio, baseUrl: baseUrl);
  }
  String baseUrl = '';

  String tag = 'AppChannel';

  int? port;

  late Api api;

  int? getPort() {
    if (port != null) {
      return port;
    }
    String data = File('${RuntimeEnvir.filesPath}/server_port').readAsStringSync();
    return int.tryParse(data);
  }

  AppInfos userApps = const AppInfos(infos: []);
  AppInfos systemApps = const AppInfos(infos: []);

  // 起初 App Channel 本身不存储相关数据，只做通信
  // 但后面发现经常一个 App 中有多个 AppChannel(例如 ADB KIT)
  // 如果此时再将 Channel 对应设备的软件信息存在别的地方，例如 AppController
  // 数据就会非常的乱
  //
  // At first, the App Channel itself does not store related data, only communication
  // But later found that there are often multiple AppChannels in an App (such as ADB KIT)
  // If the software information of the device corresponding to the channel is stored elsewhere at this time, such as AppController
  // The data will be very messy
  Future<void> loadUserApps() async {
    userApps = await getAppInfosV2();
    userApps.infos.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
  }

  Future<void> loadSystemApps() async {
    systemApps = await getAppInfosV2(true);
    systemApps.infos.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
  }

  Future<AppInfos> getAppInfosV2([bool? isSystemApp]) async {
    AppInfos appInfos = await api.getAllAppInfoV2(isSystemApp: isSystemApp);
    return appInfos;
  }

  Future<String> getAppDetails(String package) async {
    String result = await api.getAppDetail(package: package);
    return result;
  }

  Future<String> getAppMainActivity(String packageName) async {
    Map<String, dynamic> result = await api.getAppMainActivity(package: packageName);
    return result['mainActivity'];
  }

  Future<List<String>> getAppActivitys(String package) async {
    String result = await api.getAppActivity(package: package);
    final List<String> infos = result.split('\n');
    infos.removeLast();
    return infos;
  }

  Future<List<String>> getAppPermission(String package) async {
    String result = await api.getAppPermissions(package: package);
    final List<String> infos = result.split('\r');
    infos.removeLast();
    return infos;
  }

  Future<String> execCMD(String cmd) async {
    String result = await api.execCMD(cmd: cmd);
    return result.trim();
  }

  Future<String> startActivity(String package, String activity, String id) async {
    Log.i('package -> $package activity -> $activity id -> $id', tag: tag);
    // 这里好像没有返回结果，用同一个dio会有问题
    // TODO 换成同一个 dio
    Api newApi = Api(Dio(), baseUrl: 'http://127.0.0.1:${port ?? getPort()}');
    String result = await newApi.startActivity(
      package: package,
      activity: activity,
      displayId: id,
      options: RequestOptions(
        headers: {
          'Content-Type': 'text/plain',
        },
      ),
    );
    return result;
  }

  Future<void> stopActivity(String package) async {
    // Log.i('package -> $package activity -> $activity id -> $id', tag: tag);
    // 这里好像没有返回结果，用同一个dio会有问题
    // TODO 换成同一个 dio
    Api newApi = Api(Dio(), baseUrl: 'http://127.0.0.1:${port ?? getPort()}');
    await newApi.stopActivity(
      package: package,
      options: RequestOptions(
        headers: {
          'Content-Type': 'text/plain',
        },
      ),
    );
  }

  Future<List<app.AppInfo>> getAppInfos(List<String> packages) async {
    String result = await api.getAppInfos(apps: packages);
    final List<String> infos = result.split('\n');
    final List<app.AppInfo> entitys = <app.AppInfo>[];
    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split('\r');
      final app.AppInfo appInfo = app.AppInfo(
        infoList[0],
        appName: infoList[1],
        minSdk: infoList[2],
        targetSdk: infoList[3],
        versionCode: infoList[5],
        versionName: infoList[4],
        freeze: infoList[6] == 'false',
        hide: infoList[7] == 'true',
        uid: infoList[8],
        apkPath: infoList[9],
      );
      entitys.add(appInfo);
    }
    return entitys;
  }

  Future<Displays> getDisplays() async {
    return await api.display(action: 'getDisplays');
  }

  String iconUrl(String package) {
    return '$baseUrl/icon?package=$package';
  }

  Future<Tasks> getTasks() async {
    Tasks result = await api.getTasks();
    return result;
  }

  Future<bool> clearAppData(String packageName) async {
    String result = await exec('pm clear $packageName');
    return result.isNotEmpty;
  }

  Future<bool> hideApp(String packageName) async {
    String result = await exec('pm hide $packageName');
    return result.isNotEmpty;
  }

  Future<bool> showApp(String packageName) async {
    String result = await exec('pm unhide $packageName');
    return result.isNotEmpty;
  }

  Future<bool> freezeApp(String packageName) async {
    Log.i('pm disable $packageName');
    String result = await exec(
      'pm disable-user --user 0 $packageName',
    );
    return result.isNotEmpty;
  }

  Future<bool> unFreezeApp(String packageName) async {
    String result = await exec('pm enable --user 0 $packageName');
    return result.isNotEmpty;
  }

  Future<bool> unInstallApp(String packageName) async {
    String result = await exec('pm uninstall  $packageName');
    return result.isNotEmpty;
  }

  Future<String> getFileSize(String path) async {
    return await exec('stat -c "%s" $path');
  }

  Future<Display?> createVirtualDisplay(int width, int height, int density, bool? useDeviceConfig) async {
    try {
      Display display = await api.createVirtualDisplay(
        width: width.toString(),
        height: height.toString(),
        density: density.toString(),
        useDeviceConfig: useDeviceConfig,
      );
      return display;
    } on DioException catch (e) {
      Log.e('createVirtualDisplay Error -> ${e.message} ${e.error} ${e.response}');
      return null;
    }
  }

  Future<Display?> createVirtualDisplayWithSurfaceView({
    int? width,
    int? height,
    int? density,
    bool? useDeviceConfig,
  }) async {
    assert(
      width != null || height != null || density != null || useDeviceConfig != null,
      'At least one parameter must be non-null',
    );
    try {
      Display display = await api.createVirtualDisplay(
        width: width.toString(),
        height: height.toString(),
        density: density.toString(),
        useDeviceConfig: useDeviceConfig,
      );
      return display;
    } on DioException catch (e) {
      Log.e('createVirtualDisplay Error -> ${e.message} ${e.error} ${e.response}');
      return null;
    }
  }
}




// class IsolateArgs {
//   final String deviceID;
//   final Map<String, dynamic> envir;
//   final int rangeStart;
//   IsolateArgs(this.deviceID, this.envir, this.rangeStart);
// }

// /// 顶级函数，为了在 isolate 中调用
// /// Process.start 在 UI 线程影响性能
// Future<int> startServerWithIsolate(IsolateArgs args) async {
//   RuntimeEnvir.initEnvirFromMap(args.envir);
//   Stopwatch stopwatch = Stopwatch()..start();
//   String suffix = Config.versionCode;
//   await initSetting();
//   Log.i('init setting time : ${stopwatch.elapsed}');
//   stopwatch.reset();
//   final Completer<int> completer = Completer();
//   String serverPath = Settings.serverPath.setting.get();
//   if (serverPath.isEmpty) {
//     serverPath = Config.adbLocalPath;
//   }
//   final String targetPath = '$serverPath/app_server$suffix';
//   Log.i('targetPath -> $targetPath');
//   // 上传server文件
//   await AdbUtil.pushFile(args.deviceID, '${RuntimeEnvir.binPath}/app_server', targetPath);
//   Log.i('push file time : ${stopwatch.elapsed}');
//   stopwatch.reset();
//   StringBuffer dexArg = StringBuffer();
//   dexArg.write('-s ${args.deviceID} ');
//   dexArg.write('shell ');
//   dexArg.write('CLASSPATH=$targetPath ');
//   dexArg.write('app_process ');
//   dexArg.write('$serverPath ');
//   dexArg.write('com.nightmare.applib.AppServer ');
//   dexArg.write('default');
//   final List<String> processArg = dexArg.toString().split(' ');
//   // !注意这个要和applib中的一样
//   const String startTag = 'success start port -> ';
//   String execuable = adb;
//   Process process = await Process.start(
//     execuable,
//     processArg,
//     includeParentEnvironment: true,
//     environment: adbEnvir(),
//     runInShell: GetPlatform.isWindows ? true : false,
//   );
//   StringBuffer printBuff = StringBuffer();
//   process.stdout.transform(utf8.decoder).listen((event) async {
//     if (event.isEmpty) {
//       return;
//     }
//     printBuff.write(event);
//     if ('$printBuff'.trim().isNotEmpty && '$printBuff'.contains('\n')) {
//       // 解决有时候打印一个点就占用一行的问题
//       Log.w('$printBuff'.trim(), tag: 'dex server');
//       printBuff.clear();
//     }
//     // `success start port -> 15000.`
//     if (event.contains(startTag)) {
//       for (final String line in event.split('\n')) {
//         // 说明服务启动了
//         if (line.contains(startTag)) {
//           String portStr = line.replaceAll(RegExp('.*> |\\..*'), '');
//           final int? dexPort = int.tryParse(portStr);
//           final int? forwardPort = await AdbUtil.getForwardPort(
//             args.deviceID,
//             rangeStart: args.rangeStart,
//             rangeEnd: args.rangeStart + 10,
//             targetArg: 'tcp:$dexPort',
//           );
//           completer.complete(forwardPort);
//         }
//       }
//     }
//   });
//   process.stderr.transform(utf8.decoder).listen((event) {
//     Log.e('error : $event');
//   });
//   process.exitCode.then((int code) {
//     Log.e('exit code : $code');
//   });
//   return completer.future;
// }

// class DexServer {
//   DexServer._();
//   static Map<String, AppChannel> serverStartList = {};
//   static int rangeStart = 14040;

//   static Future<AppChannel> startServer(String devicesId) async {
//     if (serverStartList.containsKey(devicesId)) {
//       return serverStartList[devicesId]!;
//     }
//     final int? port = await compute(
//       startServerWithIsolate,
//       IsolateArgs(devicesId, RuntimeEnvir.environment, rangeStart),
//     );
//     rangeStart += 10;
//     AppChannel channel = AppChannel(port: port);
//     return serverStartList[devicesId] = channel;
//   }
// }
