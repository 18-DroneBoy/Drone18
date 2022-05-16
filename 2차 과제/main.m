droneObj = ryze("TELLO-ED9E1A");

takeoff(droneObj);

moveleft(droneObj,'Distance',2);
turn(droneObj,deg2rad(45));
moveforward(droneObj,'Distance',2*sqrt(2));
turn(droneObj,deg2rad(135));
moveforward(droneObj,'Distance',2);
land(droneObj);
