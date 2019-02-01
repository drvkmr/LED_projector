import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LED_projector extends PApplet {





Serial arduino;
String[] ports;
int numRows;
int numColumns;
LED[][] led;
byte pat = 0;
int size = 10;
int cPicker = color(100);
long sendInterval = 16;
long lastTrigger = 0;
PImage img;
Movie movie;
boolean playVideo = false;
boolean bw = false;
boolean drag = false;
float globalB = .5f;
int gridDistance = 50;
float gridRotation = 0;
int ledBox = 10;
int fading = 0;
PVector m;
int c;
int uiWidth = 170;

int baudr = 2000000;

public void setup() {
  //BASIC SETUP
  
  surface.setResizable(true);
  noStroke();
  
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

public void draw() {
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
public void ledSetup() {
  led = new LED[numRows][numColumns];
  for (int i=0; i<numRows; i++) {
    for (int j=0; j<numColumns; j++) {
      led[i][j] = new LED();
    }
  }
}


//DRAWING LEDS ON SCREEN AND GETTING PIXEL VALUES
public void drawLEDs() {
  if (drag)
    m = new PVector(mouseX, mouseY);
  switch(pat) {

    //GET COLOURS FROM A SINGLE POINT
  case 0:
    c = get(PApplet.parseInt(m.x), PApplet.parseInt(m.y));                    //Pick colours
    rect(m.x, m.y, ledBox, ledBox);                 //Draw rectangle at position
    for (int i=0; i<numRows; i++) {                 //assign same color value to all LEDs
      for (int j=0; j<numColumns; j++) {
        led[i][j].red = PApplet.parseByte(red(c)*globalB);       //enforce global brightness value
        led[i][j].blue = PApplet.parseByte(blue(c)*globalB);
        led[i][j].green = PApplet.parseByte(green(c)*globalB);
      }
    }
    break;

    //GET COLOURS FROM A STRIP PATTERN (COLUMNS IGNORED)
  case 1:
    for (int i=0; i<numRows; i++) {
      //Get each co-ordinate based on grid distance and rotation set by user
      int x = PApplet.parseInt(m.x + gridDistance * (i-numRows/2) * cos(gridRotation));
      int y = PApplet.parseInt(m.y + gridDistance * (i-numRows/2) * sin(gridRotation));
      c = get(x, y);                                //Pick colour
      rect(x, y, ledBox, ledBox);                   //Draw Rectangle
      led[i][0].red = PApplet.parseByte(red(c)*globalB);
      led[i][0].blue = PApplet.parseByte(blue(c)*globalB);
      led[i][0].green = PApplet.parseByte(green(c)*globalB);
    }
    break;
    
    //GET COLOURS FROM A 2D MATRIX PATTERN
  case 2:
    for (int i=0; i<numColumns; i++) {
      for (int j=0; j<numRows; j++) {
        //Get each co-ordinate based on grid distance
        int x = PApplet.parseInt(m.x + gridDistance * (j-numRows/2));
        int y = PApplet.parseInt(m.y + gridDistance * (i-numColumns/2));
        
        //Apply rotation using PVector
        PVector cord = new PVector (x, y);
        cord.sub(m);
        cord.rotate(gridRotation);
        cord.add(m);
        x = PApplet.parseInt(cord.x);
        y = PApplet.parseInt(cord.y);
        
        //Get colour and draw rectangles
        c = get(x, y);
        rect(x, y, ledBox, ledBox);
        led[j][i].red = PApplet.parseByte(red(c)*globalB);
        led[j][i].blue = PApplet.parseByte(blue(c)*globalB);
        led[j][i].green = PApplet.parseByte(green(c)*globalB);
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
      c = get(PApplet.parseInt(pos.x), PApplet.parseInt(pos.y));
      rect(pos.x, pos.y, ledBox, ledBox);
      led[i][0].red = PApplet.parseByte(red(c)*globalB);
      led[i][0].blue = PApplet.parseByte(blue(c)*globalB);
      led[i][0].green = PApplet.parseByte(green(c)*globalB);
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

  public void makeBW() {
    byte average = PApplet.parseByte((red + blue + green)/3);
    red = average;
    blue = average;
    green = average;
  }
}

//FUNCTION TO PACK ALL VALUES IN A BYTE ARRAY, READY TO SEND TO ARDUINO
public byte[] getValues() {
  byte[] values = new byte[numRows*numColumns*3+1];
  int k = 0;
  for (int i=0; i<numColumns; i++) {
    for (int j=0; j<numRows; j++) {
      if (bw == true)
        led[j][i].makeBW();
      values[k++] = led[j][i].red;
      values[k++] = led[j][i].green;
      values[k++] = led[j][i].blue;
      //println(led[i][j].red + " " + led[i][j].blue + " " + led[i][j].green);
    }
  }
  //ADD 0XFF IN THE END FOR ARDUINO TO KNOW IT'S THE END OF PACKET
  values[k++] = (byte)0xFF;
  return values;
}

public void movieEvent(Movie m) {
  m.read();
}

ControlP5 cp5;

public void createGUI() {
  cp5 = new ControlP5(this);
  Accordion accordion;
  
  
  cp5.addTextlabel("label")
    .setText("LED PROJECTOR")
    .setPosition(20,20)
    .setColorValue(0xffF0F0F0)
    .setFont(createFont("AvenirNext-Bold",20))
    ;
  
  Group g1 = cp5.addGroup("Hardware setup")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(140)
    ;
    
  cp5.addSlider("rows")
    .setCaptionLabel("rows (0-100)")
    .setPosition(10, 80)
    .setSize(150, 10)
    .moveTo(g1)
    .setRange(0,100)
    .setNumberOfTickMarks(100)
    .setValue(8)
    .showTickMarks(false);
    ;
    cp5.getController("rows").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  cp5.addSlider("columns")
  .setCaptionLabel("columns (0-10)")
    .setPosition(10, 110)
    .setSize(150, 10)
    .moveTo(g1)
    .setRange(0,10)
    .setNumberOfTickMarks(10)
    .setValue(1)
    .showTickMarks(false);
    ;
    cp5.getController("columns").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  cp5.addScrollableList("patternType")
    .setPosition(10, 35)
    .setSize(150, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItem("Point", 0)
    .addItem("Strip", 0)
    .addItem("Matrix", 0)
    .addItem("Ring", 0)
    .moveTo(g1)
    .close()
    // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
    
  cp5.addScrollableList("portsList")
    .setPosition(10, 10)
    .setSize(150, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(ports)
    .moveTo(g1)
    .close()
    // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
    
  Group g2 = cp5.addGroup("Get file")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(140)
    .setSize(150,10)
    ;
  
  cp5.addButton("getVideo")
     .setPosition(10,10)
     .setSize(70,19)
     .moveTo(g2)
     ;
     
   cp5.addButton("getImage")
     .setPosition(90,10)
     .setSize(70,19)
     .moveTo(g2)
     ;
     
  cp5.addSlider("globalBrightness")
    .setPosition(10, 60)
    .setSize(150, 10)
    .moveTo(g2)
    .setRange(0,100)
    .setNumberOfTickMarks(100)
    .setValue(50)
    .showTickMarks(false);
    ;
    cp5.getController("globalBrightness").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  Group g3 = cp5.addGroup("Adjust Pattern")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(140)
    .setSize(150,10)
    ;
    
 cp5.addSlider("gridSize")
    .setPosition(10, 20)
    .setSize(150, 10)
    .moveTo(g3)
    .setRange(0,100)
    .setNumberOfTickMarks(100)
    .setValue(50)
    .showTickMarks(false);
    ;
    cp5.getController("gridSize").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
   
  cp5.addSlider("gridRotation")
    .setPosition(10, 60)
    .setSize(150, 10)
    .moveTo(g3)
    .setRange(0,360)
    .setNumberOfTickMarks(360)
    .setValue(0)
    .showTickMarks(false);
    ;
    cp5.getController("gridRotation").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  Group g4 = cp5.addGroup("Effects")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(140)
    .setSize(150,10)
    ;
    
  cp5.addCheckBox("eff")
    .setPosition(10, 10)
    .setSize(20, 20)
    .addItem("Black&White", 0)
    .moveTo(g4)
    ;
    
  cp5.addSlider("fade")
    .setPosition(10, 60)
    .setSize(150, 10)
    .moveTo(g4)
    .setRange(0,100)
    .setNumberOfTickMarks(100)
    .setValue(0)
    .showTickMarks(false);
    ;
    cp5.getController("fade").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
      
  accordion = cp5.addAccordion("acc")
    .setPosition(20, 60)
    .setWidth(uiWidth)
    .addItem(g1)
    .addItem(g2)
    .addItem(g3)
    .addItem(g4)
    ;

  accordion.open(0, 1, 2, 3);

  accordion.setCollapseMode(Accordion.MULTI);
}

public void portsList(int val) {
  arduino = new Serial(this, ports[val], baudr);
}

public void ledType(byte val) {
  pat = val;
}

public void rows(int val) {
  numRows = val;
  ledSetup();
}

public void columns(int val) {
  numColumns = val;
  ledSetup();
}

public void globalBrightness(int val) {
  globalB = PApplet.parseFloat(val)/100;
  //println(globalB);
}

public void patternType(int val) {
  pat = PApplet.parseByte(val);
}

public void gridSize(int val) {
  gridDistance = val;
}

public void gridRotation(int val) {
  gridRotation = radians(val);
}

public void getImage() {
  selectInput("Select a file to process:", "imageSelected");
}

public void getVideo() {
  selectInput("Select a file to process:", "videoSelected");
}

public void eff(float[] a) {
  println(a);
  if(a[0] == 1) bw = true;
  else bw = false;
}

public void fade(int val) {
  fading = val;
}

public void imageSelected(File selection) {
  if (selection != null) {
    img = loadImage(selection.getAbsolutePath());
    playVideo = false;
  }
}

public void videoSelected(File selection) {
  if (selection != null) {
    img = loadImage(selection.getAbsolutePath());
    movie = new Movie(this, selection.getAbsolutePath());
    playVideo = true;
    movie.loop();
  }
}


//DRAG PATTERN WITH MOUSE WHEN MOUSE IS DRAGGED
//AND THE FIRST CLICK IS NOT OVER UI WINDOW
public void mousePressed() {
  if(mouseX>uiWidth+10) {
    drag = true;
  }
}

public void mouseReleased() {
  drag = false;
}
  public void settings() {  size(1200, 600);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "LED_projector" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
