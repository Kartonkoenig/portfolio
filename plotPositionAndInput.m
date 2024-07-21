function plotPositionAndInput(position, s_ortho, reference, x0, u, n,i, collision_point, radius, center, top, channels)
    
    % Fix dimensions
    if size(position,1) ~= 3
        position = position';
    end

    if size(s_ortho,1) ~= 1
        s_ortho = s_ortho';
    end

    if size(collision_point,1) ~= 3
        collision_point = collision_point';
    end

    f = figure();
    set(gcf,'color','w');
    set(groot,'defaultAxesTickLabelInterpreter','latex');
    tiledlayout(2,4);
    
    % Position (z-Position corrected for particle thickness)
    nexttile([2,2])        
    conePlot(radius, center, top, channels)
    hold on;
    grid on;
    plot3(position(1,:), position(2,:), position(3,:)- s_ortho(1,:), 'r', LineWidth=1.6);
    plot3(reference(1), reference(2), reference(3), 'r*', 'LineWidth', 1.4, 'MarkerSize', 12)
    plot3(x0(1), x0(2), x0(3), 'r.', 'LineWidth', 1.4, 'MarkerSize', 16)
    xlabel('Position [m]');
    ylabel('Position [m]');
    
    
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
    plot(position(3,:)- s_ortho(1,:), LineWidth=1.6);
    plot(collision_point(3,:), LineWidth=1.6);
    xlabel('t in s');
    ylabel('Particle height');

    % Motorstrom
    nexttile        
    hold on;
    grid on;
    plot(i, LineWidth=1.6);
    xlabel('t in s');
    ylabel('Motor current');
    
end