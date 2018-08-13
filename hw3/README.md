## Summary:
Design a Local Median Filter Engine (LMFE):  
1. Input image is 128x128 gray-scale image.  
2. Median filter size is 7x7.  
3. Utilizing Single Port SRAM (2 choices: 1KB / 8KB SRAM) to save input pixels because Host would send the pixels of picture sequentially and only once.

## Block Diagrams:  
1. Local Median Filter Engine:
<img src=https://github.com/02stevenyang850527/CVSD/blob/master/pics/hw3_1.png alt="LMFE" width=500 height=185>  
2. Signals between Host and LMFE:
<img src=https://github.com/02stevenyang850527/CVSD/blob/master/pics/hww3_2.png alt="hw3_2" width=500 height=280>  
3. Example of input image:  
<img src=https://github.com/02stevenyang850527/CVSD/blob/master/pics/hw3_3.png alt="hw3_3" width=500 height=350>  


