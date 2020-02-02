package xmly.com.flutter_app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;

public class MainActivity extends FlutterActivity {

    //channel的名称，由于app中可能会有多个channel，这个名称需要在app内是唯一的。
    private static final String CHANNEL_METHOD = "samples.flutter.io/battery";
    private static final String CHANNEL_EVENT = "samples.flutter.io/charging";

    private FlutterView mFlutterView;
    private MethodChannel mMethodChannel;
    private EventChannel mEventChannel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        mMethodChannel = new MethodChannel(flutterEngine.getDartExecutor(), CHANNEL_METHOD);
        mMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                if (methodCall.method.equals("getBatteryLevel")) {
                    int batterLevel = getBatteryLevel();
                    if (batterLevel != -1) {
                        result.success(batterLevel);
                    } else {
                        result.error("UNAVAIABLE", "无法获取电池信息", null);
                    }
                }
                else if (methodCall.method.equals("invokeFlutterMethod")) {
                    invokeFlutterMethod();
                }
                else {
                    result.notImplemented();
                }
            }
        });
        mEventChannel = new EventChannel(flutterEngine.getDartExecutor(), CHANNEL_EVENT);
        mEventChannel.setStreamHandler(new EventChannel.StreamHandler() {

            // 接收电池广播的BroadcastReceiver。
            private BroadcastReceiver chargingStateChangeReceiver;
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                chargingStateChangeReceiver = createChargingStateChangeReceiver(eventSink);
                registerReceiver(chargingStateChangeReceiver, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            }

            @Override
            public void onCancel(Object o) {
                unregisterReceiver(chargingStateChangeReceiver);
                chargingStateChangeReceiver = null;
            }
        });
    }

    private BroadcastReceiver createChargingStateChangeReceiver(final EventChannel.EventSink events) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                int status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1);

                if (status == BatteryManager.BATTERY_STATUS_UNKNOWN) {
                    events.error("UNAVAILABLE", "Charging status unavailable", null);
                } else {
                    boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL;
                    // 把电池状态发给Flutter
                    events.success(isCharging ? "charging" : "discharging");
//                    events.endOfStream();
                }
            }
        };
    }

    private void invokeFlutterMethod() {
        mMethodChannel.invokeMethod("getName", null, new MethodChannel.Result() {
            @Override
            public void success(Object o) {
                Log.d("flutter", "Native. success: " + o);
            }

            @Override
            public void error(String s, String s1, Object o) {
                Log.d("flutter", "Native error: " + s);
            }

            @Override
            public void notImplemented() {
                Log.d("flutter", "notImplemented.");
            }
        });
    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        return batteryLevel;
    }
}
