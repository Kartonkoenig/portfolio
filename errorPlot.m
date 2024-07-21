function errorPlot(regeldiff_winkel, regeldiff_radius)
    % Funktion, um einen Radiusfehler über Startradius abzubilden

    fig = figure();
    tiledlayout(1,2);

   
    % Winkelfehler
    nexttile
    regeldiff_winkel_degree = rad2deg(regeldiff_winkel);
    winkeldiff_achse = linspace(0, 180, length(regeldiff_winkel_degree));
    plot(winkeldiff_achse, regeldiff_winkel_degree, 'r', LineWidth=1.5);
    grid on;
    xlabel('Winkeldifferenz [°]');
    ylabel('Fehler für Winkel [°]');

    % Abstand zum Startpunkt 0
    nexttile
    radius_achse = linspace(0,0.225, length(regeldiff_radius)); 
    plot(radius_achse, regeldiff_radius,'b', LineWidth=1.5);
    grid on;
    xlabel('Abstand zu Startpunkt [m]');
    ylabel('Fehler für Radius [m]');
end
end