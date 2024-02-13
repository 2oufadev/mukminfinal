/*
 * Copyright 2017 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.alamintijarahresources.mukminapps.videoplayer;


import static com.alamintijarahresources.mukminapps.VideoPlayer360Plugin.SHOW_PLACEHOLDER;

import android.Manifest.permission;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.alamintijarahresources.mukminapps.R;
import com.alamintijarahresources.mukminapps.videoplayer.rendering.Mesh;
import com.google.vr.ndk.base.DaydreamApi;


/**
 * Basic Activity to hold {@link MonoscopicView} and render a 360 video in 2D.
 *
 * Most of this Activity's code is related to Android & VR permission handling. The real work is in
 * MonoscopicView.
 *
 * The default intent for this Activity will load a 360 placeholder panorama. For more options on
 * how to load other media using a custom Intent, see {@link MediaLoader}.
 */
public class VideoActivity extends Activity implements SensorEventListener {
  private static final String TAG = "VideoActivity";
  private static final int READ_EXTERNAL_STORAGE_PERMISSION_ID = 1;
  private MonoscopicView videoView;

  public static View loadingProgressView;
  private View viewTiltInstruction;
  private ImageView navigator;
  private LinearLayout layout_campass;
  // record the compass picture angle turned
  private float currentDegree = 0f;
  private float currentDegree2 = 0f;
  private float currentDegree3 = 0f;
  private final float[] phoneInWorldSpaceMatrix = new float[16];
  private final float[] remappedPhoneMatrix = new float[16];
  private final float[] angles = new float[3];
  // device sensor manager
  private SensorManager mSensorManager;
  /**
   * Checks that the appropriate permissions have been granted. Otherwise, the sample will wait
   * for the user to grant the permission.
   *
   * @param savedInstanceState unused in this sample but it could be used to track video position
   */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.video_activity);

    // Configure the MonoscopicView which will render the video and UI.
    loadingProgressView = findViewById(R.id.loading_progress_view);
    viewTiltInstruction = findViewById(R.id.view_tilt_instruction);
    layout_campass = findViewById(R.id.layout_campass);



    videoView = (MonoscopicView) findViewById(R.id.video_view);
    VideoUiView videoUi = (VideoUiView) findViewById(R.id.video_ui_view);
    videoUi.setVrIconClickListener(
        new OnClickListener() {
          @Override
          public void onClick(View v) {
            // Convert the Intent used to launch the 2D Activity into one that can launch the VR
            // Activity. This flow preserves the extras and data in the Intent.
            DaydreamApi api =  DaydreamApi.create(VideoActivity.this);
            if (api != null){
              // Launch the VR Activity with the proper intent.
              Intent intent = DaydreamApi.createVrIntent(
                  new ComponentName(VideoActivity.this, VrVideoActivity.class));
              intent.setData(getIntent().getData());
              intent.putExtra(
                  MediaLoader.MEDIA_FORMAT_KEY,
                  getIntent().getIntExtra(MediaLoader.MEDIA_FORMAT_KEY, Mesh.MEDIA_MONOSCOPIC));
              api.launchInVr(intent);
              api.close();
            } else {
              // Fall back for devices that don't have Google VR Services. This flow should only
              // be used for older Cardboard devices.
              Intent intent =
                  new Intent(getIntent()).setClass(VideoActivity.this, VrVideoActivity.class);
              intent.removeCategory(Intent.CATEGORY_LAUNCHER);
              intent.setFlags(0);  // Clear any flags from the previous intent.
              startActivity(intent);
            }

            // See VrVideoActivity's launch2dActivity() for more info about why this finish() call
            // may be required.
            finish();
          }
        });
    videoView.initialize(videoUi);


    // Boilerplate for checking runtime permissions in Android.
