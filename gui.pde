ControlP5 cp5;

void createGUI() {
  cp5 = new ControlP5(this);
  Accordion accordion;
  
  
  cp5.addTextlabel("label")
    .setText("LED PROJECTOR")
    .setPosition(20,20)
    .setColorValue(#F0F0F0)
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
  .setCaptionLabel("rows (0-10)")
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
    .setWidth(170)
    .addItem(g1)
    .addItem(g2)
    .addItem(g3)
    .addItem(g4)
    ;

  accordion.open(0, 1, 2, 3);

  accordion.setCollapseMode(Accordion.MULTI);
}

void portsList(int val) {
  arduino = new Serial(this, ports[val], 9600);
}

void ledType(byte val) {
  pat = val;
}

void rows(int val) {
  numRows = val;
  ledSetup();
}

void columns(int val) {
  numColumns = val;
  ledSetup();
}

void globalBrightness(int val) {
  globalB = float(val)/100;
  //println(globalB);
}

void patternType(int val) {
  pat = byte(val);
}

void gridSize(int val) {
  gridDistance = val;
}

void gridRotation(int val) {
  gridRotation = radians(val);
}

void getImage() {
  selectInput("Select a file to process:", "imageSelected");
}

void getVideo() {
  selectInput("Select a file to process:", "videoSelected");
}

void eff(float[] a) {
  println(a);
  if(a[0] == 1) bw = true;
  else bw = false;
}

void fade(int val) {
  fading = val;
}

void imageSelected(File selection) {
  if (selection != null) {
    img = loadImage(selection.getAbsolutePath());
    playVideo = false;
  }
}

void videoSelected(File selection) {
  if (selection != null) {
    img = loadImage(selection.getAbsolutePath());
    movie = new Movie(this, selection.getAbsolutePath());
    println("IN");
    playVideo = true;
    movie.loop();
  }
}
