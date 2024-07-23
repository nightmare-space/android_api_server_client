import 'package:app_channel/foundation/app_info.dart';
import 'package:app_channel/interface/app_channel.dart';
import 'package:signale/signale.dart';

void main() async {
  AppInfos infos = await RemoteAppChannel(port: 15000).getAppInfosV2();
  Log.i('infos -> $infos');
}
