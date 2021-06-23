piclist = {
    'bar.ppm';
    'building.ppm';
    % 'character.ppm';
    'earth.ppm';
    % 'flower.ppm';
    % 'pcgame.ppm';
    % 'pc_desktop.ppm';
    % 'shop.ppm';
    % 'street.ppm';
    % 'wedding.ppm';
};
headsize=607;
L = 90;
U = 100;
for picnum=1:length(piclist)
    parfor Q=L:U
        jpeg_main(piclist{picnum}, Q);
    end

    src = imread(piclist{picnum});
    peaksnr = zeros(1,U-L+1);
    snrval = peaksnr;
    ssimval = peaksnr;
    filesize_KByts = peaksnr;
    MOSpsnr = peaksnr;
    MOSssim = peaksnr;
    filenamestr = cell(1,U-L+1);
    for i=L:U
        file = dir(strcat(piclist{picnum},int2str(i),'.jpg'));
        filenamestr(i-L+1) = {file.name};
        dst = imread(file.name);
        [peaksnr(i-L+1),snrval(i-L+1)] = psnr(src,dst)
        [ssimval(i-L+1), ~] = ssim(src,dst);
        filesize_KByts(i-L+1) = (file.bytes-headsize) / 1024;
        MOSpsnr(i-L+1) = -24.3816 * (0.5 - 1 ./ (1 + exp(-0.56962 * (peaksnr(i-L+1) - 27.49855)))) + 1.9663 * peaksnr(i-L+1) - 2.37071;
        MOSssim(i-L+1) = 2062.3 * (1 / (1 + exp(-11.8 * (ssimval(i-L+1) - 1.3))) + 0.5) + 40.6 * ssimval(i-L+1) - 1035.6;
    end
    compress_ratio = 1./(filesize_KByts * 1024 / (1920*1080*3)); 
    tabletitle = {'filename', 'size_KB', 'compress_ratio','SNR', 'PSNR', 'SSIM', 'PSNR2MOS', 'SSIM2MOS'};    
    csvdata = table(filenamestr(:), filesize_KByts(:), compress_ratio(:), snrval(:), peaksnr(:), ssimval(:), MOSpsnr(:), MOSssim(:), 'VariableNames', tabletitle);
    writetable(csvdata, [piclist{picnum},'_evaluation.csv']);
end

recycle('on');
delete('*.ppm.jpg')