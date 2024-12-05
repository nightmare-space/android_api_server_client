// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:android_api_server_client/src/api/aas_api.dart';
import 'package:android_api_server_client/src/model/model.dart';
import 'package:dio/dio.dart';
import 'package:global_repository/global_repository_dart.dart';
import 'package:signale/signale.dart';
import 'package:flutter/foundation.dart';

class AASClient {
  AASClient({this.port, this.url = 'http://127.0.0.1'}) {
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
    port ??= getPort();
    baseUrl = '$url:$port';
    Log.i('AppChannel api init port:$port');
    api = Api(dio, baseUrl: baseUrl);
    genKey();
  }

  Map<String, Function> apis = {};
  Map<String, Map<Symbol, dynamic>> apiArguments = {};

  String baseUrl = '';

  String tag = 'AppChannel';

  int? port;

  String url;

  late Api api;

  int? getPort() {
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
    userApps = await getAllAppInfos();
    userApps.infos.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
  }

  Future<void> loadSystemApps() async {
    systemApps = await getAllAppInfos(isSystemApp: true);
    systemApps.infos.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
  }

  String? apiKey;

  Completer<void> keyCompleter = Completer<void>();

  Future<void> genKey() async {
    apiKey = kDebugMode ? 'aas' : () {}.hashCode.toString();
    try {
      await api.setKey(key: apiKey);
    } on DioException catch (e) {
      Log.e('genKey Error -> ${e.message} ${e.error} ${e.response}');
    }
    keyCompleter.complete();
  }

  Future<void> waitKeyGen() async {
    await keyCompleter.future;
  }

  Future<AppInfos> getAllAppInfos({bool? isSystemApp}) async {
    await waitKeyGen();
    return api.getAllAppInfos(key: apiKey, isSystemApp: isSystemApp);
  }

  Future<AppDetail> getAppDetails({required String package}) async {
    await waitKeyGen();
    return api.getAppDetail(key: apiKey, package: package);
  }

  Future<AppActivitys> getAppActivitys({required String package}) async {
    await waitKeyGen();
    return api.getAppActivity(key: apiKey, package: package);
  }

  Future<AppMainActivity> getAppMainActivity({required String package}) async {
    await waitKeyGen();
    return api.getAppMainActivity(key: apiKey, package: package);
  }

  Future<String> getAppMainActivityString(String package) async {
    await waitKeyGen();
    return (await api.getAppMainActivity(key: apiKey, package: package)).activity;
  }

  Future<AppPermissions> getAppPermission({required String package}) async {
    await waitKeyGen();
    return api.getAppPermissions(key: apiKey, package: package);
  }

  Future<Displays> getDisplays() async {
    await waitKeyGen();
    return api.display(key: apiKey);
  }

  Future<DefaultMap> startActivity({
    required String package,
    required String activity,
    int displayId = 0,
  }) async {
    await waitKeyGen();
    return api.startActivity(key: apiKey, package: package, activity: activity, displayId: '$displayId');
  }

  Future<void> stopActivity({required String package}) async {
    await waitKeyGen();
    api.stopActivity(package: package);
  }

  String iconUrl(String package) {
    if (!keyCompleter.isCompleted) {
      throw 'key not ready';
    }
    return '$baseUrl/package_manager?key=$apiKey&action=get_icon&package=$package';
  }

  String taskUrl(int taskId) {
    if (!keyCompleter.isCompleted) {
      throw 'key not ready';
    }
    return '$baseUrl/task_thumbnail?key=$apiKey&id=$taskId';
  }

  Future<Tasks> getTasks() async {
    await waitKeyGen();
    return api.getTasks(key: apiKey);
  }

  // Future<bool> clearAppData(String packageName) async {
  //   String result = await exec('pm clear $packageName');
  //   return result.isNotEmpty;
  // }

  // Future<bool> hideApp(String packageName) async {
  //   String result = await exec('pm hide $packageName');
  //   return result.isNotEmpty;
  // }

  // Future<bool> showApp(String packageName) async {
  //   String result = await exec('pm unhide $packageName');
  //   return result.isNotEmpty;
  // }

  // Future<bool> freezeApp(String packageName) async {
  //   Log.i('pm disable $packageName');
  //   String result = await exec(
  //     'pm disable-user --user 0 $packageName',
  //   );
  //   return result.isNotEmpty;
  // }

  // Future<bool> unFreezeApp(String packageName) async {
  //   String result = await exec('pm enable --user 0 $packageName');
  //   return result.isNotEmpty;
  // }

  // Future<bool> unInstallApp(String packageName) async {
  //   String result = await exec('pm uninstall  $packageName');
  //   return result.isNotEmpty;
  // }

  // Future<String> getFileSize(String path) async {
  //   return await exec('stat -c "%s" $path');
  // }

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
