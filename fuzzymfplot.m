% MF Functions Plotter
function fuzzymfplot(fis)
    % Funktion zum Plotten der Membership-Functions eines Fuzzy-Systems
     
     set(gcf,'color','w');
     set(groot,'defaultAxesTickLabelInterpreter','latex');
        tiledlayout(1,3);

        nexttile        
        hold on;
        grid on;
        plotmf(fis, 'input', 1);

        nexttile
        hold on;
        grid on;
        plotmf(fis, 'input', 2);

        nexttile
        hold on;
        grid on;
        plotmf(fis,'output', 1);

end