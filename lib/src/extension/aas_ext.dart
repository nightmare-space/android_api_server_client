import 'package:android_api_server_client/android_api_server_client.dart';

extension AASExt on AASClient {
  void initSymbol() {
    String currentPackage = 'com.example.android_api_server_client_example';
    apis = {
      '/activity_manager?action=get_all_app_info': () async {
        List<T> getFirstTwoElements<T>(List<T> list) {
          if (list.length >= 2) {
            return list.sublist(0, 2);
          }
          return list;
        }

        AppInfos infos = await getAllAppInfos(isSystemApp: false);
        return AppInfos(infos: getFirstTwoElements(infos.infos));
      },
      '/activity_manager?action=get_app_detail': () {
        return getAppDetails(package: currentPackage);
      },
      '/activity_manager?action=get_app_activities': () {
        return getAppActivitys(package: currentPackage);
      },
      '/activity_manager?action=app_main_activity': () {
        return getAppMainActivity(package: currentPackage);
      },
      '/package_manager?action=get_permissions': () {
        return getAppPermission(package: currentPackage);
      },
      '/display_manager?action=getDisplays': () {
        return getDisplays();
      },
      '/icon': () {
        return iconUrl(currentPackage);
      },
      '/start_activity': () {
        return startActivity(
          package: 'com.android.settings',
          activity: 'com.android.settings.Settings',
        );
      },
      '/stop_activity': () {
        return stopActivity(package: 'com.android.settings');
      },
      '/tasks': getTasks,
      '/tasks_thumbnail': () {},
    };
  }
}
