function [value, isterminal, direction] = coneStopEvent(t,x)

  % Function to stop simulation

  distToCenter = sqrt(x(1)^2+x(2)^2)-0.225;
  value = distToCenter;           % The value that we want to be zero
  isterminal = 1;                 % Stop simulation
  direction = 0;                  % The zero can be approached from either direction
end
