package com.nightmare.aas_client;

import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.nightmare.aas_integrated.AASIntegrate;

/**
 * AASClient
 */
public class AASClient implements FlutterPlugin, MethodCallHandler {
    // tag
    private static final String TAG = "AppChannelPlugin";
    static List<FlutterEngine> flutterEngines = new ArrayList<>();

    public static void addFlutterEngine(FlutterEngine flutterEngine) {
        Log.d(TAG, "addFlutterEngine -> " + flutterEngine);
        flutterEngines.add(flutterEngine);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        FlutterEngine flutterEngine = flutterPluginBinding.getFlutterEngine();
        if (flutterEngines.contains(flutterEngine)) {
            Log.d(TAG, "this engine do not need applib server");
            return;
        }
        try {
            int port = AASIntegrate.startServerFromActivity(flutterPluginBinding.getApplicationContext());
            Log.d(TAG, "port -> " + port);
        } catch (Exception e) {
            Log.d(TAG, "error -> " + e);
            e.printStackTrace();
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}
