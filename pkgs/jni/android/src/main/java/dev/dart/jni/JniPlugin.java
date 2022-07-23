package dev.dart.jni;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import android.util.Log;
import android.app.Activity;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import android.content.Context;

@Keep
public class JniPlugin implements FlutterPlugin, ActivityAware {
  
  @Override
  public void
  onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
	  setup(binding.getApplicationContext());
  }

  public static void registerWith(Registrar registrar) {
    JniPlugin plugin = new JniPlugin();
	plugin.setup(registrar.activeContext());
  }

  private void setup(Context context) {
	initializeJni(context, getClass().getClassLoader());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  // Activity handling methods
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
	Activity activity = binding.getActivity();
	setJniActivity(activity, activity.getApplicationContext());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {}

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
	Activity activity = binding.getActivity();
	setJniActivity(activity, activity.getApplicationContext());
  }

  @Override
  public void onDetachedFromActivity() {}

  native void initializeJni(Context context, ClassLoader classLoader);
  native void setJniActivity(Activity activity, Context context);

  static {
	System.loadLibrary("dartjni");
  }
}

