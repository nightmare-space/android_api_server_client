// ignore_for_file: avoid_print

import 'dart:io';
import 'package:android_api_server/api/aas_api.dart';
import 'package:android_api_server/model/app_activitys.dart';
import 'package:android_api_server/model/app_detail.dart';
import 'package:android_api_server/model/app_main_activity.dart';
import 'package:android_api_server/model/app_permission.dart';
import 'package:android_api_server/model/cmd_result.dart';
import 'package:android_api_server/model/default_map.dart';
import 'package:android_api_server/model/model.dart';
import 'package:dio/dio.dart';
import 'package:global_repository/global_repository_dart.dart';
import 'package:signale/signale.dart';

Map<String, Function> apis = {};
Map<String, Map<Symbol, dynamic>> apiArguments = {};

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
    apis = {
      '/all_app_info': getAppInfos,
      '/app_detail': getAppDetails,
      '/appactivity': getAppActivitys,
      '/app_main_activity': getAppMainActivity,
      '/app_permissions': getAppPermission,
      '/cmd': execCMD,
      '/display': getDisplays,
      '/icon': ({required String package}) {
        return iconUrl(package);
      },
      '/start_activity': startActivity,
      '/stop_activity': stopActivity,
      '/tasks': getTasks,
    };
    apiArguments = {
      '/all_app_info': {
        #isSystemApp: false,
      },
      '/app_detail': {
        #package: 'com.nightmare.android_api_server',
      },
      '/appactivity': {
        #package: 'com.nightmare.android_api_server',
      },
      '/app_main_activity': {
        #package: 'com.nightmare.android_api_server',
      },
      '/app_permissions': {
        #package: 'com.nightmare.android_api_server',
      },
      '/cmd': {
        #cmd: 'ls /data/data/com.nightmare.android_api_server',
      },
      '/display': {},
      '/icon': {
        #package: 'com.nightmare.android_api_server',
      },
      '/start_activity': {
        #package: 'com.android.settings',
        #activity: 'com.android.settings.Settings',
        #id: '0',
      },
      '/stop_activity': {
        #package: 'com.android.settings',
      },
      '/tasks': {},
    };
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
    userApps = await getAppInfos();
    userApps.infos.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
  }

  Future<void> loadSystemApps() async {
    systemApps = await getAppInfos(isSystemApp: true);
    systemApps.infos.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
  }

  Future<AppInfos> getAppInfos({bool? isSystemApp}) => api.getAllAppInfo(isSystemApp: isSystemApp);

  Future<AppDetail> getAppDetails({required String package}) => api.getAppDetail(package: package);

  Future<AppActivitys> getAppActivitys({required String package}) => api.getAppActivity(package: package);

  Future<AppMainActivity> getAppMainActivity({required String package}) => api.getAppMainActivity(package: package);

  Future<AppPermissions> getAppPermission({required String package}) => api.getAppPermissions(package: package);

  Future<CmdResult> execCMD({required String cmd}) => api.execCMD(cmd: cmd);

  Future<Displays> getDisplays() => api.display(action: 'getDisplays');

  Future<DefaultMap> startActivity({
    required String package,
    required String activity,
    String id = '0',
  }) async {
    return api.startActivity(package: package, activity: activity, displayId: id);
  }

  Future<void> stopActivity({required String package}) => api.stopActivity(package: package);

  String iconUrl(String package) {
    return '$baseUrl/icon?package=$package';
  }

  Future<Tasks> getTasks() => api.getTasks();

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
