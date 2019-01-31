import controlP5.*;
import processing.serial.*;
import processing.video.*;

Serial arduino;
String[] ports;
int numRows;
int numColumns;
LED[][] led;
byte pat = 0;
PVector pos = new PVector(width/2, height/2);
int size = 10;
int cPicker = color(100);
long sendInterval = 16;
long lastTrigger = 0;
PImage img;
Movie movie;
boolean playVideo = false;
boolean bw = false;
float globalB = .5;
int gridDistance = 50;
float gridRotation = 0;
int ledBox = 10;
int fading = 0;
color c;

void setup() {
  size(1200, 600);
  noStroke();
  smooth();
  //frameRate(25);
  rectMode(CENTER);
  strokeWeight(2);
  noFill();
  stroke(255);
  ports = Serial.list();
  arduino = new Serial(this, ports[2], 500000);
  ledSetup();
  img = loadImage("gradient.jpg");
  movie = new Movie(this, "transit.mov");
  movie.loop();
  numRows = 8;
  numColumns = 1;
  createGUI();
}

void draw() {
  background(255);
  if (playVideo == false) {
    img.resize(width, height);
    image(img, 0, 0);
  } else {
    image(movie, 0, 0, width, height);
  }
  drawLEDs();
  if (millis()-lastTrigger > sendInterval) {
    arduino.write(getValues());
    lastTrigger = millis();
  }
  //delay(1000);
}

void ledSetup() {
  led = new LED[numRows][numColumns];
  for (int i=0; i<numRows; i++) {
    for (int j=0; j<numColumns; j++) {
      led[i][j] = new LED();
    }
  }
}



void drawLEDs() {
  PVector m = new PVector(mouseX, mouseY);
  switch(pat) {
  case 0:
    c = get(int(m.x), int(m.y));
    rect(m.x, m.y, ledBox, ledBox);
    for (int i=0; i<numRows; i++) {
      for (int j=0; j<numColumns; j++) {
        led[i][j].red = byte(red(c)*globalB);
        led[i][j].blue = byte(blue(c)*globalB);
        led[i][j].green = byte(green(c)*globalB);
      }
    }
    break;
  case 1:
    for (int i=0; i<numRows; i++) {
      int x = int(m.x + gridDistance * (i-numRows/2) * cos(gridRotation));
      int y = int(m.y + gridDistance * (i-numRows/2) * sin(gridRotation));
      c = get(x, y);
      rect(x, y, ledBox, ledBox);
      led[i][0].red = byte(red(c)*globalB);
      led[i][0].blue = byte(blue(c)*globalB);
      led[i][0].green = byte(green(c)*globalB);
    }
    break;
  case 2:
    for (int i=0; i<numColumns; i++) {
      for (int j=0; j<numRows; j++) {
        PVector mouse = new PVector(m.x, m.y);
        int x = int(m.x + gridDistance * (j-numRows/2));
        int y = int(m.y + gridDistance * (i-numColumns/2));
        PVector cord = new PVector (x, y);
        cord.sub(mouse);
        cord.rotate(gridRotation);
        cord.add(mouse);
        x = int(cord.x);
        y = int(cord.y);
        c = get(x, y);
        rect(x, y, ledBox, ledBox);
        led[j][i].red = byte(red(c)*globalB);
        led[j][i].blue = byte(blue(c)*globalB);
        led[j][i].green = byte(green(c)*globalB);
      }
    }
    break;
  case 3:
    for (int i=0; i<numRows; i++) {
      PVector pos = PVector.fromAngle(gridRotation+TWO_PI/numRows*i);
      pos.setMag(gridDistance*5);
      pos.add(m);
      
      c = get(int(pos.x), int(pos.y));
      rect(pos.x, pos.y, ledBox, ledBox);
      led[i][0].red = byte(red(c)*globalB);
      led[i][0].blue = byte(blue(c)*globalB);
      led[i][0].green = byte(green(c)*globalB);
    }
    break;
  }
}


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

byte[] getValues() {
  byte[] values = new byte[numRows*numColumns*3+1];
  int k = 0;
  for (int i=0; i<numColumns; i++) {
    for (int j=0; j<numRows; j++) {
      if(bw == true)
        led[j][i].makeBW();
      values[k++] = led[j][i].red;
      values[k++] = led[j][i].green;
      values[k++] = led[j][i].blue;
      //println(led[i][j].red + " " + led[i][j].blue + " " + led[i][j].green);
    }
  }
  values[k++] = (byte)0xFF;
  return values;
}

void movieEvent(Movie m) {
  m.read();
}
