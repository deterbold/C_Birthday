// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 16-14: Overall motion

import processing.video.*;

// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;

// How different must a pixel be to be a "motion" pixel
float threshold = 50;
float avgMotion;

//Gameplay variables
boolean snakeSleep;
boolean snakeAlert;
boolean gameOver;

//timer stuff
int time;
int wait = 5000;
boolean timerRunning;
boolean pauseTimer;

//game states 
//0 = intro
//1 = game
//2 = game over
//3 = victory
int gameState;

//cheesy UI
PImage sleepingSnake;
PImage alertSnake;
PImage victorySnake;
PImage defeatSnake;

boolean debug;


void setup() 
{
  size(800, 800);
  // Using the default capture device
  video = new Capture(this, width, height);
  video.start();
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);

  //gameplay variables start here
  snakeSleep = true;
  snakeAlert = false;

  //timer stuff
  timerRunning = false;
  pauseTimer = false;
  time = millis();

  //game state
  gameState = 0;

  //cheesy UI
  sleepingSnake = loadImage("sleepingSnake.jpg");
  alertSnake = loadImage("alertSnake.jpg");
  victorySnake = loadImage("victorySnake.jpg");
  defeatSnake = loadImage("defeatSnake.jpg");

  //debug stuff
  PFont p = createFont("Georgia", 14);
  textFont(p, 14);
  smooth();
  debug = true;
}

// New frame available from camera
void captureEvent(Capture video) 
{
  // Save previous frame for motion detection!!
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();
  video.read();
}

void draw() 
{
  switch(gameState)
  {
    case 0:
      runIntro();
      break;
    case 1:
      runGame();
      break;
    case 2:
      runDefeat();
      break;
    case 3:
      runVictory();
      break;
  }

  motionDetection();
  
  if(debug)
  {
    runDebug();
  }
}

void runIntro()
{
  background(0);
  fill(255, 255, 0);
  textSize(72);
  text("tryk!", width/2, height/2);
  if(keyPressed)
  {
    gameState = 1;
  }
}

void runGame()
{
  if(snakeSleep)
  {
    image(sleepingSnake, 0 , 0);

    if(avgMotion > 9)
    {
      time = millis();
      timerRunning = true;
      snakeSleep = false;
      snakeAlert = true;
    }

    if(keyPressed)
    {
      gameState = 3;
    }
  }

  if(snakeAlert)
  {
    image(alertSnake, 0, 0);
    if(avgMotion > 12)
      {
        gameState = 2;
      }
  }
  
  if(timerRunning)
  {
    runTimer();
  }
} 

void runDefeat()
{
  image(defeatSnake, 0, 0);
  fill(255, 0, 0);
  textSize(72);
  text("Øv!", width/2, height/2);
  if(keyPressed)
  {
    gameState = 0;
  }
}

void runVictory()
{
  image(victorySnake, 0, 0);
  fill(0, 255, 0);
  textSize(72);
  text("Sej!", width/2, height/2);
  if(keyPressed)
  {
    gameState = 0;
  }

}

void runDebug()
{
  //background(0, 0, 0);
  fill(0, 0, 255);
  textSize(32);
  text(avgMotion, width/2, 75);
  text("game state: ", width/2 - 200, 125);
  text(gameState, width/2, 125);
  println("snakeAlert: "+snakeAlert);
}

void motionDetection()
{
  // You don't need to display it to analyze it!
  //image(video, 0, 0);

  video.loadPixels();
  prevFrame.loadPixels();

  // Begin loop to walk through every pixel
  // Start with a total of 0
  float totalMotion = 0;

  // Sum the brightness of each pixel
  for (int i = 0; i < video.pixels.length; i ++ ) {
    // Step 2, what is the current color
    color current = video.pixels[i];

    // Step 3, what is the previous color
    color previous = prevFrame.pixels[i];

    // Step 4, compare colors (previous vs. current)
    float r1 = red(current); 
    float g1 = green(current);
    float b1 = blue(current);
    float r2 = red(previous); 
    float g2 = green(previous);
    float b2 = blue(previous);

    // Motion for an individual pixel is the difference between the previous color and current color.
    float diff = dist(r1, g1, b1, r2, g2, b2);
    // totalMotion is the sum of all color differences. 
    totalMotion += diff;
  }

  // averageMotion is total motion divided by the number of pixels analyzed.
  avgMotion = totalMotion / video.pixels.length; 
}

void mouseClicked()
{
  debug = !debug;
}

void runTimer()
{
  if(millis() - time >= wait)
  {
    timerRunning = false;
    snakeAlert = false;
    snakeSleep = true;
    time = millis();
  }
}