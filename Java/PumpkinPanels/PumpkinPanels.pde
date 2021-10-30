/*
 * Run the code and see if you can figure out how to change the pumpkins
 * in different ways.
 * 
 * *Hint* Look in the code in the draw() and mouseWheel() methods. 
 *
 * Use the following pumpkin methods to customize your pumpkin panel!
 * pumpkin.setSize()
 * pumpkin.setPumpkinColor()
 * pumpkin.bounce()
 * pumpkin.setBounceHeight()
 * pumpkin.spin()
 * pumpkin.spinSpinSpeed()
 * pumpkin.explode()
 * pumpkin.explodeColor()
 * pumpkin.explodeRandomColor()
 * pumpkin.stop()
 * pumpkin.reset()
 * pumpkin.moveRight()
 * pumpkin.moveLeft()
 * panel.addPumpkin()
 */
int numPanels = 5;
int panelWidth;
Panel[] panels;
color[] bgColors;

final color RED    = #FF0000;
final color BLUE   = #0000FF;
final color GREEN  = #00FF00;
final color YELLOW = #FFFF00;
final color PURPLE = #800080;
final color ORANGE = #FFA500;

color[] colors = {
  RED, 
  BLUE, 
  GREEN, 
  YELLOW, 
  PURPLE, 
  ORANGE
};

void setup() {
  size(1200, 800);
  initializePanels(colors);
}

void draw() {
  for ( int i = 0; i < panels.length; i++ ) {
    boolean addPumpkin = false;
    boolean clearPumpkins = false;
    Panel panel = panels[i];

    for ( Pumpkin pumpkin : panel.pumpkins ) {
      
      /*
       * If mouse is hovering over a panel...
       */
      if ( i == mouseX / (width / numPanels) ) { 
        pumpkin.bounce();

        if ( mousePressed ) {
          if ( mouseButton == LEFT ) {
            pumpkin.explode();
          } else if ( mouseButton == RIGHT ) {
            pumpkin.spin();
          }
        }

        if ( keyPressed ) {
          if( keyCode == LEFT ){
            pumpkin.moveLeft(5);
          } else if( keyCode == RIGHT ){
            pumpkin.moveRight(5);
          } else if ( key == 'r' ) {
            pumpkin.reset();
            clearPumpkins = true;
          } else if ( key == 's' ) {
            pumpkin.stop();
          } else if ( key == 'a' ) {
            addPumpkin = true;
          }
        }
      } else {
        pumpkin.stop();
      }
    }
    
    /*
     * Outside of for loop to avoid concurrent modification exception
     */
    if( addPumpkin ){
      panel.addPumpkinRandomSize(int(random(0, panelWidth)));
    }
    if( clearPumpkins ){
      panel.pumpkins.clear();
      panel.addPumpkin(panel.pg.width / 2, 150);
    }

    panel.draw();
  }
}

void mouseWheel(MouseEvent event) {

  for ( Pumpkin pumpkin : panels[mouseX / panelWidth].pumpkins ) {
    
    /*
     * event.getCount() returns < 0 if scrolled up (away from the user)
     * event.getCount() returns > 0 if scrolled down (toward the user)
     */
    if ( event.getCount() > 0 ) {
      pumpkin.setSpinSpeed( pumpkin.spinSpeed + 2 );
    } else {
      pumpkin.setSpinSpeed( pumpkin.spinSpeed - 2 );
    }
  }
}




void initializePanels(color[] colors) {
  panelWidth = width / numPanels;
  bgColors = new color[numPanels];
  panels = new Panel[numPanels];

  for ( int i = 0; i < bgColors.length; i++ ) {
    bgColors[i] = colors[i % colors.length];
  }

  for ( int i = 0; i < numPanels; i++ ) {
    panels[i] = new Panel(i * panelWidth, panelWidth, bgColors[i]);
  }
}

class Panel {
  int x, y, w, h;
  color bgColor;
  PImage bg;
  PGraphics pg;
  ArrayList<Pumpkin> pumpkins;

  public Panel(int x, int w, color bgColor) {
    this.x = x;
    this.y = 0;
    this.w = w;
    this.h = height;
    this.bgColor = bgColor;
    this.pg = createGraphics(w, h);
    this.bg = createImage(pg.width, pg.height, ARGB);

    pumpkins = new ArrayList<Pumpkin>();
    addPumpkin(pg.width / 2, 150);

    for (int i = 0; i < bg.pixels.length; i++) {
      float a = map(i, 0, bg.pixels.length, 0, 255 + 100);
      bg.pixels[i] = color(red(bgColor), green(bgColor), blue(bgColor), a);
    }
  }

  void addPumpkin(int x, int size) {
    Pumpkin pumpkin = new Pumpkin(x, bgColor, pg);
    pumpkin.setSize(size);
    pumpkin.setBounceHeight(int(random(10, height/20)));
    this.pumpkins.add(pumpkin);
  }
  
  void addPumpkinRandomSize(int x) {
    addPumpkin(x, int(random(10, 200)));
  }

  void draw() {
    pg.beginDraw();

    pg.fill(255);
    pg.rect(0, 0, pg.width, pg.height);
    pg.image(bg, 0, 0);
    
    for( Pumpkin pumpkin : this.pumpkins ){
      pumpkin.draw();
    }

    pg.endDraw();

    image(pg, x, y);
  }
}
