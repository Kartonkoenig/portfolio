function dx = multidynamics(t, x, u, tdata, is_on_cone1, is_on_cone2)

    % Dynamics für zwei Partikel

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
    % x1
    pos1        = [x(1); x(2); x(3)];  % position vector
    vel1        = [x(4); x(5); x(6)];  % velocity vector
    QR_dyn1     = [x(7); x(8); x(9)];  % dynamic friction force vector

    % x2
    pos2        = [x(10); x(11); x(12)];
    vel2        = [x(13); x(14); x(15)];
    QR_dyn2     = [x(16); x(17); x(18)];

    omega       = x(19);               % angular speed
    i           = x(20);               % Strom


    % Berechnung Trägheitsmoment
    J_Kegel     = 0.5 * m_kegel * radius^2;
    dq          = sqrt(pos1(1)^2 + pos1(2)^2);    % euklidische Distanz zur Drehachse
    dq2         = sqrt(pos2(1)^2 + pos2(2)^2);
    J_Partikel1  = 2/5 * m * s0^2 + m * dq^2;    % Trägheit Partikel mit Steiner Anteil
    J_Partikel2  = 2/5 * m * s0^2 + m *dq2^2;

    if is_on_cone1 && is_on_cone2
        J       = J_Motor + J_Kegel + J_Partikel1 + J_Partikel2;
    elseif is_on_cone1 && ~is_on_cone2
        J       = J_Motor + J_Kegel + J_Partikel1;
    elseif ~is_on_cone1 && is_on_cone2
        J       = J_Motor + J_Kegel + J_Partikel2;
    else
        J       = J_Motor + J_Kegel;
    end

    % Berechnung omega_punkt und i_punkt
    omega_punkt = (-c/J) * omega + (K_m/J) * i;

    i_punkt     = (-K_m/L) * omega - R/L * i + u/L;

    %% Calculate difference velocity
    % x1
    omega_vec   = [0; 0; omega];                        % omega_vec = [0; 0; omega]
    vel_p1       = cross(omega_vec,pos1);                % Plate velocity
    vel_dif1     = vel1 - vel_p1;                          % Velocity difference between mass and plate
    e_v1         = -vel_dif1/(norm(vel_dif1) + epsilon);   % Unit vector of direction of difference velocity (Reibkraft zeigt entgegen Bewegungsrichtung)
    v1           = norm(vel_dif1);                        % Betrag des Differenzgeschwindigkeitsvektors

    % x2
    vel_p2      = cross(omega_vec, pos2);
    vel_diff2   = vel2 - vel_p2;
    e_v2        = -vel_diff2/(norm(vel_diff2) + epsilon);
    v2          = norm(vel_diff2);


    %% Activation function
    % x1
    barrier_pos1 = CollisionPoint(radius, center, top, channels, pos1);  % Collision point with barrier
    s_ortho1     = pos1(3) - barrier_pos1(3);                             % Distance to barrier
    dz_barrier1  = -(top(3)*(pos1(1)*vel1(1) + pos1(2)*vel1(2)))/(radius*(pos1(1)^2 + pos1(2)^2)^(1/2)); % z-velocity of collision point movement
    barrier_vel1 = [vel1(1); vel1(2); dz_barrier1];                       % Velocity of barrier
    v_ortho1     = vel1(3) - barrier_vel1(3);                             % Relative velocity between particle and barrier

    rc          = (s0 + sc)/2;                          % Barrier offset
    rt          = (2/(s0 - sc)) * atanh(ra);            % Transition param for defining object elasticity

    if sqrt(pos1(1)^2 + pos1(2)^2) > radius
        R_a1     = 0;
    else
        R_a1     = (1 - tanh(rt*(s_ortho1 - rc)))/2;      % Activation function
    end

    % x2
    barrier_pos2    = CollisionPoint(radius, center, top, channels, pos2);
    s_ortho2        = pos2(3) - barrier_pos2(3);
    dz_barrier2     = -(top(3)*(pos2(1)*vel2(1) + pos2(2)*vel2(2)))/(radius*(pos2(2)^2 + pos2(2)^2)^(1/2));
    barrier_vel2    = [vel2(1); vel2(2); dz_barrier2];
    v_ortho2        = vel2(3) - barrier_vel2(3);

    if sqrt(pos2(1)^2 + pos2(2)^2) > radius
        R_a2         = 0;
    else
        R_a2         = (1 - tanh(rt*(s_ortho2 - rc)))/2;
    end

    % x1-x2
    s_ortho12       = sqrt((pos2(1)-pos1(1))^2 + (pos2(2)-pos1(2))^2 + (pos2(3)-pos1(3))^2);       % Distance particle to particle
    v_ortho12       = ((2*(vel2(1)-vel1(1))*(pos2(1)-pos1(1))) + (2*(vel2(2)-vel1(2))*(pos2(2)-pos1(2))) + (2*(vel2(3)-vel1(3))*(pos2(3)-pos1(3)))) / (2*s_ortho12);

    R_a12   = (1 - tanh(rt*(s_ortho12 - rc)))/2;

    %% Resistance force of barrier
    % x1-x2
    % Richtungsvektoren sind Partialableitungen von v_ortho nach q_punkt
    e_Fc_12_1_1   = (2*pos1(1) - 2*pos2(1))/(2*((pos1(1) - pos2(1))^2 + (pos1(2) - pos2(2))^2 + (pos1(3) - pos2(3))^2)^(1/2));
    e_Fc_12_1_2   = (2*pos1(2) - 2*pos2(2))/(2*((pos1(1) - pos2(1))^2 + (pos1(2) - pos2(2))^2 + (pos1(3) - pos2(3))^2)^(1/2));
    e_Fc_12_1_3   = (2*pos1(3) - 2*pos2(3))/(2*((pos1(1) - pos2(1))^2 + (pos1(2) - pos2(2))^2 + (pos1(3) - pos2(3))^2)^(1/2));

    e_Fc_12_2_1   = -(2*pos1(1) - 2*pos2(1))/(2*((pos1(1) - pos2(1))^2 + (pos1(2) - pos2(2))^2 + (pos1(3) - pos2(3))^2)^(1/2));
    e_Fc_12_2_2   = -(2*pos1(2) - 2*pos2(2))/(2*((pos1(1) - pos2(1))^2 + (pos1(2) - pos2(2))^2 + (pos1(3) - pos2(3))^2)^(1/2));
    e_Fc_12_2_3   = -(2*pos1(3) - 2*pos2(3))/(2*((pos1(1) - pos2(1))^2 + (pos1(2) - pos2(2))^2 + (pos1(3) - pos2(3))^2)^(1/2));

    e_Fc_12_1   = [e_Fc_12_1_1; e_Fc_12_1_2; e_Fc_12_1_3];
    e_Fc_12_2   = [e_Fc_12_2_1; e_Fc_12_2_2; e_Fc_12_2_3];

    Fc12_1      = e_Fc_12_1*((1 - tanh(rd*v_ortho12))/2)*rf;
    Fc12_2      = e_Fc_12_2*((1 - tanh(rd*v_ortho12))/2)*rf;

    F_ortho12_1 = R_a12 .* Fc12_1;
    F_ortho12_2 = R_a12 .* Fc12_2;

    % x1
    % Direction of Fc: d(v_ortho)/d(q_dot)
    e_Fc_x1      = (top(3)*pos1(1))/(radius*(pos1(1)^2 + pos1(2)^2)^(1/2));
    e_Fc_y1      = (top(3)*pos1(2))/(radius*(pos1(1)^2 + pos1(2)^2)^(1/2));
    e_Fc_z1      = 1;
    e_Fc1        = [e_Fc_x1; e_Fc_y1; e_Fc_z1];
    Fc1          = e_Fc1*((1 - tanh(rd*v_ortho1))/2)*rf;
    F_ortho1     = R_a1.* Fc1;                             % Normalkräfte der Kontaktpunkte

    % Gravitation and acceleration
    F_g         = [0; 0; -m*g];                         % Weight force
    acc1         = (1/m)*(QR_dyn1 + F_ortho1 + F_g + F_ortho12_1);       % Acceleration

    % Static model with friction and contact force
    Fr_visc1     = d*v1*e_v1;
    Fr_coul1     = Fc1*(1/rf)*my_c*tanh(v1/v_c).*e_v1;
    Fr_stri1     = v1*exp(0.5 - 0.5*(v1/v_s).^2)*(Fc1*(1/rf) * (1/v_s) *(my_s - my_c*tanh(v1/v_s)) - d).*e_v1;

    QR_stat1     = R_a1.*(Fr_visc1 + Fr_coul1 + Fr_stri1);

    % Dynamic model with friction and contact
    a1           = 1 - exp(-(vel_dif1/dq_F).^2);
    dQR_dyn1     = (a1/T_F).*(QR_stat1 - QR_dyn1);


    % x2
    % Direction of Fc: d(v_ortho)/d(q_dot)
    e_Fc_x2      = (top(3)*pos2(1))/(radius*(pos2(1)^2 + pos2(2)^2)^(1/2));
    e_Fc_y2      = (top(3)*pos2(2))/(radius*(pos2(1)^2 + pos2(2)^2)^(1/2));
    e_Fc_z2      = 1;
    e_Fc2        = [e_Fc_x2; e_Fc_y2; e_Fc_z2];
    Fc2          = e_Fc2*((1 - tanh(rd*v_ortho2))/2)*rf;
    F_ortho2     = R_a2.* Fc2;                             % Normalkräfte der Kontaktpunkte

    % Gravitation and acceleration
    F_g         = [0; 0; -m*g];                         % Weight force
    acc2         = (1/m)*(QR_dyn2 + F_ortho2 + F_g + F_ortho12_2);       % Acceleration

    % Static model with friction and contact force
    Fr_visc2     = d*v2*e_v2;
    Fr_coul2     = Fc2*(1/rf)*my_c*tanh(v2/v_c).*e_v2;
    Fr_stri2     = v2*exp(0.5 - 0.5*(v2/v_s).^2)*(Fc2*(1/rf) * (1/v_s) *(my_s - my_c*tanh(v2/v_s)) - d).*e_v2;

    QR_stat2     = R_a2.*(Fr_visc2 + Fr_coul2 + Fr_stri2);

    % Dynamic model with friction and contact
    a2           = 1 - exp(-(vel_diff2/dq_F).^2);
    dQR_dyn2     = (a2/T_F).*(QR_stat2 - QR_dyn2);




    %% Define state derivatives
    omega_punkt = [omega_punkt];
    i_punkt     = [i_punkt];
    dx          = [vel1; acc1; dQR_dyn1; vel2; acc2; dQR_dyn2; omega_punkt(1); i_punkt(1)];


end
