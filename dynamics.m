function dx = dynamics(t, x, u, tdata, is_on_cone)

    % Prepares ODEs for dynamic friction and contact force

    % tdata - Time stamps of input sequence u

    % System parameters

    % Static friction parameters
    epsilon     = 0.0000001;        % Stability parameter
    d           = 750;              % Damping parameter viscous friction
    my_c        = 0.85;             % Gleitreibungskoeffzient
    v_c         = 0.00005;          %  Übergangsgeschwindigkeit
    my_s        = 150;              % 0.99 Haftreibungskoeffzient
    v_s         = 1.0000e-2;        % 1.0000e-3, 0.1 Stribeck velocity

    % Dynamic friction parameters
    m           = 0.125;         	% Mass [kg]
    T_F         = 0.0003;           % Zeitkonstante Tiefpassfilter
    dq_F        = 0.0001;           % Verteilungsfaktor Gaußglocke für LPV-Filter


    % Contact force Parameters
    g           = 9.81;             % Gravitational acceleration [m/s^2]
    s0          = 0.025;            % Outer radius of contact sphere [m]
    compr       = 0.5;              % sc-to-s0 ratio
    sc          = compr*s0;         % Compression radius of contact sphere [m]
    ra          = 0.99;             % Approximation parameter activation function
    rd          = 120;              % Dissipation param [s/m], defines energy loss during contact, Specker value: 5.9
    rf          = 120;              % Force param [N], max. force by barrier during compression

    % Cone parameters
    tilt        = 15;              % Angle of distribution cone base [°]
    diameter    = 0.45;             % Diameter of distribiution plate [m]
    radius      = diameter/2;       % Radius of distribution plate [m]
    height      = coneHeight(tilt, diameter); % Cone height[m]
    center      = [0 0 0];
    top         = [center(1) center(2) center(3) + height];
    channels    = 14;
    m_kegel     = 2.7;              % Masse Kegel [kg]

    % Motor - Maxon EC frameless DT 85L, 90 mm
    J_Motor = 1.3 * 10^-4;          % Rotor inertia [kg m^2]
    c = 0.001;                      % Friction coefficient c.f. Iqteit et al. (2022) [kg * m/s]
    K_m = 242 * 10^-3;              % Torque constant [Nm/A] = Back-EMF constant [V/s^-1]
    R = 0.218;                      % Resistance [Ohm]
    L = 0.632 * 10^-3;              % Inductance [H]

    % Define states
    pos         = [x(1); x(2); x(3)];  % positon vector
    vel         = [x(4); x(5); x(6)];  % velocity vector
    QR_dyn      = [x(7); x(8); x(9)];  % dynamic friction force vector
    omega       = x(10);               % angular speed
    i           = x(11);               % Strom
    n           = omega / (2*pi);     % Drehzahl

    % Berechnung Trägheitsmoment
    J_Kegel     = 0.5 * m_kegel * radius^2;
    dq          = sqrt(pos(1)^2 + pos(2)^2);    % euklidische Distanz zur Drehachse
    J_Partikel  = 2/3 * m * s0^2 + m * dq^2;    % Trägheit Partikel mit Steiner Anteil

    if is_on_cone
        J       = J_Motor + J_Kegel + J_Partikel;
    else
        J       = J_Motor + J_Kegel;
    end

    % Dynamisches Lastmoment
    % T_dyn = J * (2*pi)/60 * n/t;
    T_dyn = 0;
    % Berechnung omega_punkt und i_punkt
    omega_punkt = (-c/J) * omega + (K_m/J) * i;
%
%     if (omega_punkt ~= 0)                               % Wenn Drehbewegung, dann kommt dyn Lastmoment zum Tragen
%         J           = J + T_dyn;
%         omega_punkt = (-c/J) * omega + (K_m/J) * i;
%     end
%
    i_punkt     = (-K_m/L) * omega - R/L * i + u/L;

    % Calculate difference velocity
    omega_vec   = [0; 0; omega];                        % omega_vec = [0; 0; omega]
    vel_p       = cross(omega_vec,pos);                 % Plate velocity
    vel_dif     = vel - vel_p;                          % Velocity difference between mass and plate
    e_v         = -vel_dif/(norm(vel_dif) + epsilon);   % Unit vector of direction of difference velocity (Reibkraft zeigt entgegen Bewegungsrichtung)
    v           = norm(vel_dif);                        % Betrag des Differenzgeschwindigkeitsvektors

    % Activation function
    barrier_pos = CollisionPoint(radius, center, top, channels, pos); % Collision point with barrier
    s_ortho     = pos(3) - barrier_pos(3);              % Distance to barrier
    dz_barrier  = -(top(3)*(pos(1)*vel(1) + pos(2)*vel(2)))/(radius*(pos(1)^2 + pos(2)^2)^(1/2)); % z-velocity of collision point movement
    barrier_vel = [vel(1); vel(2); dz_barrier];         % Velocity of barrier
    v_ortho     = vel(3) - barrier_vel(3);              % Relative velocity between particle and barrier

    rc          = (s0 + sc)/2;                          % Barrier offset
    rt          = (2/(s0 - sc)) * atanh(ra);            % Transition param for defining object elasticity

    if sqrt(pos(1)^2 + pos(2)^2) > radius
        R_a     = 0;
    else
        R_a     = (1 - tanh(rt*(s_ortho - rc)))/2;      % Activation function
    end

    % Resistance force of barrier
    % Direction of Fc: d(v_ortho)/d(q_dot)
    e_Fc_x      = (top(3)*pos(1))/(radius*(pos(1)^2 + pos(2)^2)^(1/2));
    e_Fc_y      = (top(3)*pos(2))/(radius*(pos(1)^2 + pos(2)^2)^(1/2));
    e_Fc_z      = 1;
    e_Fc        = [e_Fc_x; e_Fc_y; e_Fc_z];
    Fc          = e_Fc*((1 - tanh(rd*v_ortho))/2)*rf;
    F_ortho     = R_a.* Fc;                             % Normalkräfte der Kontaktpunkte

    % Gravitation and acceleration
    F_g         = [0; 0; -m*g];                         % Weight force
    acc         = (1/m)*(QR_dyn + F_ortho + F_g);       % Acceleration

    % Static model with friction and contact force
    Fr_visc     = d*v*e_v;
    Fr_coul     = Fc*(1/rf)*my_c*tanh(v/v_c).*e_v;
    Fr_stri     = v*exp(0.5 - 0.5*(v/v_s).^2)*(Fc*(1/rf) * (1/v_s) *(my_s - my_c*tanh(v/v_s)) - d).*e_v;

    QR_stat     = R_a.*(Fr_visc + Fr_coul + Fr_stri);

    % Dynamic model with friction and contact
    a           = 1 - exp(-(vel_dif/dq_F).^2);
    dQR_dyn     = (a/T_F).*(QR_stat - QR_dyn);

    % Define state derivatives
    omega_punkt = [omega_punkt];
    i_punkt     = [i_punkt];
    dx          = [vel; acc; dQR_dyn; omega_punkt(1); i_punkt(1)];
end
