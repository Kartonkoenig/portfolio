function collision = CollisionPoint(radius, center, top, channels, position)

    % Find collission point of falling item with cone

    % Parameters
    % radius    - Radius of cone;
    % center    - x-,y-z-position of cone base center
    % top       - x-,y-z-position of cone top
    % channels  - int number of channels of the distributor plate
    % pos       - starting position of item

    % Hypothetical intersection with cone base
    cb          = [position(1); position(2); 0];

    % Intersection with cone base outer circle
    b  = ((radius)/sqrt(position(1)^2 + position(2)^2))*cb;

    % Determine equation for line from top to cone base outer circle intersection 
    %lambda1     = (position(1)-top(1))/(b(1)-top(1));
    lambda1      = sqrt(position(1)^2 + position(2)^2)/radius;

    % Determine collision point z-coordinate
    z           = top(3) + lambda1*(b(3) - top(3));
    collision   = [position(1); position(2); z];

    
    plott = false;
    if plott == true
        figure();
        plot3(position(1), position(2), position(3), '.', 'Color', "#A2142F", 'LineWidth', 1.4, 'MarkerSize', 16);
        hold all;
        plot3(cb(1), cb(2), cb(3), 'k.', 'LineWidth', 1, 'MarkerSize', 12);
        plot3(b(1), b(2), b(3), 'k.', 'LineWidth', 1, 'MarkerSize', 12);
        plot3(collision(1), collision(2), collision(3), 'r*', 'LineWidth', 1, 'MarkerSize', 6);
        conePlot(radius, center, top, channels);
        xlabel('x Position', 'FontSize', 12); ylabel('y Position', 'FontSize', 12); zlabel('z Position', 'FontSize', 12);
        title('Collision point of falling item and cone','FontSize', 14);
        stem3(position(1),position(2), position(3),'filled')
    end

end