function height = coneHeight(tilt,diameter)    

    % Calculate the height of a cone

    % Parameters
    % tilt      - Angle at the cone base
    % diameter  - Diameter of the cone

    topAngle   = 180-2*tilt;
    topAngle   = deg2rad(topAngle);

    % Sine theorem
    tilt        = deg2rad(tilt);
    height      = (sin(tilt)/sin(topAngle/2))*(diameter/2);


end