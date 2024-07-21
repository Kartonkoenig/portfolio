function [t, x1, regeldiff_winkel_1, regeldiff_radius_1] = multiFuzzySimulateWithConstInput(t0, x0_1,x0_2,motor, t_end, T, u, t_u, ODE_Opt, reference, radius, center, top, channels, plott)
    
    % Für mehrere Partikel

    % Simulate the system keeping input constant between time steps and plot particle
    % trajecotry, control input, and particle height
    % t0    - Initial time
    % x0    - Initial states vector 
    % tend  - End time of ODE simulation
    % T     - Sample time for simulation
    % u     - Control input sequence
    % t_u   - Time stamps of original control input u
    % ODE_opt   - Options for ODE simulation
    % reference - Target position
    
    % Initialization
    x1          = x0_1;
    x2          = x0_2;
    t           = t0;
    t_span      = [t0:T:t_end];   % Time span of ODE simulations
        

    %% Integration of Fuzzy Controller
    %
    % Initialize necessary variables for first iteration
    max_rotations           = 100;

    position1               = zeros(3, max_rotations);
    position1(:,1)          = x1(1:3,:);
    position2               = zeros(3, max_rotations);
    position2(:,1)          = x2(1:3,:);

    % Auch hier das gewünschte Fuzzy-System einfügen

    mamdani                 = readfis('mamdani2');      
    count_rotations         = 1;

    [theta_ref, rho_ref, ~] = cart2pol(reference(1), reference(2), reference(3));    % Transform to polar coordinates
    
    % Regeldiffs Partikel 1
    [theta, rho1, ~]         = cart2pol(x1(1, end), x1(2, end), x1(3, end));
    regeldiff_winkel_1        = theta_ref - theta;        % angle error
    regeldiff_radius_1        = rho_ref - rho1;            % radial error
    if regeldiff_winkel_1 > pi
            regeldiff_winkel_1 = regeldiff_winkel_1 -2*pi;
    elseif regeldiff_winkel_1 < -pi
            regeldiff_winkel_1 = 2*pi + regeldiff_winkel_1;
    end

    % Regeldiffs Partikel 2
    [theta, rho2, ~]         = cart2pol(x2(1, end), x2(2, end), x2(3, end));
    regeldiff_winkel_2        = theta_ref - theta;        % angle error
    regeldiff_radius_2        = rho_ref - rho2;            % radial error
    if regeldiff_winkel_2 > pi
            regeldiff_winkel_2 = regeldiff_winkel_2 -2*pi;
    elseif regeldiff_winkel_2 < -pi
            regeldiff_winkel_2 = 2*pi + regeldiff_winkel_2;
    end

    
    u_fuzzy                 = zeros(1, 2*max_rotations);
    is_on_cone_1            = (abs(rho1) <= radius);
    is_on_cone_2            = (abs(rho2) <= radius);
    
    %has_reached_target      = isequal(position1(:,end)', reference);

    x                       = [x1;x2;motor];

    % While particle on cone feeder simulate system
    while  (is_on_cone_1 == true)
        t_u_new                     = [t_span(count_rotations) t_span(count_rotations+1)];

        % Fuzzy Partikel 1
        u_fuzzy(count_rotations)   = evalfis(mamdani, [regeldiff_winkel_1 regeldiff_radius_1]);  
        [t_sim, x_sim]             = ode23t(@(t,x) multidynamics(t, x, u_fuzzy(count_rotations), t_u_new, is_on_cone_1, is_on_cone_2), t_u_new, x(:,end), ODE_Opt);

        x1  = [x1 x_sim(end,1:9)'];
        x2  = [x2 x_sim(end,10:18)'];
        motor   = [motor x_sim(end, 19:20)'];
        x   = [x1; x2; motor];
        t   = [t (t(end) + T)];

        % Regeldifferenzen berechnen
        [theta1, rho1, ~]    = cart2pol(x1(1,end), x1(2,end), x1(3,end));   % Take newest x,y,z coordinates and transform to polar
        regeldiff_winkel_1   = theta_ref - theta1;        % angle error
        regeldiff_radius_1   = rho_ref - rho1;            % radial error
        if regeldiff_winkel_1 > pi
            regeldiff_winkel_1 = regeldiff_winkel_1 -2*pi;
        elseif regeldiff_winkel_1 < -pi
            regeldiff_winkel_1 = 2*pi + regeldiff_winkel_1;
        end

        [theta2, rho2, ~]    = cart2pol(x2(1,end), x2(2,end), x2(3,end));   
        regeldiff_winkel_2   = theta_ref - theta2;        % angle error
        regeldiff_radius_2   = rho_ref - rho2;            % radial error
        if regeldiff_winkel_2 > pi
            regeldiff_winkel_2 = regeldiff_winkel_2 -2*pi;
        elseif regeldiff_winkel_2 < -pi
            regeldiff_winkel_2 = 2*pi + regeldiff_winkel_2;
        end
        
        position1(:,count_rotations)    = x_sim(end,1:3); 
        position2(:,count_rotations)    = x_sim(end,10:12);

        % Check if particle is still on cone or reached target position
        is_on_cone_1          = (abs(rho1) <= radius);
        has_reached_target_1  = isequal(position1(:,end)',reference);
        if has_reached_target_1 == true
            fprintf('Reached target!')
            break
        end

        is_on_cone_2            = (abs(rho2) <= radius);
        has_reached_target_2    = isequal(position2(:,end)',reference);
        if has_reached_target_2 == true
            fprintf('Particle 2 has reached target!')
            break
        end

        % If cone rotates too long, break out
        count_rotations = count_rotations + 1;
        if count_rotations > max_rotations
            %fprintf('Stopped simulating. Too many rotations');
            %break
        end
    end

    z1          = position1(3,:);
    z2          = position2(3,:);
    omega       = motor(1,:);
    n           = omega / 2 * pi;   
    currenti    = motor(2,:);
    
    collision_point1 = zeros(3, numel(z1));
    for ii = 1:numel(z1)
        collision_point1(:,ii)= CollisionPoint(radius, center, top, channels, position1(:,ii));
    end
    s_ortho1     = position1(3,:) - collision_point1(3,:);
    
    collision_point2 = zeros(3, numel(z2));
    for jj = 1:numel(z2)
        collision_point2(:,jj) = CollisionPoint(radius, center, top, channels, position2(:,jj));
    end
    s_ortho2    = position2(3,:) - collision_point2(3,:);
    
    % Plot particle´s trajectory, input, and height over time
    if plott == true
        multiPlotConeBase(position1, position2, s_ortho1, s_ortho2, reference, x0_1, x0_2, u_fuzzy,n,currenti, collision_point1, collision_point2, radius, center, top, channels)
    end
end