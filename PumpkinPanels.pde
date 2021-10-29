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
 */
int numPanels = 5;
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
  for ( int i = 0; i < panels.length; i++ ){
    Pumpkin pumpkin = panels[i].pumpkin;
    
    /*
     * If mouse is hovering over a pumpkin...
     */
    if( i == mouseX / (width / numPanels) ){ 
      pumpkin.bounce();
      
      if( mousePressed ){
        if( mouseButton == LEFT ){
          pumpkin.explode();
        } else if( mouseButton == RIGHT ){
          pumpkin.spin();
        }
      }
      
      if( keyPressed ){
        if( key == 'r' ){
          pumpkin.reset();
        } else if( key == 's' ){
          pumpkin.stop();
        }
      }
    } else {
      pumpkin.stop();
    }
    
    panels[i].draw();
  }
}

void mouseWheel(MouseEvent event){
  Pumpkin pumpkin = panels[mouseX / (width / numPanels)].pumpkin;
  
  if( event.getCount() > 0 ){
    pumpkin.spinSpinSpeed( pumpkin.spinSpeed + 2 );
  } else {
    pumpkin.spinSpinSpeed( pumpkin.spinSpeed - 2 );
  }
}

void initializePanels(color[] colors){
  bgColors = new color[numPanels];
  for( int i = 0; i < bgColors.length; i++ ){
    bgColors[i] = colors[i % colors.length];
  }

  panels = new Panel[numPanels];
  for ( int i = 0; i < numPanels; i++ ) {
    int w = width / numPanels;
    int x = i * w;
    panels[i] = new Panel(x, w, bgColors[i]);
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
    addPumpkin(pg.width / 2);

    for (int i = 0; i < bg.pixels.length; i++) {
      float a = map(i, 0, bg.pixels.length, 0, 255 + 100);
      bg.pixels[i] = color(red(bgColor), green(bgColor), blue(bgColor), a);
    }
  }

  void addPumpkin(int x) {
    this.pumpkin = new Pumpkin(x, bgColor, pg);
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
