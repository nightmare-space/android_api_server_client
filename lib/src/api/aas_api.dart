// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:android_api_server_client/src/model/app_flags.dart';
import 'package:android_api_server_client/src/model/cpu_gpu_info.dart';
import 'package:android_api_server_client/src/model/model.dart';
import 'package:android_api_server_client/src/model/pm_result.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' hide Headers;
part 'aas_api.g.dart';

const String _packageManager = '/package_manager';

@RestApi(baseUrl: "", parser: Parser.JsonSerializable)
abstract class Api {
  factory Api(Dio dio, {String baseUrl}) = _Api;

  @GET('/key')
  Future<String> setKey({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
  });

  @GET(_packageManager)
  Future<AppInfos> getAllAppInfos({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_all_app_info',
    @Query("is_system_app") bool? isSystemApp,
  });

  /// 获取应用详情
  /// get app detail
  @GET(_packageManager)
  Future<AppDetail> getAppDetail({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_app_details',
    @Query("package") String? package,
  });

  /// 通过包名获取 MainActivity
  /// get main activity by package
  @GET(_packageManager)
  Future<AppMainActivity> getAppMainActivity({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'app_main_activity',
    @Query("package") String? package,
  });

  /// 通过包名获取 所有的 Activitys
  /// get all activitys by package
  @GET(_packageManager)
  Future<AppActivitys> getAppActivity({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_app_activities',
    @Query("package") String? package,
  });

  /// 通过包名获取所有的 Permission
  /// get all permissions by package
  @GET(_packageManager)
  Future<AppPermissions> getAppPermissions({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_permissions',
    @Query("package") String? package,
  });

  /// 执行 pm 命令
  /// exec pm command
  @GET(_packageManager)
  Future<PMResult> execPMCommand({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'pm_cmd',
    @Query("cmd") String? cmd,
  });

  /// 通过包名获取所有的 Flag
  /// get all flags by package
  @GET(_packageManager)
  Future<AppFlags> getAppFlags({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_app_flags',
    @Query("private") bool? private,
    @Query("package") String? package,
  });

  /// 启动App
  /// open app by package
  @GET('/activity_manager')
  Future<DefaultResult> startActivity({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'start_activity',
    @Query("package") String? package,
    @Query("activity") String? activity,
    @Query("displayId") String? displayId,
  });

  @GET('/activity_task_manager')
  Future<Tasks> getTasks({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_tasks',
  });

  @GET('/activity_task_manager')
  Future<AndroidProcesses> getAndroidProcess({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_running_apps',
  });

  /// 停止App
  /// stop app by package
  @GET('/activity_manager')
  Future<String> stopActivity({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("package") String? package,
    @Query("action") String action = "stop_activity",
  });

  @GET('/display_manager')
  Future<Displays> display({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = "getDisplays",
  });

  @POST('/display_manager?action=createVirtualDisplay')
  Future<Display> createVirtualDisplay({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("width") required String width,
    @Query("height") required String height,
    @Query("density") required String density,
    @Query("useDeviceConfig") bool? useDeviceConfig,
  });

  @GET('/device_info')
  Future<CPUGPUInfo> cpu_gpu_info({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = "cpu_gpu_info",
  });

  // {{base}}/device_info?action=proc_stat&key={{key}}

  @GET('/device_info')
  Future<String> getProcStat({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = "proc_stat",
  });
}
