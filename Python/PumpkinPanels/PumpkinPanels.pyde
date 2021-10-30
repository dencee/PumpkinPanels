from Pumpkin import Pumpkin
# Run the code and see if you can figure out how to change the pumpkins
# in different ways.
# 
# *Hint* Look in the code in the draw() and mouseWheel() methods. 
# 
# Use the following pumpkin methods to customize your pumpkin panel!
# pumpkin.set_size()
# pumpkin.set_pumpkin_color()
# pumpkin.bounce()
# pumpkin.set_bounce_height()
# pumpkin.spin()
# pumpkin.spin_spin_speed()
# pumpkin.explode()
# pumpkin.explode_color()
# pumpkin.explode_random_color()
# pumpkin.stop()
# pumpkin.reset()
# pumpkin.move_right()
# pumpkin.move_left()
# panel.add_pumpkin()


global RED, BLUE, GREEN, YELLOW, PURPLE, ORANGE
global colors
RED    = 0xFFFF0000
BLUE   = 0xFF0000FF
GREEN  = 0xFF00FF00
YELLOW = 0xFFFFFF00
PURPLE = 0xFF800080
ORANGE = 0xFFFFA500

#
# Change the panel colors here
#
colors = [RED, BLUE, GREEN, YELLOW, PURPLE, ORANGE]

def setup():
    size(1200, 800)
  
    #
    # Change the number of panels below
    #
    global num_panels, panel_width, panels, bg_colors
    num_panels = 5
    panel_width = width / num_panels
    panels = list()
    bg_colors = list()
  
    initialize_panels(colors)


def draw():
    for i, panel in enumerate(panels):
        add_pumpkin_flag = False
        clear_pumpkins_flag = False

        for pumpkin in panel.pumpkins:
      
            #
            # If mouse is hovering over a panel...
            #
            if i == mouseX / panel_width:
                pumpkin.bounce()

                if mousePressed:
                    if mouseButton == LEFT:
                        pumpkin.explode()
                    elif mouseButton == RIGHT:
                        pumpkin.spin()

                if keyPressed:
                    if key == 'r':
                        pumpkin.reset()
                        clear_pumpkins_flag = True
                    elif key == 's':
                        pumpkin.stop()
                    elif key == 'a':
                        add_pumpkin_flag = True
                    elif keyCode == LEFT:
                        pumpkin.move_left(5)
                    elif keyCode == RIGHT:
                        pumpkin.move_right(5)
            else:
                pumpkin.stop()

        #
        # Outside of for loop to avoid concurrent modification exception
        #
        if add_pumpkin_flag:
            panel.add_pumpkin_random_size(int(random(0, panel_width)))

        if clear_pumpkins_flag:
            panel.pumpkins = list()
            panel.add_pumpkin(panel.pg.width / 2, 150)

        panel.draw()


def mouseWheel(event):
    for pumpkin in panels[mouseX / panel_width].pumpkins:
        #
        # event.getCount() returns < 0 if scrolled up (away from the user)
        # event.getCount() returns > 0 if scrolled down (toward the user)
        #
        if event.getCount() > 0:
            pumpkin.set_spin_speed( pumpkin.spin_speed + 2 )
        else:
            pumpkin.set_spin_speed( pumpkin.spin_speed - 2 )


def initialize_panels(colors):
    global panel_width, bg_colors, panels
    
    panel_width = width / num_panels

    for i in range(num_panels):
        bg_colors.append(colors[i % len(colors)])
        panels.append(Panel(i * panel_width, panel_width, bg_colors[i]))


class Panel:
    def __init__(self, x, w, bg_color):
        self.x = x
        self.y = 0
        self.w = w
        self.h = height
        self.bg_color = bg_color
        self.pg = createGraphics(self.w, self.h)
        self.bg = createImage(self.pg.width, self.pg.height, ARGB)

        self.pumpkins = list()
        self.add_pumpkin(self.pg.width / 2, 150)

        for i in range(len(self.bg.pixels)):
            alpha = map(i, 0, len(self.bg.pixels), 0, 255 + 100)
            self.bg.pixels[i] = color(red(bg_color), green(bg_color), blue(bg_color), alpha)

    def add_pumpkin(self, x, size):
        pumpkin = Pumpkin(x, self.bg_color, self.pg)
        pumpkin.set_size(size)
        pumpkin.set_bounce_height(int(random(10, height/20)))
        self.pumpkins.append(pumpkin)
  
    def add_pumpkin_random_size(self, x):
        self.add_pumpkin(x, int(random(10, 200)))

    def draw(self):
        self.pg.beginDraw();

        self.pg.fill(255);
        self.pg.rect(0, 0, self.pg.width, self.pg.height);
        self.pg.image(self.bg, 0, 0);
    
        for pumpkin in self.pumpkins:
            pumpkin.draw()

        self.pg.endDraw()

        image(self.pg, self.x, self.y)
