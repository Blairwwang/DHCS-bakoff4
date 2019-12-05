import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;
//import java.lang.Object;
//import android.speech.SpeechRecognizer;
//import android.speech.RecognitionListener;
//import android.content.Context;

import android.view.View;
import android.content.Context;
import android.widget.Button;
import android.app.Activity;
///import android.speech.SpeechRecognizer;//in the "easy way that is useless
import android.view.Gravity;//for my layout
import android.graphics.Color;//for the color of the button
///import android.speech.RecognitionListener;///useless for the "easy way"
import android.speech.RecognizerIntent;

import android.content.Intent;
//import android.os.Vibrator;///let us take problems one after the other!!!!!
import android.widget.Toast;
import java.lang.Throwable;
import java.lang.Exception;
import java.lang.RuntimeException;
import android.content.ActivityNotFoundException;
import java.util.Locale;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;
import android.view.View.OnClickListener;
import android.content.Context;
import android.speech.SpeechRecognizer;
import android.speech.RecognitionListener;

import android.os.BaseBundle;
import android.os.Bundle;
import android.content.Intent;

SpeechRecognizer sp;
Activity act;
Intent intent;
Button bouton;
private static final int MY_BUTTON1 = 9000;
FrameLayout fl;
Context context;
Bundle savedInstanceState;
RecognitionListener listener;



KetaiSensor sensor;
float angleCursor = 0;
float light = 0; 
float accel = 0;
float proxSensorThreshold = 20; //you will need to change this per your device.

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;

  //public void onStart(){
  //  startSpeech();
  //}

public void onStart(){
   act = this.getActivity();
 context = act.getApplicationContext();

 bouton = new Button(act);
bouton.setText("startspeech");
 bouton.setBackgroundColor(Color.WHITE);
  bouton.setId(MY_BUTTON1);
      
       OnClickListener oclMonBouton = new OnClickListener() {
       public void onClick(View v) {
         println("on m'a cliqué");
         startSpeech();///here the call for method 1;
         
     }
       };
     
    bouton.setOnClickListener(oclMonBouton);

      ///adding the button to the frameLayout (processing);

    fl = (FrameLayout)act.getWindow().getDecorView().getRootView();
       getActivity().runOnUiThread(new Runnable() {
     //@Override
     public void run() {
    
     FrameLayout.LayoutParams params1 = new FrameLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT,Gravity.TOP); 
                  // FrameLayout.LayoutParams params2 = new FrameLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT,Gravity.BOTTOM); //uncomment if you want change the button position (which can also be set with setX());
            
            fl.addView(bouton,params1);
   
    }
  });
}

private void startSpeech() {
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);///standard intent
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault());//choose the local language
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        intent.putExtra(RecognizerIntent.EXTRA_PROMPT,
                "hello world");///show a message to the user
        try {
            this.getActivity().startActivityForResult(intent, 666);///start Activity for result with some "code" (what you want) to "identify" your call
        } catch (ActivityNotFoundException a) {
            Toast.makeText(this.getActivity().getApplicationContext(),"désolé votre téléphone ne supporte pas cette fonction",
            Toast.LENGTH_SHORT).show();///error message in case that your phone cannot offer SpeechToText
        }
}


void onActivityResult(int requestCode, int resultCode, Intent data) {
       
        switch (requestCode) {
            case 666: {
              if (resultCode == Activity.RESULT_OK && null != data) {//data are returned && the phone can use speechToText
                  ArrayList<String> result = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
                  background(255);
                  text(result.get(0),width/2,height/2);
                  println("speech recognition result:");
                  println(result.get(0));
              }
              break;
            }
    }
}

void setup() {
 // size(800, 800); //you can change this to be fullscreen
  //frameRate(30);
  act = this.getActivity();
  //sp = SpeechRecognizer.createSpeechRecognizer(getActivity());
  orientation(PORTRAIT);
   
  sensor = new KetaiSensor(this);
  sensor.start();
  //sensor.enableMagenticField();
  //sensor.enableOrientation();
  
  rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);
  noStroke(); //no stroke

  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    //println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  onActivityResult(666,act.RESULT_OK,intent);
  
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey

  countDownTimerWait--;

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 2) + " sec per target", width/2, 150);
    return;
  }

//code to draw four target dots in a grid
  for (int i=0; i<4; i++)
  {
    pushMatrix();
    translate(width/2, height/2);
    rotate(radians(i*90));
    translate(150,0); 
    
    if (targets.get(index).target==i) // colorize target
      fill(0, 255, 0);
    else
      fill(180, 180, 180);
      
    ellipse(0,0, 100, 100);
    popMatrix();
  }

  if (light>proxSensorThreshold)
    fill(180, 0, 0);
  else
    fill(255, 0, 0);
    
  pushMatrix();
  translate(width/2,height/2);
  rotate(radians(angleCursor));
  rect(140,0, 50, 50);
  popMatrix();

  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  //text("Target #" + (targets.get(index).target), width/2, 100);

//only show phase two if the finger is down
if (light<=proxSensorThreshold)
{
  if (targets.get(index).action==0)
    text("Action: UP", width/2, 150);
  else
    text("Action: DOWN", width/2, 150);
}
  
  //debug output only, slows down rendering
  //text("light level:" + int(light), width/2, height-100);
  //text("z-axis accel: " + nf(accel,0,1), width/2, height-50); //use this to check z output!
  //text("touching target #" + hitTest(), width/2, height-150); //use this to check z output!
  
}

int hitTest()
{
  if (angleCursor>330 || angleCursor<30)
     return 0;
  else if (angleCursor>60 && angleCursor<120)
     return 1;
  else if (angleCursor>150 && angleCursor<210)
     return 2;
  else if (angleCursor>240 && angleCursor<300)
     return 3;
  else
    return -1;
}

//use gyro (rotation) to update angle
void onGyroscopeEvent(float x, float y, float z)
{
  if (light>proxSensorThreshold) //only update angle cursor if light is low / prox sensor covered
    angleCursor -= z*3; //cented to window and scaled
    if (angleCursor<0)
      angleCursor+=360; //never go below 0, keep it within 0-360
    angleCursor %= 360; //mod by 360 to keep it within 0-360
}

void onLightEvent(float v) //this just updates the light value
{
  light = v; //update global variable
}

void onAccelerometerEvent(float x, float y, float z)
{
  accel = z-9.8;//update global variable and subtract gravity (9.8 newtons)
  
  if (userDone || trialIndex>=targets.size())
    return;
    
  Target t = targets.get(trialIndex);

  if (t==null)
    return;
     
  if (light<=proxSensorThreshold && abs(accel)>4 && countDownTimerWait<0) //possible hit event
  {
    if (hitTest()==t.target)//check if it is the right target
    {
      if (((accel)>4 && t.action==0) || ((accel)<-4 && t.action==1))
      {
        //println("Right target, right z direction!");
        trialIndex++; //next trial!
      } 
      else
      {
        if (trialIndex>0)
          trialIndex--; //move back one trial as penalty!
        //println("right target, WRONG z direction!");
      }
      countDownTimerWait=10; //wait roughly 0.5 sec before allowing next trial
    } 
  } 
  else if (light<=proxSensorThreshold && countDownTimerWait<0 && hitTest()!=t.target)
  { 
    //println("wrong round 1 action!"); 
    if (trialIndex>0)
      trialIndex--; //move back one trial as penalty!

    countDownTimerWait=10; //wait roughly 0.5 sec before allowing next trial
  }
}
