# turtlegifmaker
Provides the module and shell scripts needed to turn your python turtle drawing into a gif that animates the drawing process.

# Instructions
1. Import this module into your animation repo. Replace `your_drawing_function` with your desired animation function. 

2. You have two options. You can run the shell script, or you can: 

In terminal, run:
```
brew install magick
brew install ghostscript 
```

Then, 
```
python gifcode.py
magick screenshot*.eps student.gif
rm screenshot*.eps
```

## Command-line interface

You will need [invoke](http://www.pyinvoke.org/) installed (`pip install invoke`). Then you can run `inv --list` to see 
available tasks and `inv make-gifs`


# Credits
Written by [Jenny Han](https://github.com/jennylihan)

Code adapted from https://stackoverflow.com/questions/41319971/is-there-a-way-to-save-turtles-drawing-as-an-animated-gif/41353016#41353016
