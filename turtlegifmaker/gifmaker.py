from turtle import *
import tkinter as _
from project import main
import settings
from PIL import ImageGrab, Image
import os


_.ROUND=_.BUTT

running = True
FRAMES_PER_SECOND = 10
image_list = []

def grab_canvas():
    "Grabs an Image of the screen"
    canvas = getscreen().getcanvas()
    x0 = canvas.winfo_rootx() + canvas.winfo_x()
    y0 = canvas.winfo_rooty() + canvas.winfo_y()
    x1 = x0 + canvas.winfo_width()
    y1 = y0 + canvas.winfo_height()
    return ImageGrab.grab(bbox=(x0*2 + 15, y0*2 + 15, x1*2 - 15, y1*2 -15)) #due to pixel doubling on Mac Retina Screen

def draw(your_drawing_function):
    your_drawing_function()
    print("ok finished drawing!")
    stop()

def stop():
    global running
    running = False

def record_screen():
    curr_image = grab_canvas()
    image_list.append(curr_image)
    if running:
        ontimer(record_screen, int(1000 / FRAMES_PER_SECOND))

def makegif(your_drawing_function, gif_name):
    speed(0)
    hideturtle()
    record_screen()  # start the recording
    draw(your_drawing_function) # start drawing
    path_name = os.getcwd() + gif_name + '.gif'
    image_list[0].save(path_name, format='GIF',
               save_all=True, append_images=image_list[1:], optimize=False, duration=40, loop=0)

if __name__ == '__main__':
    makegif(main, 'test');
