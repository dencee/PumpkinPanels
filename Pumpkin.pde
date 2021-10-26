public class Pumpkin {
  protected int x;
  protected int y;
  private int xSpeed = 0;
  private boolean bounce = false;
  private int bounceHeight = 30;
  private int bounceSpeed = 0;
  private int gravity = 1;
  private int pumpkinColor;
  private int pumpkinSizePixels = 150;
  private int glowingEyesColor = color(240 + random(15), 240 + random(15), random(255));
  private int greenStemColor = #2EA22C;

  protected PGraphics pg = null;

  public Pumpkin( int x, int pumpkinColor, PGraphics pg ) {
    this.x = x;
    this.y = height - 300;
    this.pumpkinColor = pumpkinColor;
    this.pg = pg;
  }

  public void setPumpkinColor( int newColor ) {
    this.pumpkinColor = newColor;
  }

  // ---------------------------------------------------------
  // Call this method from the setup() method,
  // NOT the draw() method
  // ---------------------------------------------------------
  public void setBounceHeight( int newHeightInPixels ) {
    this.bounceHeight = newHeightInPixels;
    this.y = newHeightInPixels;
  }

  public void bounce() {
    this.bounce = true;
  }

  public void stop() {
    this.bounce = false;
    this.xSpeed = 0;
  }

  public void moveRight( int speed ) {
    this.xSpeed = speed;
  }

  public void moveLeft( int speed ) {
    this.xSpeed = -speed;
  }

  public void draw() {
    pg.push();

    if ( bounceSpeed < bounceHeight ) {
      bounceSpeed += gravity;
    }

    y += bounceSpeed;

    if ( this.y > height - 100 ) {
      this.y = height - 100;

      if ( bounce ) {
        bounceSpeed = -bounceSpeed;
      }
    }

    this.x += xSpeed;

    if ( this.x > width + this.pumpkinSizePixels ) {
      this.x = 0 - this.pumpkinSizePixels;
    }
    if ( this.x < 0 - this.pumpkinSizePixels ) {
      this.x = width;
    }

    // Black outline
    pg.ellipseMode(CENTER);
    pg.stroke(0);
    pg.strokeWeight(2);

    // Draw top stem
    pg.fill(greenStemColor);
    pg.rect(x - 10, y - (pumpkinSizePixels/2) - 20, 15, 20);

    // Draw body
    pg.fill(pumpkinColor);
    pg.ellipse(x, y, pumpkinSizePixels, pumpkinSizePixels); 

    // Draw glowing eyes
    pg.fill(glowingEyesColor, random(200) + 50 );
    pg.triangle(x-30, y-20, x-20, y, x-40, y);
    pg.triangle(x+30, y-20, x+20, y, x+40, y);
    pg.triangle(x, y, x+10, y+20, x-10, y+20);

    // Draw shadow
    pg.ellipse(x, height - 15, (150 * y) / height, (10 * y) / height);

    // Draw mouth
    pg.arc(x, y + 30, 80, 80, 0, PI, 0);
    pg.line(x - 40, y + 30, x + 40, y + 30);

    // Draw tooth  
    pg.fill(this.pumpkinColor);
    pg.rect(x + 10, y + 30, 10, 15);

    // Clear the top outline of the tooth
    pg.strokeWeight(3);
    pg.stroke(this.pumpkinColor);
    pg.fill(this.pumpkinColor);
    pg.line(x + 12, y + 30, x + 17, y + 30);

    pg.pop();
  }

  color interpolateColor(color[] arr, float step) {
    int sz = arr.length;

    if (sz == 1 || step <= 0.0) {
      return arr[0];
    } else if (step >= 1.0) {
      return arr[sz - 1];
    }

    float scl = step * (sz - 1);
    int i = int(scl);

    return lerpColor(arr[i], arr[i + 1], scl - i);
  }

  void setGraphics(PGraphics pg) {
    this.pg = pg;
  }
}
