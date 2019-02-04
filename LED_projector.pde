
//LED Projector v1
//Made at Jason Bruges Studio
//by Dhruv Kumar
//with Love

import controlP5.*;
import processing.serial.*;
import processing.video.*;

Serial arduino;
String[] ports;
int numRows;
int numColumns;
LED[][] led;
byte pat = 0;
int size = 10;
int cPicker = color(100);
long sendInterval = 60;
long lastTrigger = 0;
PImage img;
Movie movie;
boolean playVideo = false;
boolean bw = false;
boolean drag = false;
float globalB = .5;
int gridDistance = 50;
float gridRotation = 0;
int ledBox = 10;
int fading = 0;
PVector m;
color c;
int uiWidth = 170;

int baudr = 500000;

void setup() {
  //BASIC SETUP
  size(1200, 600);
  surface.setResizable(true);
  noStroke();
  smooth();
  rectMode(CENTER);
  strokeWeight(2);
  noFill();
  stroke(255);

  //GET LIST OF PORTS, SETUP THE FIRST ONE FOR NOW
  ports = Serial.list();
  arduino = new Serial(this, ports[0], baudr);

  //INITIALISE LED OBJECTS
  ledSetup();
  m = new PVector(width/2, height/2);

  //LOAD AN IMAGE AND VIDEO
  img = loadImage("gradient.jpg");
  movie = new Movie(this, "transit.mov");
  movie.loop();

  numRows = 8;
  numColumns = 1;
  createGUI();
}

void draw() {
  background(255);

  //PLAYVIDEO VARIABLE IS SET FROM THE UI, IMAGE OR VIDEO
  if (playVideo == false) {
    img.resize(width, height);
    image(img, 0, 0);
  } else {
    image(movie, 0, 0, width, height);
  }

  //DRAW LEDS ON SCREEN AND GET PIXEL COLOR VALUES
  drawLEDs();

  //SEND DATA TO ARDUINO AFTER EVERY INTERVAL FOR SANITY
  if (millis()-lastTrigger > sendInterval) {
    arduino.write(getValues());
    lastTrigger = millis();
  }
}

//INITIALISING LEDS
void ledSetup() {
  led = new LED[numRows][numColumns];
  for (int i=0; i<numRows; i++) {
    for (int j=0; j<numColumns; j++) {
      led[i][j] = new LED();
    }
  }
}


//DRAWING LEDS ON SCREEN AND GETTING PIXEL VALUES
void drawLEDs() {
  if (drag)
    m = new PVector(mouseX, mouseY);
  switch(pat) {

    //GET COLOURS FROM A SINGLE POINT
  case 0:
    c = get(int(m.x), int(m.y));                    //Pick colours
    rect(m.x, m.y, ledBox, ledBox);                 //Draw rectangle at position
    for (int i=0; i<numRows; i++) {                 //assign same color value to all LEDs
      for (int j=0; j<numColumns; j++) {
        led[i][j].red = byte(red(c)*globalB);       //enforce global brightness value
        led[i][j].blue = byte(blue(c)*globalB);
        led[i][j].green = byte(green(c)*globalB);
      }
    }
    break;

    //GET COLOURS FROM A STRIP PATTERN (COLUMNS IGNORED)
  case 1:
    for (int i=0; i<numRows; i++) {
      //Get each co-ordinate based on grid distance and rotation set by user
      int x = int(m.x + gridDistance * (i-numRows/2) * cos(gridRotation));
      int y = int(m.y + gridDistance * (i-numRows/2) * sin(gridRotation));
      c = get(x, y);                                //Pick colour
      rect(x, y, ledBox, ledBox);                   //Draw Rectangle
      led[i][0].red = byte(red(c)*globalB);
      led[i][0].blue = byte(blue(c)*globalB);
      led[i][0].green = byte(green(c)*globalB);
    }
    break;
    
    //GET COLOURS FROM A 2D MATRIX PATTERN
  case 2:
    for (int i=0; i<numColumns; i++) {
      for (int j=0; j<numRows; j++) {
        //Get each co-ordinate based on grid distance
        int x = int(m.x + gridDistance * (j-numRows/2));
        int y = int(m.y + gridDistance * (i-numColumns/2));
        
        //Apply rotation using PVector
        PVector cord = new PVector (x, y);
        cord.sub(m);
        cord.rotate(gridRotation);
        cord.add(m);
        x = int(cord.x);
        y = int(cord.y);
        
        //Get colour and draw rectangles
        c = get(x, y);
        rect(x, y, ledBox, ledBox);
        led[j][i].red = byte(red(c)*globalB);
        led[j][i].blue = byte(blue(c)*globalB);
        led[j][i].green = byte(green(c)*globalB);
      }
    }
    break;
    
    //GET COLOURS FROM A RING PATTERN (COLUMNS IGNORED)
  case 3:
    for (int i=0; i<numRows; i++) {
      //Get position based on angles
      PVector pos = PVector.fromAngle(gridRotation+TWO_PI/numRows*i);
      pos.setMag(gridDistance*5);
      pos.add(m);
      
      //Get colours and draw rectangles
      c = get(int(pos.x), int(pos.y));
      rect(pos.x, pos.y, ledBox, ledBox);
      led[i][0].red = byte(red(c)*globalB);
      led[i][0].blue = byte(blue(c)*globalB);
      led[i][0].green = byte(green(c)*globalB);
    }
    break;
  }
}

//A SIMPLE LED CLASS WITH RGB VALUES AND BW FUNCTION
class LED {
  byte red;
  byte green;
  byte blue;

  LED() {
    red = 0;
    green = 0;
    blue = 0;
  }

  void makeBW() {
    byte average = byte((red + blue + green)/3);
    red = average;
    blue = average;
    green = average;
  }
}

//FUNCTION TO PACK ALL VALUES IN A BYTE ARRAY, READY TO SEND TO ARDUINO
byte[] getValues() {
  byte[] values = new byte[numRows*numColumns*3];
  int k = 0;
  for (int i=0; i<numColumns; i++) {
    for (int j=0; j<numRows; j++) {
      if (bw == true)
        led[j][i].makeBW();
      values[k++] = led[j][i].green;
      values[k++] = led[j][i].red;
      values[k++] = led[j][i].blue;
    }
  }
  return values;
}

void movieEvent(Movie m) {
  m.read();
}
