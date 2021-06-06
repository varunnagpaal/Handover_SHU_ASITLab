piclist = {
    'bar.ppm';
    'building.ppm';
    'character.ppm';
    'earth.ppm';
    'flower.ppm';
    'pcgame.ppm';
    'pc_desktop.ppm';
    'shop.ppm';
    'street.ppm';
    'wedding.ppm';
};

codelist = {
%     'dnxhr_hq';
%     'dnxhr_lb';
%     'dnxhr_sq';
    'proresproxy';
    'proreslt';
    'proresstandard';
    'proreshq';
}

for codenum=1:length(codelist)
    src = {};
    for i=1:length(piclist)
        src{i} = imread(strcat('src (',int2str(i),').ppm'));
    end
    dst = {};
%     if codenum <= 3
%         for i=1:length(piclist)
%             dst{i} = imread(strrep(strcat(codelist{codenum},int2str(i),'.ppm'),'dnxhr_',''));
%         end
%     else
        for i=1:length(piclist)
            dst{i} = im2uint8(imread(strcat(codelist{codenum},int2str(i),'.ppm')));
        end
%     end

    peaksnr = zeros(1,length(piclist));
    snrval = peaksnr;
    ssimval = peaksnr;
    filesize_KByts = peaksnr;
    MOSpsnr = peaksnr;
    MOSssim = peaksnr;
    filenamestr = cell(1,length(piclist));
    for i=1:length(piclist)
        % file = dir(strcat(codelist{codenum},'.mov'));
        % filenamestr(i) = {file.name};
        % dst_downsample = imread(file.name);
        % dst = inv_smooth(dst_downsample);
        % writename = strcat({file.name},'inv_smooth.ppm');
        % imwrite(dst,writename{1});
        [peaksnr(i),snrval(i)] = psnr(src{i}, dst{i})
        [ssimval(i), ~] = ssim(src{i}, dst{i});
        % filesize_KByts(i) = (file.bytes-headsize) / 1024;
        MOSpsnr(i) = -24.3816 * (0.5 - 1 ./ (1 + exp(-0.56962 * (peaksnr(i) - 27.49855)))) + 1.9663 * peaksnr(i) - 2.37071;
        MOSssim(i) = 2062.3 * (1 / (1 + exp(-11.8 * (ssimval(i) - 1.3))) + 0.5) + 40.6 * ssimval(i) - 1035.6;
    end
    % compress_ratio = 1./(filesize_KByts * 1024 / (1920*1072*3)); 
    tabletitle = {'SNR', 'PSNR', 'SSIM', 'PSNR2MOS', 'SSIM2MOS'};    
    csvdata = table(snrval(:), peaksnr(:), ssimval(:), MOSpsnr(:), MOSssim(:), 'VariableNames', tabletitle);
    writetable(csvdata, [codelist{codenum},'_evaluation.csv']);
end

recycle('on');
% delete('*.ppm.jpg')