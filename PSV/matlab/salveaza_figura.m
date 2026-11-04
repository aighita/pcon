function salveaza_figura(fig, nume)
    p = cai_laborator;
    exportgraphics(fig, fullfile(p.out, [nume '.png']), 'Resolution', 150);
end
