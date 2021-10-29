public class Pumpkin {
  private final int STILL = 0;
  private final int BOUNCE = 1 << 0;
  private final int SPIN = 1 << 1;
  private final int EXPLODE = 1 << 2;
  private int state = STILL;

  protected int x;
  protected int y;
  private int xSpeed = 0;
  private int angleDeg = 0;      // facing east
  private int bounceHeight = 30;
  private int bounceSpeed = 0;
  private int gravity = 1;
  private int floorY;
  private int pumpkinColor;
  private int pumpkinSizePixels = 200;
  private int glowColor;
  private int greenStemColor = #2EA22C;

  protected PGraphics pg = null;
  ArrayList<Particle> particles;

  public Pumpkin( int x, int pumpkinColor, PGraphics pg ) {
    this.x = x;
    this.y = height - pumpkinSizePixels;
    this.floorY = height - 15;
    this.pg = pg;
    this.glowColor = pumpkinColor;
    this.pumpkinColor = color(0);
    this.particles = new ArrayList<Particle>();
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
    this.state |= BOUNCE;
  }

  public void stop() {
    this.state = STILL;
    this.xSpeed = 0;
  }

  public void moveRight( int speed ) {
    this.xSpeed = speed;
  }

  public void moveLeft( int speed ) {
    this.xSpeed = -speed;
  }
  
  public void reset(){
     this.pumpkinSizePixels = 150;
     this.stop();
  }

  public void draw() {
    pg.push();

    int savedX = 0, savedY = 0;

    if ( (this.state & BOUNCE) != 0 ) {
      updateBounce();
    }
    if ( (this.state & SPIN) != 0 ) {
      pg.pushMatrix();
      savedX = this.x;
      savedY = this.y;
      updateSpin();
    }
    if ( (this.state & EXPLODE) != 0 ) {
      updateExplode();
      drawShape();
    }

    drawShape();

    if ( (this.state & SPIN) != 0 ) {
      pg.popMatrix();
      this.x = savedX;
      this.y = savedY;
    }

    pg.pop();
  }

  private void updateBounce() {

    if ( bounceSpeed < bounceHeight ) {
      bounceSpeed += gravity;
    }

    y += bounceSpeed;

    if ( this.y > floorY - (pumpkinSizePixels/2) ) {
      this.y = floorY - (pumpkinSizePixels/2);

      if ( (state & BOUNCE) != 0 ) {
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
  }

  private void updateSpin() {
    pg.translate(x, y);
    pg.rotate(radians(angleDeg));
    angleDeg += 5;
    this.x = 0;
    this.y = 0;
  }

  private void updateExplode() {
    for ( Particle p : particles ) {
      p.update();
      p.draw();
    }
  }

  private void drawShape() {
    println(this.pumpkinSizePixels);
    if( this.pumpkinSizePixels == 0 ){
      return;
    }
    
    float scaleFactor = pumpkinSizePixels / 150.0;

    // Black outline
    pg.ellipseMode(CENTER);
    pg.stroke(0);
    pg.strokeWeight(2);

    // Draw top stem
    //pg.fill(greenStemColor);
    pg.fill(0);
    pg.rect(x - (10.0 * scaleFactor), y - (pumpkinSizePixels/2) - (20 * scaleFactor), 15 * scaleFactor, 20 * scaleFactor);

    // Draw body
    pg.fill(pumpkinColor);
    pg.ellipse(x, y, pumpkinSizePixels, pumpkinSizePixels); 

    // Set flickering glow color
    pg.fill(glowColor, random(200) + 50 );

    // Draw eyes
    pg.triangle(x - (30 * scaleFactor), y - (20 * scaleFactor), x - (20 * scaleFactor), y, x - (40 * scaleFactor), y);
    pg.triangle(x + (30 * scaleFactor), y - (20 * scaleFactor), x + (20 * scaleFactor), y, x + (40 * scaleFactor), y);
    pg.triangle(x, y, x + (10 * scaleFactor), y + (20 * scaleFactor), x - (10 * scaleFactor), y + (20 * scaleFactor));

    // Draw mouth
    pg.arc(x, y + (30 * scaleFactor), 80 * scaleFactor, 80 * scaleFactor, 0, PI, 0);
    pg.line(x - (40 * scaleFactor), y + (30 * scaleFactor), x + (40 * scaleFactor), y + (30 * scaleFactor));

    // Draw tooth  
    pg.fill(this.pumpkinColor);
    pg.rect(x + (10 * scaleFactor), y + (30 * scaleFactor), 10 * scaleFactor, 15 * scaleFactor);

    // Draw shadow
    pg.ellipse(x, floorY, (150 * scaleFactor * y) / height, (10 * scaleFactor * y) / height);

    // Clear the top outline of the tooth
    pg.strokeWeight(3);
    pg.stroke(this.pumpkinColor);
    pg.fill(this.pumpkinColor);
    pg.line(x + (12 * scaleFactor), y + (30 * scaleFactor), x + (17 * scaleFactor), y + (30 * scaleFactor));
  }

  void spin() {
    this.state |= SPIN;
  }

  void explode() {
    if ( (this.state & EXPLODE) == 0) {
      particles.clear();

      pg.loadPixels();
      for ( int i = 0; i < pg.pixels.length; i+=20 ) {
        if (pg.pixels[i] == color(0)) {
          Particle p = new Particle(i % width, i / width, color(0));
          particles.add(p);
        }
      }

      this.pumpkinSizePixels = 0;
      this.state |= EXPLODE;
    }
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

  class Particle {
    float newX;
    float oldX;
    float newY;
    float oldY;
    float dir;
    float magnitude;
    float xVelocity;
    float yVelocity;
    float size;
    float gravity;
    int fireworkColor;
    boolean isSparkle = false;

    public Particle(float x, float y) {
      setup(x, y);
    }
    public Particle( float x, float y, int fireworkColor ) {
      setup(x, y);
      this.fireworkColor = fireworkColor;
    }

    public Particle( float x, float y, int fireworkColor, float minSize, float maxSize ) {
      setup(x, y);
      this.fireworkColor = fireworkColor;
      this.size = random(minSize, maxSize);
    }

    void setup(float x, float y) {
      newX = x;
      oldX = newX;
      newY = y;
      oldY = newY;

      // radiate particles 360 degree from center
      dir = random(0, TWO_PI);

      // Blast radius so the particle falls within the screen width
      float fireworkWidth = float(width) / (1.7 * width);
      magnitude = fireworkWidth * random(10.1, 25);
      xVelocity = magnitude * cos(dir);
      yVelocity = magnitude * sin(dir);


      size = random(1, 10);
      gravity = 0.2;
      fireworkColor = #FFFFFF;
    }

    void draw() {
      pg.push();

      // Draw a line from the old location to the new location
      pg.strokeWeight(this.size);
      if ( isSparkle ) {
        float red   = red(this.fireworkColor) - random(50);
        float green = green(this.fireworkColor) - random(50);
        float blue  = blue(this.fireworkColor) - random(50);
        pg.stroke(red, green, blue, random(255));
      } else {
        pg.stroke(this.fireworkColor);
      }
      pg.line(oldX, oldY, newX, newY);

      pg.pop();
    }

    void update() {
      // Calculate new X and Y, set old X and Y
      oldX = newX;
      oldY = newY;
      newX += xVelocity;
      newY += yVelocity;
      yVelocity += gravity;
    }
  }
}
