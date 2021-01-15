package com.etorarza.frek;

import java.io.*;
import java.net.URI;

import android.content.Intent;
import android.os.Bundle;
import android.net.Uri;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private String sharedText = null;
  private static final String CHANNEL = "app.channel.shared.data";


  private String getStringFromIntentOnResume(Intent intent)
  {
    return _getStringFromIntentFile(intent);
  }


  private String getStringFromIntentOnInitialize()
  {
    Intent intent = getIntent();
    return _getStringFromIntentFile(intent);
  }

  private String _getStringFromIntentFile(Intent intent) {
    String res = "";
    String action = intent.getAction();
    String type = intent.getType();
    String data = intent.getDataString();
    Uri uri = intent.getData();
    String path = "null";

    if (action == null) {
      action = "null";
    }
    if (type == null) {
      type = "null";
    }
    if (data == null) {
      data = "null";
    }
    if (uri != null) {
      path = uri.getPath();
    }

    // debug
    // if (true) {
    //   return "path: "+ path + "   action:" + action + "  data:" + data;
    // }

    if (Intent.ACTION_SEND.equals(action) || Intent.ACTION_VIEW.equals(action)) {

      // String[] splittedPath = path.split("\\.");
      // if (splittedPath.length < 2) {
      //   return "";
      // }

      // if (splittedPath[splittedPath.length - 1].equals("FrekDB")
      //     || (splittedPath[splittedPath.length - 2].equals( "FrekDB") && splittedPath[splittedPath.length - 1].equals( "bin"))) {
      //   res += "FrekDB.";
      // } else if (splittedPath[splittedPath.length - 1].equals( "FrekCard")
      //     || (splittedPath[splittedPath.length - 2].equals( "FrekCard") && splittedPath[splittedPath.length - 1].equals( "bin"))) {
      //   res += "FrekCard.";
      // } else if (splittedPath[splittedPath.length - 1].equals( "FrekCollection")
      //     || (splittedPath[splittedPath.length - 2].equals( "FrekCollection") && splittedPath[splittedPath.length - 1].equals( "bin"))) {
      //   res += "FrekCollection.";
      // } else {
      //   return "";
      // }

      try {
        // https://stackoverflow.com/questions/31069556/android-read-text-file-from-uri
        InputStream in = getContentResolver().openInputStream(uri);

        BufferedReader r = new BufferedReader(new InputStreamReader(in));
        StringBuilder total = new StringBuilder();
        for (String line; (line = r.readLine()) != null;) {
          total.append(line).append('\n');
        }
        if( total.length() > 0 )
        {
          total.deleteCharAt(total.length() - 1);
        }
        String content = total.toString();
        res += content;

      } catch (Exception e) {
        res = "file_read_error:" + e.toString();
      }

    }
    return res;
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    sharedText = getStringFromIntentOnInitialize();
  }


  @Override
  protected void onNewIntent(Intent intent) {
      // Handle intent when app is resumed
      super.onNewIntent(intent);
      sharedText = getStringFromIntentOnResume(intent);
    }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler((call, result) -> {
          if (call.method.contentEquals("getSharedText")) {
            result.success(sharedText);
            sharedText = null;
          }
        });
  }

}