//    if (ContextCompat.checkSelfPermission(this, permission.READ_EXTERNAL_STORAGE)
//        != PackageManager.PERMISSION_GRANTED) {
//      View button = findViewById(R.id.permission_button);
//      button.setOnClickListener(
//          new OnClickListener() {
//            @Override
//            public void onClick(View v) {
//              ActivityCompat.requestPermissions(
//                  VideoActivity.this,
//                  new String[] {permission.READ_EXTERNAL_STORAGE},
//                  READ_EXTERNAL_STORAGE_PERMISSION_ID);
//            }
//          });
//      // The user can click the button to request permission but we will also click on their behalf
//      // when the Activity is created.
//      button.callOnClick();
//    } else {
      // Permission has already been granted.
      initializeActivity();
   // }

    // this should be after initializeActivity()
    if (SHOW_PLACEHOLDER) {
      // check if have to display placeholder (tilt instructions)
      showPlaceholder();
    } else {
      viewTiltInstruction.setVisibility(View.GONE);
    }
    // image = (ImageView) findViewById(R.id.imageViewCompass);
    // imageViewCompass1 = (ImageView) findViewById(R.id.imageViewCompass1);
    navigator = (ImageView) findViewById(R.id.navigator);
    mSensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
  }

  private void showPlaceholder() {
    viewTiltInstruction.setVisibility(View.VISIBLE);

    Runnable timerRunnable = new Runnable() {
      @Override
      public void run() {

        Animation animFadeOut = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.fade_out);
        viewTiltInstruction.startAnimation(animFadeOut);
        animFadeOut.setAnimationListener(new Animation.AnimationListener() {
          @Override
          public void onAnimationStart(Animation animation) {}

          @Override
          public void onAnimationEnd(Animation animation) {
            viewTiltInstruction.setVisibility(View.GONE);
          }

          @Override
          public void onAnimationRepeat(Animation animation) {}
        });
      }
    };


    new Handler().postDelayed(timerRunnable, 2000);
  }

  /** Handles the user accepting the permission. */
  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] results) {
    if (requestCode == READ_EXTERNAL_STORAGE_PERMISSION_ID) {
      if (results.length > 0 && results[0] == PackageManager.PERMISSION_GRANTED) {
        initializeActivity();
      }
    }
  }

  /**
   * Normal apps don't need this. However, since we use adb to interact with this sample, we
   * want any new adb Intents to be routed to the existing Activity rather than launching a new
   * Activity.
   */
  @Override
  protected void onNewIntent(Intent intent) {
    // Save the new Intent which may contain a new Uri. Then tear down & recreate this Activity to
    // load that Uri.
    setIntent(intent);
    recreate();
  }

  /** Initializes the Activity only if the permission has been granted. */
  private void initializeActivity() {
    ViewGroup root = (ViewGroup) findViewById(R.id.activity_root);
    for (int i = 0; i < root.getChildCount(); ++i) {
      root.getChildAt(i).setVisibility(View.VISIBLE);
    }
    findViewById(R.id.permission_button).setVisibility(View.GONE);
    videoView.loadMedia(getIntent());
  }

  @Override
  protected void onResume() {
    super.onResume();
    videoView.onResume();
    mSensorManager.registerListener(this, mSensorManager.getDefaultSensor(Sensor.TYPE_ORIENTATION), SensorManager.SENSOR_DELAY_GAME);
    mSensorManager.registerListener(rotationSensor, mSensorManager.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR), SensorManager.SENSOR_DELAY_FASTEST);

  }

  @Override
  protected void onPause() {
    // MonoscopicView is a GLSurfaceView so it needs to pause & resume rendering. It's also
    // important to pause MonoscopicView's sensors & the video player.
    videoView.onPause();
    super.onPause();
    mSensorManager.unregisterListener(this);
    mSensorManager.unregisterListener(rotationSensor);
  }

  @Override
  protected void onDestroy() {
    videoView.destroy();
    super.onDestroy();
  }

  @Override
  public void onSensorChanged(SensorEvent event) {
    // get the angle around the z-axis rotated
    float degree = Math.round(event.values[0]);

    // create a rotation animation (reverse turn degree degrees)
    RotateAnimation ra = new RotateAnimation(
            currentDegree,
            -degree,
            Animation.RELATIVE_TO_SELF, 0.5f,
            Animation.RELATIVE_TO_SELF,
            0.5f);

    // how long the animation will take place
    ra.setDuration(210);
    // set the animation after the end of the reservation status
    ra.setFillAfter(true);
    // Start the animation
    // image.startAnimation(ra);
    currentDegree = -degree;

  }
  public SensorEventListener  rotationSensor=new SensorEventListener() {
    @Override
    public void onSensorChanged(SensorEvent event) {
      SensorManager.getRotationMatrixFromVector(phoneInWorldSpaceMatrix, event.values);
      SensorManager.remapCoordinateSystem(
              phoneInWorldSpaceMatrix,
              SensorManager.AXIS_X, SensorManager.AXIS_MINUS_Z,
              remappedPhoneMatrix);
     SensorManager.getOrientation(remappedPhoneMatrix, angles);


      // Optionally convert the result from radians to degrees
      angles[0] = (float) Math.toDegrees(angles[0]);
      angles[1] = (float) Math.toDegrees(angles[1]);
      angles[2] = (float) Math.toDegrees(angles[2]);

      float degree = Math.round(angles[0]);
      float degreeY = Math.round(angles[2]);


      RotateAnimation ra2 = new RotateAnimation(
              currentDegree2,
              -degree+degreeY,
              Animation.RELATIVE_TO_SELF, 0.5f,
              Animation.RELATIVE_TO_SELF,
              0.5f);
      RotateAnimation ra3 = new RotateAnimation(
              currentDegree3,
              degree+degreeY,
              Animation.RELATIVE_TO_SELF, 0.5f,
              Animation.RELATIVE_TO_SELF,
              0.5f);

      // how long the animation will take place
      ra2.setDuration(210);
      ra3.setDuration(210);

      // set the animation after the end of the reservation status
      ra2.setFillAfter(true);
      ra3.setFillAfter(true);

      // Start the animation
      // imageViewCompass1.startAnimation(ra2);
      navigator.startAnimation(ra3);
      currentDegree2 = -degree+degreeY;
      currentDegree3 =  degree+degreeY;
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {

    }
  };

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {

  }
}
