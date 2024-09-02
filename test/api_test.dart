import 'dart:io';

import 'package:app_channel/interface/app_channel.dart';
import 'package:app_channel/model/model.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:signale/signale.dart';

void main() async {
  int port = 15000;
  AppChannel channel = AppChannel(port: port);
  String testPackageName = 'com.nightmare.speedshare';

  test('Get App Infos', () async {
    AppInfos infos = await channel.getAppInfosV2();
    AppInfos logInfo = AppInfos(infos: infos.infos.take(3).toList());
    Log.i('Get App Infos -> $logInfo');
    expect(infos, isNotNull);
  });

  test('Get App Detail', () async {
    String detail = await channel.getAppDetails(testPackageName);
    Log.i('Get App Detail -> $detail');
    expect(detail, isNotNull);
  });

  test('Get App Main Activity', () async {
    String detail = await channel.getAppMainActivity(testPackageName);
    Log.i('Get App Main Activity -> $detail');
    expect(detail, isNotNull);
  });

  test('Get App Permission Content', () async {
    List<String> permissions = await channel.getAppPermission(testPackageName);
    Log.i('Get App Permission Content -> $permissions');
    expect(permissions, isNotNull);
  });

  test('Execute CMD', () async {
    String result = await channel.execCMD('pwd');
    Log.i('Execute CMD -> $result');
    expect(result, isNotNull);
  });

  test('Create Virtual Display With SurfaceView', () async {
    Display? display = await channel.createVirtualDisplayWithSurfaceView(
      useDeviceConfig: true,
    );
    Log.i('Create Virtual Display With SurfaceView -> $display');
    expect(display, isNotNull);
  });

  test('Get Displays', () async {
    Displays displays = await channel.getDisplays();
    Log.i('Get Displays -> $displays');
    expect(displays, isNotNull);
  });

  test('Get App Icon', () async {
    String downloadPath = Directory.current.path + '/test.png';
    // get header first
    Response response = await Dio().head(channel.iconUrl(testPackageName));
    Headers headers = response.headers;
    await Dio().download(channel.iconUrl(testPackageName), downloadPath);
    await Process.start(
      'bash',
      ['-c','viu -w 40 -h 20 $downloadPath'],
      mode: ProcessStartMode.inheritStdio,
    );
    expect(headers, isNotNull);
  });
  
  test('Get Tasks', () async {
    Tasks tasks = await channel.getTasks();
    Log.i('Get tasks -> $tasks');
    expect(tasks, isNotNull);
  });
}
