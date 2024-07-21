% Main für die Simulation für ein Partikel

% Cone params
diameter    = 0.45;
tilt        = 15;
radius      = diameter / 2;
center      = [0 0 0];
height      = coneHeight(tilt, diameter);
channels    = 14;
top         = [center(1) center(2) center(3)+height];

% Obtain current position on cone
[p1,p2,p3] = pol2cart(10, 0.025,0);
pos = [p1,p2,p3];
%pos         = [0.11;-0.1;0.03];
CP          = CollisionPoint(radius, center, top, channels, pos);
x0          = [pos(1); pos(2); CP(3); 0; 0; 0; 0; 0; 0; 0; 0];    % letzte beide Zustände: x10=omega, x11=i

% Testdaten für Simulation
T           = 0.005;       % Sample time for simulation - seconds
t_end       = 1000;     % End time of ODE Simulation
t0          = 0;     % Initial time
t_simulation = t0:T:t_end;

%t_u_new     = [0; 0.1; 0.2; 0.3;0.4;0.5;0.6;0.7];

[ref1,ref2,ref3]   = pol2cart(0, radius,0);
reference          = [ref1 ref2 ref3];

ODE_opt     = odeset('Events', @coneStopEvent);

% n           = 0.1*[1 1 1 1 1 1 1 1 1 1];
t_u         = linspace(0, t_end, 10);
u = ones(1,length(t_u));

%[tj, xj] = ode23t(@(t,x) dynamics(t, x, u, t_u, true), t_simulation, x0);


% Simuliere System
[tfuzz, xfuzz,~,~] = fuzzySimulateWithConstInput(t0, x0, t_end, T, u, t_u, ODE_opt, reference, radius, center, top, channels, true);

fprintf('%d rotations to reach goal\n', length(xfuzz)-1);
