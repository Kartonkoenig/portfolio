function [t, x, u_fuzzy, regeldiff_winkel, regeldiff_radius] = fuzzySimulateWithConstInput(t0, x0, t_end, T, u, t_u, ODE_Opt, reference, radius, center, top, channels, plott)
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
    x           = x0;
    t           = t0;
    t_span      = [t0:T:t_end];   % Time span of ODE simulations
    u_const     = interp1(t_u, u, t_span, 'previous');
    

    % WICHTIG: Fuzzy-System in Zeile 28 manuell eintragen!
    % mamdani1 für den ersten Mamdani-Regler wie in der BA
    % mamdani2 für den finalen Mamdani-Regler wie in der BA
    % takagi1 für den Takagi-Sugeno-Regler wie in der BA

    %% Integration of Fuzzy Controller
    %
    % Initialize necessary variables for first iteration
    max_rotations           = 100;
    position                = zeros(3, max_rotations);
    position(:,1)           = x(1:3,:);
    mamdani                 = readfis('mamdani1');      
    count_rotations         = 1;               
    [theta_ref, rho_ref, ~] = cart2pol(reference(1), reference(2), reference(3));    % Transform to polar coordinates
    [theta, rho, ~]         = cart2pol(x(1, end), x(2, end), x(3, end));
    regeldiff_winkel        = theta_ref - theta;        % angle error
    regeldiff_radius        = rho_ref - rho;            % radial error
    if regeldiff_winkel > pi
            regeldiff_winkel = regeldiff_winkel -2*pi;
    elseif regeldiff_winkel < -pi
            regeldiff_winkel = 2*pi + regeldiff_winkel;
    end

    regeldiff_winkel_archive = zeros(1,1000);
    regeldiff_winkel_archive(count_rotations) = regeldiff_winkel;
    regeldiff_radius_archive = zeros(1,1000);
    regeldiff_radius_archive(count_rotations) = regeldiff_radius;
    
    
    u_fuzzy                 = zeros(1, max_rotations);
    is_on_cone              = (abs(rho) <= radius);
    has_reached_target      = isequal(position(:,end)', reference);


    % While particle on cone feeder simulate system
    while  (is_on_cone == true)
        t_u_new                     = [t_span(count_rotations) t_span(count_rotations+1)];
        u_fuzzy(count_rotations)    = evalfis(mamdani, [regeldiff_winkel regeldiff_radius]);  
        [t_sim, x_sim]              = ode23t(@(t,x) dynamics(t, x, u_fuzzy(count_rotations), t_u_new, is_on_cone), t_u_new, x(:,end), ODE_Opt);
        x                           = [x x_sim(end,:)'];
        t                           = [t (t(end) + T)];

        [theta, rho, ~]    = cart2pol(x(1,end), x(2,end), x(3,end));   % Take newest x,y,z coordinates and transform to polar
        regeldiff_winkel   = theta_ref - theta;        % angle error
        regeldiff_radius   = rho_ref - rho;            % radial error
        if regeldiff_winkel > pi
            regeldiff_winkel = regeldiff_winkel -2*pi;
        elseif regeldiff_winkel < -pi
            regeldiff_winkel = 2*pi + regeldiff_winkel;
        end
        
        regeldiff_winkel_archive(count_rotations+1) = regeldiff_winkel;
        regeldiff_radius_archive(count_rotations+1) = regeldiff_radius;

        position(:,count_rotations)    = x_sim(end,1:3); 

        % Check if particle is still on cone or reached target position
        is_on_cone          = (abs(rho) <= radius);
        has_reached_target  = isequal(position(:,end)',reference);
        if has_reached_target == true
            fprintf('Reached target!')
            break
        end

        % If cone rotates too long, break out
        count_rotations = count_rotations + 1;
        if count_rotations > max_rotations
            %fprintf('Stopped simulating. Too many rotations');
            %break
        end
    end

    z           = position(3,:);
    omega       = x(10,:);
    n           = omega / 2 * pi;   
    currenti    = x(11,:);
    
    collision_point = zeros(3, numel(z));
    for ii = 1:numel(z)
        collision_point(:,ii)= CollisionPoint(radius, center, top, channels, position(:,ii));
    end
    s_ortho     = position(3,:) - collision_point(3,:);
    
    % Plot particle´s trajectory, input, and height over time
    if plott == true
        plotConeBase(position, s_ortho, reference, x0, u_fuzzy,n,currenti, collision_point, radius, center, top, channels)
        %plotPositionAndInput(position, s_ortho, reference, x0, u_fuzzy,n,currenti, collision_point, radius, center, top, channels)
    end
end