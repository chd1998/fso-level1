#!/usr/bin/python

from tkinter import *
import time

# Code to add widgets will go here...



master = Tk()
var = IntVar()
title_txt="Fiber Displacement Sensor      "+time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
master.title(title_txt)

Label(master, text="position X").grid(sticky=E)
Label(master, text="position Y").grid(sticky=E)
Label(master, text="position Z").grid(sticky=E)
Label(master, text="Temp.").grid(sticky=E)
Label(master, text="Humidity").grid(sticky=E)
Label(master, text="Pressure").grid(sticky=E)

Label(master, text="IP").grid(sticky=E)


e1 = Entry(master)
e2 = Entry(master)
e3 = Entry(master)
e4 = Entry(master)
e5 = Entry(master)
e6 = Entry(master)
e7 = Entry(master)


e1.grid(row=0, column=1)
e2.grid(row=1, column=1)
e3.grid(row=2, column=1)
e4.grid(row=3, column=1)
e5.grid(row=4, column=1)
e6.grid(row=5, column=1)
e7.grid(row=6, column=1)

#checkbutton = Checkbutton(master, text='Preserve aspect', variable=var)
#checkbutton.grid(columnspan=2, sticky=W)

photo = PhotoImage(file='')
label = Label(image=photo)
label.image = photo
label.grid(row=0, column=2, columnspan=2, rowspan=2, sticky=W+E+N+S, padx=5, pady=5)

button1 = Button(master, text='Connect')
button1.grid(row=6, column=3)

button2 = Button(master, text='Exit')
button2.grid(row=6, column=4)

mainloop()