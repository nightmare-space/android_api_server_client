import 'dart:io';

import 'package:android_api_server_client/src/client/aas_client.dart';
import 'package:android_api_server_client/src/model/model.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:signale/signale.dart';

void main() async {
  int port = 15000;
  AASClient client = AASClient(port: port);
  String testPackageName = 'com.nightmare.speedshare';

  await client.waitKeyGen();
  test('Get App Activitys', () async {
    AppActivitys activitys = await client.getAppActivitys(package: testPackageName);
    Log.i('activitys -> $activitys');
    expect(activitys, isNotNull);
  });

  test('Get App Flags', () async {
    AppFlags flags = await client.getAppFlags(package: testPackageName);
    Log.i('flags -> $flags');
    expect(flags, isNotNull);
  });

  test('Get App Details', () async {
    AppDetail detail = await client.getAppDetails(package: testPackageName);
    Log.i('detail -> $detail');
    expect(detail, isNotNull);
  });

  test('Get Apps Info', () async {
    AppInfos infos = await client.getAllAppInfos(isSystemApp: false);
    Log.i('infos -> ${infos.infos.first}');
    expect(infos, isNotNull);
  });

  test('Get App Main Activity', () async {
    AppMainActivity infos = await client.getAppMainActivity(package: testPackageName);
    Log.i('infos -> $infos');
    expect(infos, isNotNull);
  });

  test('Get App Permission', () async {
    AppPermissions permissions = await client.getAppPermission(package: testPackageName);
    Log.i('permissions -> ${permissions.datas.first}');
    expect(permissions, isNotNull);
  });

  test('Get App Icon', () async {
    String downloadPath = '${Directory.current.path}/test.png';
    // get header first
    Response response = await Dio().head(client.iconUrl(testPackageName));
    Headers headers = response.headers;
    await Dio().download(client.iconUrl(testPackageName), downloadPath);
    await Process.start(
      'bash',
      ['-c', 'viu -w 40 -h 20 $downloadPath'],
      mode: ProcessStartMode.inheritStdio,
    );
    File file = File(downloadPath);
    file.deleteSync();
    expect(headers, isNotNull);
  });

  test('Get Displays', () async {
    Displays displays = await client.getDisplays();
    Log.i('displays -> ${displays.datas.first}');
    expect(displays, isNotNull);
  });

  test('Get CPU GPU', () async {
    CPUGPUInfo infos = await client.api.cpu_gpu_info(key: 'aas');
    Log.i('Get CPU GPU -> $infos');
    expect(infos, isNotNull);
  });

  // test('Create Virtual Display With SurfaceView', () async {
  //   Display? display = await channel.createVirtualDisplayWithSurfaceView(
  //     useDeviceConfig: true,
  //   );
  //   Log.i('Create Virtual Display With SurfaceView -> $display');
  //   expect(display, isNotNull);
  // });

  // test('Get Start Activity', () async {
  //   await channel.startActivity(
  //     testPackageName,
  //     testPackageName + '.MainActivity',
  //     '0',
  //   );
  // });

  // test('Get Tasks', () async {
  //   Tasks tasks = await channel.getTasks();
  //   Log.i('Get tasks -> $tasks');
  //   expect(tasks, isNotNull);
  // });
}
