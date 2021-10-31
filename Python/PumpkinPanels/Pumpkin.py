class Pumpkin:
    STILL   = 0
    BOUNCE  = 1 << 0
    EXPLODE = 1 << 1
    SPIN    = 1 << 2
  
    def __init__(self, x, pumpkin_color, pg):
        self.state = Pumpkin.STILL
        self.size_pixels = 150
        self.floor_y = height - 15
        self.x = x
        self.x_speed = 0
        self.y = self.floor_y - (self.size_pixels / 2)
        self.pg = pg
        self.spin_speed = 5
        self.pumpkin_color = color(0)       # pumpkin shell color
        self.glow_color = pumpkin_color      # color inside the pumpkin
        self.angle_deg = 0                  # facing east
        self.bounce_height = 30
        self.bounce_speed = 0
        self.gravity = 1
        self.particles = list()
        self.spin_explode_count = 0

    #
    # Set new pumpkin size
    #
    def set_size(self, new_size):
        self.size_pixels = new_size
        self.y = self.floor_y - (self.size_pixels / 2)

    #
    # Change the color of your pumpkin
    #
    def set_pumpkin_color(self, new_color ):
        self.pumpkin_color = new_color

    #
    # Make the pumpkin spin
    #
    def spin(self):
        if (self.state & Pumpkin.EXPLODE) == 0:
            self.state |= Pumpkin.SPIN

    #
    # Set how fast the pumpkin spins
    #
    def set_spin_speed(self, new_speed):
        self.spin_speed = new_speed

    #
    # Make the pumpkin EXPLODE!
    #
    def explode_random_color(self):
        self.explode(color(random(255), random(255), random(255)))

    def explode(self, c=color(0)):
        if (self.state & Pumpkin.EXPLODE) == 0:
            self.particles = list()
    
        for i in range(0, self.size_pixels * 20, 10):
            # Apparently my first impression on solving this is pretty naive
            # because the general distribution of a random point inside a circle
            # has a greater density of points at larger radii, so that's why it's
            # sqrt(random(0, 1)) and not just random(0, 1) :D
            #random_radius = (self.size_pixels / 2) * random(0, 1)
            random_radius = (self.size_pixels / 2) * sqrt(random(0, 1))
            
            random_angle_rad = 2 * PI * random(0, 1)
            random_x = self.x + (random_radius * cos(random_angle_rad))
            random_y = self.y + (random_radius * sin(random_angle_rad))
            particle = self.Particle(self.pg, random_x, random_y, c)
            self.particles.append(particle)
    
        # Size of 0 makes the pumpkin shape disappear
        self.size_pixels = 0
        self.state |= Pumpkin.EXPLODE

    #
    # Make the pumpkin bounce
    #
    def bounce(self):
        self.state |= Pumpkin.BOUNCE

    #
    # Set how high the pumpkin bounces
    #
    def set_bounce_height(self, new_height_pixels ):
        self.bounce_height = new_height_pixels
        self.y = new_height_pixels

    #
    # Stop the pumpkin from moving or bouncing
    #
    def stop(self):
        self.state = Pumpkin.STILL
        self.x_speed = 0

    #
    # Regererate a new pumpkin!
    #
    def reset(self):
        self.set_size(int(random(100, 600)))
        self.set_bounce_height(int(random(10, height/20)))
        self.stop()

    #
    # Have the pumpkin move to the right
    #
    def move_right(self, speed ):
        self.x_speed = speed

    #
    # Have the pumpkin move to the left
    #
    def move_left(self, speed):
        self.x_speed = -speed

    #
    # Draw the pumpkin!
    #
    def draw(self):
        self.pg.push()

        saved_x = self.x
        saved_y = self.y
    
        if (self.state & Pumpkin.BOUNCE) != 0:
            self.update_bounce()
        
        if (self.state & Pumpkin.EXPLODE) != 0:
            self.update_explode()
        
        # Spin must be the last if check because the x/y coordinates
        # and coordiante system are modified when rotate() is called
        if (self.state & Pumpkin.SPIN) != 0:
            self.pg.pushMatrix()
            saved_x = self.x
            saved_y = self.y
            self.update_spin()

        self.draw_pumpkin_shape()
    
        if (self.state & Pumpkin.SPIN) != 0:
            self.pg.popMatrix()
            self.x = saved_x
            self.y = saved_y
        
        # Call here so the shadow doesn't potentially rotate
        self.draw_shadow()
    
        self.pg.pop()

    def update_bounce(self):
        if self.bounce_speed < self.bounce_height:
            self.bounce_speed += self.gravity
    
        self.y += self.bounce_speed
    
        if self.y > self.floor_y - (self.size_pixels / 2):
            self.y = self.floor_y - (self.size_pixels / 2)
    
            if (self.state & Pumpkin.BOUNCE) != 0:
                self.bounce_speed = -self.bounce_speed
    
        self.x += self.x_speed
    
        if self.x > self.pg.width + self.size_pixels:
            self.x = 0 - self.size_pixels
    
        if self.x < 0 - self.size_pixels:
            self.x = self.pg.width + self.size_pixels

    def update_spin(self):
        self.pg.translate(self.x, self.y)
        self.pg.rotate(radians(self.angle_deg))
        self.angle_deg += self.spin_speed
        self.x = 0
        self.y = 0

    def update_explode(self):
        for particle in self.particles:
            particle.update()
            particle.draw()

    def draw_shadow(self):
        scale_factor = self.size_pixels / 150.0
        w = (150 * scale_factor * self.y) / height
        h = (10 * scale_factor * self.y) / height
        self.pg.ellipse(self.x, self.floor_y, w, h)

    def draw_pumpkin_shape(self):
        if self.size_pixels == 0:
            return

        pg = self.pg
        x = self.x
        y = self.y
        size_pixels = self.size_pixels
        scale_factor = size_pixels / 150.0
    
        # Black outline
        pg.ellipseMode(CENTER)
        pg.stroke(0)
        pg.strokeWeight(2)
    
        # Draw top stem
        pg.fill(0)
        pg.rect(x - (10.0 * scale_factor), y - (size_pixels/2) - (20 * scale_factor), 15 * scale_factor, 20 * scale_factor)
    
        # Draw body
        pg.fill(self.pumpkin_color)
        pg.ellipse(x, y, size_pixels, size_pixels)
    
        # Set flickering glow color
        pg.fill(self.glow_color, random(200) + 50 )
    
        # Draw eyes
        pg.triangle(x - (30 * scale_factor), y - (20 * scale_factor), x - (20 * scale_factor), y, x - (40 * scale_factor), y)
        pg.triangle(x + (30 * scale_factor), y - (20 * scale_factor), x + (20 * scale_factor), y, x + (40 * scale_factor), y)
        pg.triangle(x, y, x + (10 * scale_factor), y + (20 * scale_factor), x - (10 * scale_factor), y + (20 * scale_factor))
    
        # Draw mouth
        pg.arc(x, y + (30 * scale_factor), 80 * scale_factor, 80 * scale_factor, 0, PI, 0)
        pg.line(x - (40 * scale_factor), y + (30 * scale_factor), x + (40 * scale_factor), y + (30 * scale_factor))
    
        # Draw tooth  
        pg.fill(self.pumpkin_color)
        pg.rect(x + (10 * scale_factor), y + (30 * scale_factor), 10 * scale_factor, 15 * scale_factor)
    
        # Clear the top outline of the tooth
        pg.strokeWeight(3)
        pg.stroke(self.pumpkin_color)
        pg.fill(self.pumpkin_color)
        pg.line(x + (12 * scale_factor), y + (30 * scale_factor), x + (17 * scale_factor), y + (30 * scale_factor))

    class Particle:
        def __init__(self, pg, x, y, particle_color=None, min_size=None, max_size=None):
            self.pg = pg
            self.new_x = None
            self.old_x = None
            self.new_y = None
            self.old_y = None
            self.x_velocity = None
            self.y_velocity = None
            self.gravity = None
            self.particle_color = None
            self.particle_size = None
            self.is_sparkle = False

            self.particle_setup(x, y)
        
            if particle_color is not None:
                self.particle_color = particle_color
        
            if min_size is not None and max_size is not None:
                self.particle_size = random(min_size, max_size)
            
    
        def particle_setup(self, x, y):
            self.new_x = x
            self.old_x = self.new_x
            self.new_y = y
            self.old_y = self.new_y
    
            # Radiate particles 360 degree from center
            dir = random(0, TWO_PI)
        
            # Blast radius so the particle falls within the screen width
            firework_width = float(width) / (1.7 * width)
            magnitude = firework_width * random(10.1, 25)
            self.x_velocity = magnitude * cos(dir)
            self.y_velocity = magnitude * sin(dir)
        
            self.particle_size = random(1, 10)
            self.gravity = 0.2
            self.particle_color = '#FFFFFF'
    
        def draw(self):
            self.pg.push()
    
            # Draw a line from the old location to the new location
            self.pg.strokeWeight(int(self.particle_size))
        
            if self.is_sparkle:
                red_color = green_color = blue_color = None
                red_color   = red(self.particle_color) - random(50)
                green_color = green(self.particle_color) - random(50)
                blue_color  = blue(self.particle_color) - random(50)
                self.pg.stroke(red_color, green_color, blue_color, random(255))
            else:
                self.pg.stroke(self.particle_color)
    
            self.pg.line(self.old_x, self.old_y, self.new_x, self.new_y)
    
            self.pg.pop()
    
        def update(self):
            # Calculate new X and Y, set old X and Y
            self.old_x = self.new_x
            self.old_y = self.new_y
            self.new_x += self.x_velocity
            self.new_y += self.y_velocity
            self.y_velocity += self.gravity
