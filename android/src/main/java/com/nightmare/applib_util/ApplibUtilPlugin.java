package com.nightmare.applib_util;

import android.util.Log;

import com.nightmare.applib.AppServer;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


/**
 * ApplibUtilPlugin
 */
public class ApplibUtilPlugin implements FlutterPlugin, MethodCallHandler {

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d("ApplibUtilPlugin","test");
        try {
            int port = AppServer.startServerFromActivity(flutterPluginBinding.getApplicationContext());
            Log.d("ApplibUtilPlugin","port -> " + port);
        } catch (Exception e) {
            Log.d("ApplibUtilPlugin","error -> " + e);
            e.printStackTrace();
        }
        Log.d("ApplibUtilPlugin","test1");
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}
