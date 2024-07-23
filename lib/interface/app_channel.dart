// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:app_channel/api/api.dart';
import 'package:app_channel/foundation/app.dart' as app;
import 'package:app_channel/foundation/app_info.dart';
import 'package:app_channel/model/model.dart';
import 'package:dio/dio.dart';
import 'package:global_repository/global_repository.dart';

/// 在起初的设计中，AppChannel 分为 LocalAppChannel 和 RemoteAppChannel
/// LocalAppChannel 即 App 运行时，获取安卓相关的信息
/// RemoteAppChannel 之前主要是 PC 端获取 Android 设备信息，创建虚拟显示器等
abstract class AppChannel {
  int? port;

  Future<List<app.AppInfo>> getAllAppInfo(bool isSystemApp);

  Future<List<app.AppInfo>> getAppInfos(List<String> packages);

  Future<String> getAppDetails(String package);

  Future<List<String>> getAppActivitys(String package);

  Future<List<String>> getAppPermission(String package);

  Future<String> getAppMainActivity(String packageName);

  Future<bool> clearAppData(String packageName);

  Future<bool> hideApp(String packageName);

  Future<bool> showApp(String packageName);

  Future<bool> freezeApp(String packageName);

  Future<bool> unFreezeApp(String packageName);

  Future<bool> unInstallApp(String packageName);

  /// 获得文件的大小
  Future<String> getFileSize(String path);

  Future<void> openApp(String packageName, String activity, String id);

  Future<Tasks> getTasks();

  Future<Displays> getDisplays();

  /// 创建虚拟显示器
  Future<Display?> createVirtualDisplay(int width, int height, int density, bool? useDeviceConfig);

  @override
  String toString() {
    return 'AppChannel{port: $port}';
  }
}

class RemoteAppChannel implements AppChannel {
  RemoteAppChannel({this.port}) {
    Log.v('RemoteAppChannel Instance port:$port');
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
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(options.extra);
          print('');
          Log.v('>>>>>>>>HTTP LOG');
          Log.v('>>>>>>>>URI: ${options.uri}');
          Log.v('>>>>>>>>Method: ${options.method}');
          Log.v('>>>>>>>>Headers: ${options.headers}');
          JsonEncoder encoder = const JsonEncoder.withIndent('  ');
          String prettyprint = encoder.convert(options.data);
          Log.v('>>>>>>>>Body: $prettyprint');
          Log.v('<<<<<<<<');
          print('');
          // log response
          handler.next(options);
        },
      ),
    );
    Log.i('RemoteAppChannel api init port:$port');
    api = Api(dio, baseUrl: 'http://127.0.0.1:${port ?? getPort()}');
  }

  String tag = 'RemoteAppChannel';
  @override
  int? port;

  late Api api;

  int? getPort() {
    if (port != null) {
      Log.e('port -> $port');
      return port;
    }
    String data = File('${RuntimeEnvir.filesPath}/server_port').readAsStringSync();
    port = int.tryParse(data);
    Log.i('成功获取 LocalAppChannel port -> $port', tag: tag);
    return port;
  }
  // Future<AppInfos>

  Future<AppInfos> getAppInfosV2() async {
    AppInfos appInfos = await api.getAllAppInfoV2();
    return appInfos;
  }

  @Deprecated('Use getAllAppInfoV2')
  @override
  Future<List<app.AppInfo>> getAllAppInfo(bool isSystemApp) async {
    Stopwatch watch = Stopwatch();
    watch.start();
    // Log.i(port);
    final result2 = await api.getAllAppInfoV2(isSystemApp: isSystemApp);
    Log.i('result2 -> $result2');
    final result = await api.getAllAppInfo(isSystemApp: isSystemApp);
    final List<String> infos = (result).split('\n');
    // Log.e('watch -> ${watch.elapsed}');
    final List<app.AppInfo> entitys = <app.AppInfo>[];

    /// 为了减少数据包大小，自定义了一个简单的协议，没用 json
    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split('\r');
      // Log.d('infoList line$i $infoList');
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

  @override
  Future<String> getAppDetails(String package) async {
    String result = await api.getAppDetail(package: package);
    return result;
  }

  @override
  Future<String> getAppMainActivity(String packageName) async {
    Map<String, dynamic> result = await api.getAppMainActivity(package: packageName);
    Log.i('getAppMainActivity $result', tag: tag);
    return result['mainActivity'];
  }

  @override
  Future<List<String>> getAppActivitys(String package) async {
    String result = await api.getAppActivity(package: package);
    final List<String> infos = result.split('\n');
    infos.removeLast();
    return infos;
  }

  @override
  Future<List<String>> getAppPermission(String package) async {
    String result = await api.getAppPermissions(package: package);
    final List<String> infos = result.split('\r');
    infos.removeLast();
    return infos;
  }

  @override
  Future<void> openApp(String package, String activity, String id) async {
    Log.i('package -> $package activity -> $activity id -> $id', tag: tag);
    Api newApi = Api(Dio(), baseUrl: 'http://127.0.0.1:${port ?? getPort()}');
    await newApi.openAppByPackage(
      package: package,
      activity: activity,
      displayId: id,
      options: RequestOptions(
        headers: {
          'Content-Type': 'text/plain',
        },
      ),
    );
  }

  @override
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

  /// 获得DisplayID List
  @override
  Future<Displays> getDisplays() async {
    return await api.displays();
  }

  @override
  Future<Tasks> getTasks() async {
    Tasks result = await api.getTasks();
    return result;
  }

  @override
  Future<bool> clearAppData(String packageName) async {
    String result = await exec('pm clear $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> hideApp(String packageName) async {
    String result = await exec('pm hide $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> showApp(String packageName) async {
    String result = await exec('pm unhide $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> freezeApp(String packageName) async {
    Log.i('pm disable $packageName');
    String result = await exec(
      'pm disable-user --user 0 $packageName',
    );
    return result.isNotEmpty;
  }

  @override
  Future<bool> unFreezeApp(String packageName) async {
    String result = await exec('pm enable --user 0 $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> unInstallApp(String packageName) async {
    String result = await exec('pm uninstall  $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<String> getFileSize(String path) async {
    return await exec('stat -c "%s" $path');
  }

  @override
  Future<Display?> createVirtualDisplay(int width, int height, int density, bool? useDeviceConfig) async {
    try {
      Display display = await api.createVirtualDisplay(
        width: width.toString(),
        height: height.toString(),
        density: density.toString(),
        useDeviceConfig: useDeviceConfig,
      );
      return display;
    } on DioError catch (e) {
      Log.e('createVirtualDisplay Error -> ${e.message} ${e.error} ${e.response}');
      return null;
    }
  }
}
// Future<String> exec(String cmd) async {
//   String value = '';
//   final ProcessResult result = await Process.run(
//     'sh',
//     ['-c', cmd],
//     environment: PlatformUtil.envir(),
//   );
//   value += result.stdout.toString();
//   value += result.stderr.toString();
//   return value.trim();
// }