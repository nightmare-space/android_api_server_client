import 'package:flutter/material.dart';

/// 需要实现一个 App Icon 的 Widget
/// 先从缓存中查是否有某个 App 的 Icon，如果没有先下载
/// 之前的策略是，每个 Icon 都作为网络图片从目标设备中加载
/// 这样对客户端到没啥影响，但会影响目标设备
/// 例如使用小米设备查看魅族设备上的应用列表


class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}