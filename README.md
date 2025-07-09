# UV Exposure Device

When planning my first attempt to etch my own circuit boards, I realized that I needed a solution for exposing the circuit boards to UV light. Of course, it was tempting for me to solve this task on a DIY basis as well. Many people on the net have built their own UB exposure devices based on old flatbed scanners. I liked that idea and so I built my own UV exposure device too:

<img src="images/IMG_5348.JPG" height="200" /><img src="images/IMG_5359.JPG" height="200" /><img src="images/IMG_7681_UV_Controllere.PNG" height="200" />

For the sake of transparency, I have to admit that I have never used the device to make printed circuit boards because I have since learned about the ironing method and stuck with it. Nevertheless, I am sharing my work in case it helps others who want to follow a similar path.

## Architecture

I found an old defective flatbet scanner for my project. I barely managed to put the components inside the slim case and there was almost no space for a small display, a rotary encoder and such things. So I thought it would be nice to control the device from my smartphone via bluetooth. That would give me a lot of options like individual presets and a nice GUI. I never developed a native App for iOS before. I was always convinced that platform-independend web-apps would be the right way to go. So I (successfully!) wrote a small Javascript program which proofed that the UV device could be controlled from a website via bluetooth. But... iOS does not support webserial (the required functionality) yet. So ... give up the plan or develop a native app for iOS? I tried the later. I turned out that it wasn't that hard to do it in Swift with XCode. Everything worked out quite nicely. This repo contains the web-software and the iOS app.

### Schematic

The schematic is simple as can be. We have an LED strip with a 12V power supply. The ESP32 can be fed by this source too. We use a 7805 to turn the 12V into 5V and we use an IRF510 MOSFET (many other logic-level MOSFETs should work too) to switch the LED strip on and off. 

![schematic](schematic/schematic.png)





