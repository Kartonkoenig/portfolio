function errorPlotAll()
% Funktion zum Plotten der Diagramme für die Regler-Validierung
% Es werden für alle möglichen Startradien und Winkeldifferenzen
% jeweils eine Simulation durchgeführt und die Winkel- und Radiusfehler
% in Säulendiagrammen abgebildet. Zusätzlich wird noch der Mittelwert 
% gebildet und mit Standardabweichung abgebildet. 

% Für diese Funktion in fuzzySimulateWithConstInput als Ausgabewert die
% Spannung u_fuzzy hinzufügen. Den braucht nur diese Funktion.


    % Cone params
    diameter    = 0.45;
    tilt        = 7.5;
    radius      = diameter / 2;
    center      = [0 0 0];
    height      = coneHeight(tilt, diameter);
    channels    = 14;
    top         = [center(1) center(2) center(3)+height];
     
    % Testdaten für Simulation
    T           = 0.005;       % Sample time for simulation - seconds
    t_end       = 100;     % End time of ODE Simulation 
    t0          = 0;     % Initial time
    
    ODE_opt     = odeset('Events', @coneStopEvent);
    
    t_u         = linspace(0, t_end, 10); 
    u = ones(1,length(t_u));


    % Initialisierung der Fehler
    angles = 0:10:360;
    radiants = 0.025:0.025:0.225;

    error_winkel = zeros(length(angles), length(radiants));
    
    error_radius = zeros(length(angles), length(radiants));

    u_cell          = cell(length(angles), length(radiants));   % Alle Spannungswerte
    trajectories    = cell(length(angles), length(radiants));   % Alle Trajektorien
    times           = cell(length(angles), length(radiants));   % Alle Zeiten bis Ende


    % (0, radius, 0) als Zielort für alle Simulationen
    [ref1,ref2,ref3]   = pol2cart(0, radius,0);
    reference          = [ref1 ref2 ref3];

    for ii=1:length(angles)
        for jj=1:length(radiants)

            % Neue Startposition
            [p1,p2,p3]  = pol2cart(angles(ii),radiants(jj),0);
            pos         = [p1,p2,p3];
            CP          = CollisionPoint(radius, center, top, channels, pos);
            x0          = [pos(1); pos(2); CP(3); 0; 0; 0; 0; 0; 0; 0; 0]; 
            
            [times{ii,jj}, trajectories{ii,jj}, u_cell{ii,jj}, error_winkel(ii,jj), error_radius(ii,jj)] = fuzzySimulateWithConstInput(t0, x0, t_end, T, u, t_u, ODE_opt, reference, radius, center, top, channels, false);
        end
    end

    error_winkel = rad2deg(error_winkel);

    radiants_less           = radiants(1:8);

    %% Plot für Spannung
    
    mittelwerte = zeros(length(angles), length(radiants_less));
    maxima      = zeros(length(angles), length(radiants_less));

    for ii=1:length(angles)
        for jj=1:length(radiants_less)
            % Berechne Mittelwerte für jeden Radius bei jeder
            % Winkeldifferenz
            mittelwerte(ii,jj) = mean(u_cell{ii,jj});
            maxima(ii,jj)      = max(u_cell{ii,jj});
        end
    end

    f0 = figure();
    hold all
    grid on;
    plot(radiants_less, mittelwerte, 'o');
    %bar(radiants_less, mittelwerte);
    xlabel('Startradius [m]');
    ylabel('Spannung [V]');
    hold off

    f01 = figure();
    hold all
    grid on;
   plot(radiants_less, maxima, 'o');
    %bar(radiants_less, maxima);
    xlabel('Startradius [m]');
    ylabel('Spannung [V]');
    hold off

    %% Plot Zeiten bis Abbruch
    % Länge der einzelnen Zeitvektoren entspricht Simulationsdauer bis
    % Abbruch
    zeiten = zeros(length(angles), length(radiants_less));

    for ii=1:length(angles)
        for jj=1:length(radiants_less)
            zeiten(ii,jj) = length(times{ii,jj});
        end
    end

    f02 = figure();
    hold all;
    grid on;
    plot(radiants_less, zeiten, 'o');
    %bar(radiants_less, zeiten);
    xlabel('Startradius [m]');
    ylabel('Zeit [s]');
    hold off

    %% Plot Winkelfehler über Startradius
    f1 = figure();
    
    bar(radiants, error_winkel);
    grid on;
    xlabel('Startradius [m]');
    ylabel('Winkelfehler [°]');

    % zusätzlicher Plot ohne 0.22
    
    error_winkel_less       = error_winkel;
    error_winkel_less(:,9)  = [];
    f1_1 = figure();
    bar(radiants_less, error_winkel_less);
    grid on;
    xlabel('Startradius [m]');
    ylabel('Winkelfehler [°]');
    
    %% Plot Winkelfehler über Winkeldifferenz
    f2 = figure();

    bar(angles, error_winkel');
    grid on;
    xlabel('Winkeldifferenz [°]');
    ylabel('Winkelfehler [°]');

    % zusätzlicher Plot ohne 0.22
    f2_1 = figure();
    bar(angles, error_winkel_less');
    grid on;
    xlabel('Startradius [m]');
    ylabel('Winkelfehler [°]');

    %% Plot Radiusfehler über Startradius
    f3 = figure();

    grid on;
    bar(radiants, error_radius);
    xlabel('Startradius [m]');
    ylabel('Radiusfehler [m]');

    %% Plot Radiusfehler über Winkeldifferenz
    f4 = figure();

    grid on;
    bar(angles, error_radius');
    xlabel('Winkeldifferenz [°]');
    ylabel('Radiusfehler [m]');
    

end 