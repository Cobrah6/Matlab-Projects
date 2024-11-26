In this project loads on an aircraft wing were calculated 
I assumed the loads to act directly into a wingSpar which was an I-shaped beam for minimal weight and maximum strength and stiffness
The dimensions of a wing Spar we provided 
This task was achieved by spilliting the work into functions 
The first function calculated the ben ding stress and store its in a stucture array called wingRootStress
The second function calculated the curvature of the wing and Stored the data in a structure array called wingSparCurvature
The third function created a major structure array called wingData with two fileds moment filed and force field
The main function the checked if the wing would bend or not under the experienced loads and created a structure array  for this and added that data to main wingData structure.
