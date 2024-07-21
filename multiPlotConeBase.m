function multiPlotConeBase(position1,position2, s_ortho1, s_ortho2, reference, x0_1, x0_2, u, n,currenti, collision_point1, collision_point2, radius, center, top, channels)
    
    % Plot-Funktion für zwei Partikel-Trajektorien

    phi     = linspace(0, 2*pi, 2000);
    x       = radius*cos(phi) + center(1);
    y       = radius*sin(phi) + center(2);
    z       = zeros(1, numel(x)) + center(3); 
    
    % Fix dimensions
    if size(position1,1) ~= 3
        position1 = position1';
    end

    if size(position2,1) ~= 3
        position2 = position2';
    end

    if size(s_ortho1,1) ~= 1
        s_ortho1 = s_ortho1';
    end

    if size(s_ortho2,1) ~= 1
        s_ortho2 = s_ortho2';
    end

    if size(collision_point1,1) ~= 3
        collision_point1 = collision_point1';
    end

    if size(collision_point2, 1) ~= 3
        collision_point2 = collision_point2';
    end
   

    pos_interp_x = interp(position1(1,:), 4);
    pos_interp_y = interp(position1(2,:),4);

    pos2_interp_x = interp(position2(1,:), 4);
    pos2_interp_y = interp(position2(2,:), 4);

    f = figure();
    set(gcf,'color','w');
    set(groot,'defaultAxesTickLabelInterpreter','latex');
    tiledlayout(2,4);
    %tiledlayout(2,2);
    
    
    % Position (z-Position corrected for particle thickness)
    nexttile([2,2])        
    plot(center(1), center(2),'kx', 'LineWidth', 1.4, 'MarkerSize', 10);
    hold all;
    grid on;
    patch(x, y, z, 'FaceColor', "#99999e", 'FaceAlpha', 0.1, 'EdgeColor', "#0a0a0a")
    fill(x,y,[0.7 0.7 0.7], 'FaceAlpha', 0.4)
    hold on;
    grid on;
    plot(pos_interp_x, pos_interp_y, 'r', LineWidth=1.6);
    plot(pos2_interp_x, pos2_interp_y, 'b', LineWidth=1.6);
    plot(reference(1), reference(2), 'rx', 'LineWidth', 1.4, 'MarkerSize', 12)
    plot(x0_1(1), x0_1(2),'r.', 'LineWidth', 1.4, 'MarkerSize', 16)
    plot(x0_2(1), x0_2(2), 'b', 'LineWidth', 1.4, 'MarkerSize', 16)
    xlabel('Position [m]');
    ylabel('Position [m]');

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
    
    %
    % Input (rotational speed)
    nexttile        
    hold on;
    grid on;
    plot(n, LineWidth=1.6);
    xlabel('t in s');
    ylabel('Rotational speed');
    

    % Spannung
    nexttile
    hold on;
    grid on;
    plot(u, LineWidth=1.6);
    xlabel('t in s');
    ylabel('Spannung')

    % Height over time
    nexttile         
    hold on;
    grid on;
    plot(position1(3,:)- s_ortho1(1,:),'r', LineWidth=1.6);
    plot(position2(3,:)- s_ortho2(1,:), 'b',LineWidth=1.6);
    plot(collision_point1(3,:), LineWidth=1.6);
    xlabel('t in s');
    ylabel('Particle height');

    % Motorstrom
    nexttile        
    hold on;
    grid on;
    plot(currenti, LineWidth=1.6);
    xlabel('t in s');
    ylabel('Motor current');
    
    
end