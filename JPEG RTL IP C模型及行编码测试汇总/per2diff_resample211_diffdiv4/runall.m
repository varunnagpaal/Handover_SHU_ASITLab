% parpool('local',8)

name={
        % ' bar',
        % ' bottle',
        % ' building',
        % ' camera',
        ' character',
        % ' earth',
        ' flower',
        ' kitchen',
        % ' lemon',
        % ' pc_desktop',
        % ' pcgame',
        % ' rainier',
        % ' room',
        % ' shop',
        % ' street',
        % ' tatemono',
        % ' deskchair',
        ' wedding'
};

parfor i = 1:length(name)
    system(string(strcat('wsl source enc_dec_per2_diffdivC.sh',name(i))));
    eva(strtrim(char(name(i))));
end