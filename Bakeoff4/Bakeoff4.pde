import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;
import android.app.Activity;
import android.content.Context;
import android.os.Vibrator;
 
 
Activity act;

PImage bg;
KetaiSensor sensor;
float angleCursor = 0;
float light = 0; 
// global: target correctness check
boolean rightTarget = false;
float accel = 0;
float proxSensorThreshold = 0.5; //you will need to change this per your device.

float accelerometerX, accelerometerY, accelerometerZ;
int prevTarget = -1;
boolean showedText = false;

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
int coolingPeriod = 0;

void setup() {
  //size(480, 960); //you can change this to be fullscreen
  //frameRate(30);
  
  orientation(PORTRAIT);
  bg = loadImage("phone.png");
  sensor = new KetaiSensor(this);
  sensor.start();
  //sensor.enableMagenticField();
  //sensor.enableOrientation();

  //rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);
  noStroke(); //no stroke
  
  act = this.getActivity();
  
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
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  println("light val: " + light);
  background(255); //background is light grey
  image(bg, 20, 20, width-35, height-30);
  countDownTimerWait--;
  coolingPeriod--;

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
  
  
  
  // draw highlighted rectangle
  for (int i=0; i<4; i++)
  {
    //pushMatrix();
    if (targets.get(index).target==0) {
      noFill();
      rect(0,0,width/2,height/2);
      stroke(0,255,0);
      strokeWeight(5);
    }
    else if (targets.get(index).target==1) {
      noFill();
      rect(width/2,0,width/2,height/2);
      stroke(0,255,0);
      strokeWeight(5);
    }
    else if (targets.get(index).target==2) {
      noFill();
      rect(width/2,height/2,width/2,height/2);
      stroke(0,255,0);
      strokeWeight(5);
    }
    else {
      noFill();
      rect(0,height/2,width/2,height/2);
      stroke(0,255,0);
      strokeWeight(5);
    }
    //popMatrix();
  } 
  //println("target: " + targets.get(index).target);

//code to draw four target dots in a grid
  //for (int i=0; i<4; i++)
  //{
  //  pushMatrix();
  //  translate(width/2, height/2);
  //  rotate(radians(i*90 - 135));
  //  translate(150,0); 

  //  if (targets.get(index).target==i) // colorize target
  //    fill(0, 255, 0);
  //  else
  //    fill(180, 180, 180);

  //  rect(0,0, 100, 150);
  //  text(i, 100,100);
  //  popMatrix();
  //}

  //pushMatrix();
  //translate(width/2,height/2);
  //rotate(radians(angleCursor));
  ////rect(140,0, 50, 50);
  //popMatrix();

  fill(40); // dark grey //white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  //text("Target #" + (targets.get(index).target), width/2, 100);

  // tells you to cover if action==1 and uncover if action==0, show only if phase 1 is right
  if (rightTarget) {
    showedText = true;
    if (targets.get(index).action==1)
      text("COVER", width/2, 150);
    else
      text("DON'T COVER", width/2, 150);
  }
  

  //debug output only, slows down rendering
  //text("light level:" + int(light), width/2, height-100);
  //text("z-axis accel: " + nf(accel,0,1), width/2, height-50); //use this to check z output!
  //text("touching target #" + hitTest(), width/2, height-150); //use this to check z output!

}

void onLightEvent(float v) //this just updates the light value
{
  light = v; //update global variable
}

void onAccelerometerEvent(float x, float y, float z)
{
  //accel = z-9.8;//update global variable and subtract gravity (9.8 newtons)

  if (userDone || trialIndex>=targets.size())
    return;

  Target t = targets.get(trialIndex);

  if (t==null)
    return;


  //println("getTarget=", getTarget(x,y,z));
  if (countDownTimerWait<0 && coolingPeriod <= 0) {
    int curTarget = getTarget(x,y,z);
    if (prevTarget == -1 || prevTarget != curTarget) {
      prevTarget = curTarget;
    } else { // the user has stayed on this target for 0.5 seconds. Check to see if hit
      if (prevTarget == t.target) { //check if it is the right target
        // passed phase 1
        println("Right target, right z direction!");
        // setting rightTarget = true will cause the "cover" or "don't cover" text to appear
        rightTarget = true;
        // sets curAction to the user's current action
        int curAction = 0;
        if (light <= proxSensorThreshold)
          curAction = 1;
        // check if current action matches correct action
        if (showedText && curAction == t.action) {
          println("passed phase 2");
          trialIndex++; //next trial!
          Vibrator vibrer = (Vibrator) act.getSystemService(Context.VIBRATOR_SERVICE);
          vibrer.vibrate(100);
          
          showedText = false;
          prevTarget = -1;
          rightTarget = false; // next trial's will start out as worng
        }
      } else {
        if (trialIndex>0) {
          trialIndex--; //move back one trial as penalty!
          //println("right target, WRONG z direction!");
          prevTarget = -1;
          rightTarget = false; // next trial's will start out as worng
        }
      }
      // add a next trail cooling period
      coolingPeriod = 20;
    
    }
    countDownTimerWait = 20; // a timer for 0.5 seconds
    
  }


  /////////////////////////////////////////////////////
  //if (light<=proxSensorThreshold && abs(accel)>4 && countDownTimerWait<0) //possible hit event
  //{
  //  if (hitTest()==t.target)//check if it is the right target
  //  {
  //    if (((accel)>4 && t.action==0) || ((accel)<-4 && t.action==1))
  //    {
  //      //println("Right target, right z direction!");
  //      trialIndex++; //next trial!
  //    } 
  //    else
  //    {
  //      if (trialIndex>0)
  //        trialIndex--; //move back one trial as penalty!
  //      //println("right target, WRONG z direction!");
  //    }
  //    countDownTimerWait=10; //wait roughly 0.5 sec before allowing next trial
  //  } 
  //} 
  //else if (light<=proxSensorThreshold && countDownTimerWait<0 && hitTest()!=t.target)
  //{ 
  //  //println("wrong round 1 action!"); 
  //  if (trialIndex>0)
  //    trialIndex--; //move back one trial as penalty!

  //  countDownTimerWait=10; //wait roughly 0.5 sec before allowing next trial
  //}
}

int getTarget(float x, float y, float z) {
  // looking down
  if (z >= 0) {
    if (x >= 0) {
      return 2;
    } else {
      return 3;
    }
  // looking up
  } else {
    if (x >= 0) {
      return 0;
    } else {
      return 1;
    }
  }
}
