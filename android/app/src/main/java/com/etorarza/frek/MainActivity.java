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

  private String sharedText = "";
  private static final String CHANNEL = "app.channel.shared.data";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Intent intent = getIntent();
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


    sharedText+= "action: " + action + " | ";
    sharedText+= "type: " +  type + " | ";
    sharedText+= "data: " +  data + " | ";
    sharedText+= "path: " +  path + " | ";

    if (Intent.ACTION_SEND.equals(action) || Intent.ACTION_VIEW.equals(action)) {

      sharedText += "intent match | ";
      
      try {
        // https://stackoverflow.com/questions/31069556/android-read-text-file-from-uri
        InputStream in = getContentResolver().openInputStream(uri);


        BufferedReader r = new BufferedReader(new InputStreamReader(in));
        StringBuilder total = new StringBuilder();
        for (String line; (line = r.readLine()) != null; ) {
            total.append(line).append('\n');
        }
        String content = total.toString();
        sharedText += "read_content:" + content + "|";


    }catch (Exception e) {
        sharedText += "error on read: " + e.toString() + "|";
    }

     }
  }
  

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
      GeneratedPluginRegistrant.registerWith(flutterEngine);

      new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
              .setMethodCallHandler(
                      (call, result) -> {
                          if (call.method.contentEquals("getSharedText")) {
                              result.success(sharedText);
                              sharedText = null;
                          }
                      }
              );
  }

  void handleSendText(Intent intent) {
    //sharedText += intent.getStringExtra(Intent.EXTRA_TEXT);
  }



}
