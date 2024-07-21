%% MAIN FÜR MEHRERE PARTIKEL

% Cone params
diameter    = 0.45;
tilt        = 15;
radius      = diameter / 2;
center      = [0 0 0];
height      = coneHeight(tilt, diameter);
channels    = 14;
top         = [center(1) center(2) center(3)+height];

%% Obtain current position on cone
% Pos 1
[p1,p2,p3]  = pol2cart(80, 0.025,0);
pos         = [p1,p2,p3];
%pos        = [0.11;-0.1;0.03];
CP          = CollisionPoint(radius, center, top, channels, pos);
x0_1        = [pos(1); pos(2); CP(3); 0; 0; 0; 0; 0; 0];

% Pos 2
[p1,p2,p3]  = pol2cart(80, 0.05,0);
pos         = [p1,p2,p3];
CP          = CollisionPoint(radius, center, top, channels, pos);
x0_2        = [pos(1); pos(2); CP(3); 0; 0; 0; 0; 0; 0];

motor       = [0;0];    % omega und i



%% Testdaten für Simulation
T           = 0.005;       % Sample time for simulation - seconds
t_end       = 1000;     % End time of ODE Simulation
t0          = 0;     % Initial time
t_simulation = t0:T:t_end;

% Target Position
[ref1,ref2,ref3]   = pol2cart(0, radius,0);
reference          = [ref1 ref2 ref3];


ODE_opt     = odeset('Events', @coneStopEvent);

t_u         = linspace(0, t_end, 10);
u           = ones(1,length(t_u));


%% Simuliere System
[tfuzz, xfuzz,~,~] = multiFuzzySimulateWithConstInput(t0, x0_1, x0_2, motor, t_end, T, u, t_u, ODE_opt, reference, radius, center, top, channels, true);

fprintf('%d rotations to reach goal\n', length(xfuzz)-1);
