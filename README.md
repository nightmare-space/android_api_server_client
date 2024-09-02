# app_channel
Flutter Plugin

根据 applib 的协议用 dart 进行实现，实现 applib server 的自启动

这样像 SpeedShare、ADB KIT、Uncon 只需要依赖这个插件，插件在 native 层就会自动启动 applib server

由于 applib 是一个基于 HTTP 的服务，所以 AppChannel 的存在是为了将这些接口使用 Dart 编写

可以以 Dart API 调用的方式获取设备的信息

## Example
只是为了方便调试 Plugin，使用 Android Studio 打开 example 下的安卓工程


