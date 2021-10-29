public class Pumpkin {
  private final int STILL   = 0;
  private final int BOUNCE  = 1 << 0;
  private final int SPIN    = 1 << 1;
  private final int EXPLODE = 1 << 2;
  private int state = STILL;

  protected int x;
  protected int y;
  private int spinSpeed = 5;
  private int xSpeed = 0;
  private int angleDeg = 0;      // facing east
  private int bounceHeight = 30;
  private int bounceSpeed = 0;
  private int gravity = 1;
  private int floorY;
  private int pumpkinColor;
  private int sizePixels = 200;
  private int glowColor;
  private int greenStemColor = #2EA22C;

  protected PGraphics pg = null;
  ArrayList<Particle> particles;

  public Pumpkin( int x, int pumpkinColor, PGraphics pg ) {
    this.x = x;
    this.floorY = height - 15;
    this.y = floorY - (sizePixels / 2);
    this.pg = pg;
    this.glowColor = pumpkinColor;
    this.pumpkinColor = color(0);
    this.particles = new ArrayList<Particle>();
  }

  /*
   * Set new pumpkin size
   */
  public void setSize(int newSize) {
    this.sizePixels = newSize;
    this.y = floorY - (sizePixels / 2);
  }

  /*
   * Change the color of your pumpkin
   */
  public void setPumpkinColor( int newColor ) {
    this.pumpkinColor = newColor;
  }

  /*
   * Make the pumpkin spin
   */
  void spin() {
    this.state |= SPIN;
  }

  /*
   * Set how fast the pumpkin spins
   */
  void setSpinSpeed(int newSpeed) {
    this.spinSpeed = newSpeed;
  }

  /*
   * Make the pumpkin EXPLODE!
   */
  void explode() {
    explodeColor(color(0));
  }
  void explodeRandomColor() {
    explodeColor(color(random(255), random(255), random(255)));
  }
  void explodeColor(color c) {
    if ( (this.state & EXPLODE) == 0) {
      particles.clear();

      for ( int i = 0; i < this.sizePixels * 50; i+=10 ) {
        Particle p = new Particle(this.x, this.y, c);
        particles.add(p);
      }

      this.sizePixels = 0;
      this.state |= EXPLODE;
    }
  }

  /*
   * Make the pumpkin bounce
   */
  public void bounce() {
    this.state |= BOUNCE;
  }

  /*
   * Set how high the pumpkin bounces
   */
  public void setBounceHeight( int newHeightInPixels ) {
    this.bounceHeight = newHeightInPixels;
    this.y = newHeightInPixels;
  }

  /*
   * Stop the pumpkin from moving or bouncing
   */
  public void stop() {
    this.state = STILL;
    this.xSpeed = 0;
  }

  /*
   * Regererate a new pumpkin!
   */
  public void reset() {
    this.setSize(int(random(100, 600)));
    this.setBounceHeight(int(random(10, height/20)));
    this.stop();
  }

  /*
   * Have the pumpkin move to the right
   */
  public void moveRight( int speed ) {
    this.xSpeed = speed;
  }

  /*
   * Have the pumpkin move to the left
   */
  public void moveLeft( int speed ) {
    this.xSpeed = -speed;
  }

  /*
   * Draw the pumpkin!
   */
  public void draw() {
    pg.push();

    int savedX = x, savedY = y;

    if ( (this.state & BOUNCE) != 0 ) {
      updateBounce();
    }
    if ( (this.state & EXPLODE) != 0 ) {
      updateExplode();
    }
    
    // Spin must be the last if check because the x/y coordinates
    // and coordiante system are modified when rotate() is called
    if ( (this.state & SPIN) != 0 ) {
      pg.pushMatrix();
      savedX = this.x;
      savedY = this.y;
      updateSpin();
    }

    drawPumpkinShape();

    if ( (this.state & SPIN) != 0 ) {
      pg.popMatrix();
      this.x = savedX;
      this.y = savedY;
    }
    
    drawShadow();

    pg.pop();
  }

  private void updateBounce() {

    if ( bounceSpeed < bounceHeight ) {
      bounceSpeed += gravity;
    }

    y += bounceSpeed;

    if ( this.y > floorY - (sizePixels/2) ) {
      this.y = floorY - (sizePixels/2);

      if ( (state & BOUNCE) != 0 ) {
        bounceSpeed = -bounceSpeed;
      }
    }

    this.x += xSpeed;

    if ( this.x > width + this.sizePixels ) {
      this.x = 0 - this.sizePixels;
    }
    if ( this.x < 0 - this.sizePixels ) {
      this.x = width;
    }
  }

  private void updateSpin() {
    pg.translate(x, y);
    pg.rotate(radians(this.angleDeg));
    this.angleDeg += this.spinSpeed;
    this.x = 0;
    this.y = 0;
  }

  private void updateExplode() {
    for ( Particle p : particles ) {
      p.update();
      p.draw();
    }
  }

  private void drawShadow() {
    float scaleFactor = sizePixels / 150.0;
    float w = (150 * scaleFactor * y) / height;
    float h = (10 * scaleFactor * y) / height;
    pg.ellipse(x, floorY, w, h);
  }

  private void drawPumpkinShape() {

    if ( this.sizePixels == 0 ) {
      return;
    }

    float scaleFactor = sizePixels / 150.0;

    // Black outline
    pg.ellipseMode(CENTER);
    pg.stroke(0);
    pg.strokeWeight(2);

    // Draw top stem
    pg.fill(0);
    pg.rect(x - (10.0 * scaleFactor), y - (sizePixels/2) - (20 * scaleFactor), 15 * scaleFactor, 20 * scaleFactor);

    // Draw body
    pg.fill(pumpkinColor);
    pg.ellipse(x, y, sizePixels, sizePixels); 

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

    // Clear the top outline of the tooth
    pg.strokeWeight(3);
    pg.stroke(this.pumpkinColor);
    pg.fill(this.pumpkinColor);
    pg.line(x + (12 * scaleFactor), y + (30 * scaleFactor), x + (17 * scaleFactor), y + (30 * scaleFactor));
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
    int particleColor;
    boolean isSparkle = false;

    public Particle(float x, float y) {
      initialize(x, y);
    }
    public Particle( float x, float y, int particleColor ) {
      initialize(x, y);
      this.particleColor = particleColor;
    }

    public Particle( float x, float y, int particleColor, float minSize, float maxSize ) {
      initialize(x, y);
      this.particleColor = particleColor;
      this.size = random(minSize, maxSize);
    }

    void initialize(float x, float y) {
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
      particleColor = #FFFFFF;
    }

    void draw() {
      pg.push();

      // Draw a line from the old location to the new location
      pg.strokeWeight(this.size);
      if ( isSparkle ) {
        float red   = red(this.particleColor) - random(50);
        float green = green(this.particleColor) - random(50);
        float blue  = blue(this.particleColor) - random(50);
        pg.stroke(red, green, blue, random(255));
      } else {
        pg.stroke(this.particleColor);
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
