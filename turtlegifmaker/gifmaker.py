#in terminal, run:
    #brew install magick
    #brew install ghostscript
    #python gifcode.py
    #magick screenshot*.eps student.gif
    #rm screenshot*.eps

from turtle import *
import tkinter as _
_.ROUND=_.BUTT

running = True
FRAMES_PER_SECOND = 10

def draw(your_drawing_function):
    your_drawing_function()
    ontimer(stop, 500)  # stop the recording (1/2 second trailer)
    done()

def stop():
    global running
    running = False

def save(counter=[1]):
    getcanvas().postscript(file = "screenshot{0:03d}.eps".format(counter[0]))
    counter[0] += 1
    if running:
        ontimer(save, int(1000 / FRAMES_PER_SECOND))

def makegif(your_drawing_function):
    speed(0)
    hideturtle()
    save()  # start the recording
    ontimer(draw(your_drawing_function), 1000)  # start the program (1/2 second leader)
    done()

if __name__ == '__main__':
    speed(0)
    hideturtle()
    save()  # start the recording
    ontimer(draw(your_drawing_function), 1000)  # start the program (1/2 second leader)
    done()
