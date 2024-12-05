// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:android_api_server_client/src/model/model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' hide Headers;
part 'aas_api.g.dart';

@RestApi(baseUrl: "", parser: Parser.JsonSerializable)
abstract class Api {
  factory Api(Dio dio, {String baseUrl}) = _Api;

  @GET('/key')
  Future<String> setKey({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
  });

  @GET('/activity_manager')
  Future<AppInfos> getAllAppInfos({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_all_app_info',
    @Query("is_system_app") bool? isSystemApp,
  });

  /// 获取应用详情
  /// get app detail
  @GET('/activity_manager')
  Future<AppDetail> getAppDetail({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_app_detail',
    @Query("package") String? package,
  });

  /// 通过包名获取 MainActivity
  /// get main activity by package
  @GET('/activity_manager')
  Future<AppMainActivity> getAppMainActivity({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'app_main_activity',
    @Query("package") String? package,
  });

  /// 通过包名获取 所有的 Activitys
  /// get all activitys by package
  @GET('/activity_manager')
  Future<AppActivitys> getAppActivity({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_app_activities',
    @Query("package") String? package,
  });

  /// 启动App
  /// open app by package
  @GET('/activity_manager')
  Future<DefaultMap> startActivity({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'start_activity',
    @Query("package") String? package,
    @Query("activity") String? activity,
    @Query("displayId") String? displayId,
  });

  @GET('/activity_manager')
  Future<Tasks> getTasks({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_tasks',
  });

  /// 通过包名获取所有的 Permission
  /// get all permissions by package
  @GET('/package_manager')
  Future<AppPermissions> getAppPermissions({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = 'get_permissions',
    @Query("package") String? package,
  });

  /// 停止App
  /// stop app by package
  @GET('/stop_activity')
  Future<String> stopActivity({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("package") String? package,
  });

  @GET('/display_manager')
  Future<Displays> display({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("action") String action = "getDisplays",
  });

  @POST('/display?action=createVirtualDisplay')
  Future<Display> createVirtualDisplay({
    @DioOptions() RequestOptions? options,
    @Header("key") String? key,
    @Query("width") required String width,
    @Query("height") required String height,
    @Query("density") required String density,
    @Query("useDeviceConfig") bool? useDeviceConfig,
  });
}
