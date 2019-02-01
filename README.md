# LED_projector

A simple tool to project pixels from an image or a video to a programmable led strip/ring/matrix.

https://youtu.be/ekIMIryXptU

![Screenshot v1](https://github.com/drvkmr/LED_projector/blob/master/Screen%20Shot.png)
![Snapshot v1](https://github.com/drvkmr/LED_projector/blob/master/snapshot.jpg)

It is optimised for usage with Arduino UNO and Neopixel LEDs. Here are the steps to be followed-
1. Connect the led strip/matrix/ring to Arduino's pin 3.
2. Upload the given arduino code.
3. Run the LED_projector_mac/windows based on what OS you are using. Skip step 4 if it runs without any issues.
4. You probably need to install java if they don't work. But if there are more issues, download and install processing IDE from processing.org and run LED_projector.pde.
5. Once in the software, go step by step. Select the right port from the PortsList.
6. Click and drag the small square and see if the colour of connected LEDs is changing.
7. If it is, you are golden. Now pick the right kind of pattern.
8. Select the number of rows (max 100). Unless you are using a 2D matrix, ignore the columns.
9. You can click and drag the pattern around, adjust its parameters with 2 sliders called gridsize and gridrotation.
10. Use getvideo and getimage to show your own file on the display.
11. Apply effects. (Fade doesn't work yet).

Thanks.