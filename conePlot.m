function conePlot(radius, center, top, channels)

   % Plots a cone and its base with variable amount of dosing channels

   % Parameters
   % radius     - Radius of cone
   % center     - x-,y-,z-position of center of cone base
   % top        - x-,y-,z-position of cone top
   % channels   - int number of channels of the distributor plate (BA-Fall: 14)

   phi     = linspace(0, 2*pi, 2000);
   x       = radius*cos(phi) + center(1);
   y       = radius*sin(phi) + center(2);
   z       = zeros(1, numel(x)) + center(3);

   % Plot pane with center
   plot3(center(1), center(2), center(3), 'k*', 'LineWidth', 1.4, 'MarkerSize', 10);
   hold all;
   grid on;
   patch(x, y, z, 'FaceColor', "#99999e", 'FaceAlpha', 0.1, 'EdgeColor', "#0a0a0a")

   % Plot dosing channels
   stepWidth       = 360/channels;
   i = 1;
   for angle = 0:stepWidth:360
        channelX(1)   = 0;
     channelY(1)   = 0;
     channelX(2)   = channelX(1) + radius * cosd(angle);
     channelY(2)   = channelY(1) + radius * sind(angle);
     plot(channelX, channelY, 'k--');
   end
   text(0, 0.2, '1', 'interpreter','Latex');
   text(0.08, 0.18, '2', 'interpreter','Latex');
   text(0.15, 0.12, '3', 'interpreter','Latex');
   text(0.19, 0.045, '4', 'interpreter','Latex');
   text(0.19, -0.045, '5', 'interpreter','Latex');
   text(0.15, -0.12, '6', 'interpreter','Latex');
   text(0.085, -0.18, '7', 'interpreter','Latex');
   text(0, -0.2, '8', 'interpreter','Latex');
   text(-0.085, -0.18, '9','interpreter','Latex');
   text(-0.15, -0.12, '10','interpreter','Latex');
   text(-0.19, -0.045, '11','interpreter','Latex');
   text(-0.19, 0.045, '12','interpreter','Latex');
   text(-0.15, 0.12, '13','interpreter','Latex');
   text(-0.08, 0.18,  '14','interpreter','Latex');


  % Plot cone
   for i= 1:1999
       xCone  = [x(i); x(i+1); 0];
       yCone  = [y(i); y(i+1); 0];
       zCone  = transpose(top);
       fill3(xCone, yCone, zCone,[1; 0.5; 0], "EdgeColor",'None', "FaceAlpha",0.5) % bunter Plot "None" für EdgeColor, grau "#526070"
   end

end
