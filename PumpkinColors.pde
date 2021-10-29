int numPanels = 5;
Panel[] panels;

final color RED    = #FF0000;
final color BLUE   = #0000FF;
final color GREEN  = #00FF00;
final color YELLOW = #FFFF00;
final color PURPLE = #800080;

color[] bgColors = {
  RED, 
  BLUE, 
  GREEN, 
  YELLOW, 
  PURPLE
};

void setup() {
  size(1200, 800);
  background(255);
  noStroke();
  ellipseMode(RADIUS);

  panels = new Panel[numPanels];
  for ( int i = 0; i < numPanels; i++ ) {
    int w = width / numPanels;
    int x = i * w;
    panels[i] = new Panel(x, w, bgColors[i]);
  }

  for ( Panel panel : panels ) {
    panel.draw();
  }
}

void draw() {
  for ( int i = 0; i < panels.length; i++ ){
    Panel panel = panels[i];
    
    if( i == mouseX / (width / numPanels) ){ 
      panel.pumpkin.bounce();
      
      if( mousePressed ){
        if( mouseButton == LEFT ){
          panel.pumpkin.explode();
        } else {
          panel.pumpkin.spin();
        }
      }
      
      if( keyPressed ){
        if( key == 'r' ){
          panel.pumpkin.reset();
        }
      }
      
    } else {
      panel.pumpkin.stop();
    }
    
    panel.draw();
  }
}


class Panel {
  int x, y, w, h;
  color bgColor;
  Pumpkin pumpkin;
  PImage bg;
  PGraphics pg;

  public Panel(int x, int w, color bgColor) {
    this.x = x;
    this.y = 0;
    this.w = w;
    this.h = height;
    this.bgColor = bgColor;
    this.pg = createGraphics(w, h);
    this.bg = createImage(pg.width, pg.height, ARGB);
    addPumpkin();

    for (int i = 0; i < bg.pixels.length; i++) {
      float a = map(i, 0, bg.pixels.length, 0, 255 + 100);
      bg.pixels[i] = color(red(bgColor), green(bgColor), blue(bgColor), a);
    }
  }

  void addPumpkin() {
    this.pumpkin = new Pumpkin(pg.width / 2, bgColor, pg);
    this.pumpkin.setGraphics(pg);
    this.pumpkin.setBounceHeight(int(random(10, height/20)));
  }

  void draw() {
    pg.beginDraw();
    pg.fill(255);
    pg.rect(0, 0, pg.width, pg.height);

    pg.image(bg, 0, 0);

    this.pumpkin.draw();
    pg.endDraw();
    image(pg, x, y);
  }
}
