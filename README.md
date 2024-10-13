# Affective Computing final project: Deepface Moodtracker

## Setup
Before getting into the engine there's two scripts we need to have running in terminal:
1. **apy.py** python script inside the deepface/api/src directory(not in the repo)
2. **camera_stream.py** inside the python directory(inside the repo)

## Running the app
Starting the app is as simple as pressing the play button on the top right:
![image](https://github.com/user-attachments/assets/37096fc3-c516-4044-a8f5-a15aa839c8fe)

## Editing the code
Code can be edited directly in the godot editor, you can open the text editor by either clicking the script button on the top center:

![image](https://github.com/user-attachments/assets/efb3319b-ac95-4010-ba4a-549f7cfe101b)

or you can open an specific script from the node tree at the left by clicking on the little scroll icon on the 'Main' node:

![image](https://github.com/user-attachments/assets/cb1dd4ef-542e-48af-947a-6e7139cb36ed)

## Stuff to consider
The deepface analysis tools seem to be trained for clear, crisp and well lit images. Analysis results gotten from webcam images are probably quite innacurate, good lighting and closeness to the camera might help with this. If a 400 HTTP error pops up in the godot output terminal is probably because the face is not being detected due to the webcam issues previously listed.
