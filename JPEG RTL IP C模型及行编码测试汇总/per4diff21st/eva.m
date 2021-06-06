function csvdata = eva(name)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %read8-bitimage.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A = imread([name, '\', name, '.ppm']);

    ref1 = imread([name, '\', name, '_gimp80.ppm']);
    ref2 = imread([name, '\', name, '_gimp90.ppm']);
    ref3 = imread([name, '\', name, '_gimp91.ppm']);
    ref4 = imread([name, '\', name, '_gimp92.ppm']);
    ref5 = imread([name, '\', name, '_gimp93.ppm']);
    ref6 = imread([name, '\', name, '_gimp94.ppm']);
    ref7 = imread([name, '\', name, '_gimp95.ppm']);
    ref8 = imread([name, '\', name, '_gimp96.ppm']);
    ref9 = imread([name, '\', name, '_gimp97.ppm']);
    ref10 = imread([name, '\', name, '_gimp98.ppm']);
    ref11 = imread([name, '\', name, '_gimp99.ppm']);
    ref12 = imread([name, '\', name, '_gimp100.ppm']);
    [ssimval(1), ~] = ssim(A, ref1);
    [peaksnr(1), snrval(1)] = psnr(A, ref1);
    [ssimval(end+1), ~] = ssim(A, ref2);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref2);
    [ssimval(end+1), ~] = ssim(A, ref3);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref3);
    [ssimval(end+1), ~] = ssim(A, ref4);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref4);
    [ssimval(end+1), ~] = ssim(A, ref5);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref5);
    [ssimval(end+1), ~] = ssim(A, ref6);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref6);
    [ssimval(end+1), ~] = ssim(A, ref7);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref7);
    [ssimval(end+1), ~] = ssim(A, ref8);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref8);
    [ssimval(end+1), ~] = ssim(A, ref9);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref9);
    [ssimval(end+1), ~] = ssim(A, ref10);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref10);
    [ssimval(end+1), ~] = ssim(A, ref11);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref11);
    [ssimval(end+1), ~] = ssim(A, ref12);
    [peaksnr(end+1), snrval(end+1)] = psnr(A, ref12);
    % [peaksnr' ssimval'];

    n = length(ssimval);
    for i = 1:n
        MOSpsnr(i) = -24.3816 * (0.5 - 1 ./ (1 + exp(-0.56962 * (peaksnr(i) - 27.49855)))) + 1.9663 * peaksnr(i) - 2.37071;
        MOSssim(i) = 2062.3 * (1 / (1 + exp(-11.8 * (ssimval(i) - 1.3))) + 0.5) + 40.6 * ssimval(i) - 1035.6;
    end

    % disp('psnr 2 MOS')
    % flip(MOSpsnr')
    % disp('ssim 2 MOS')
    % flip(MOSssim')

    clear filename
    filename(1, :) = [name, '/', name, '_gimp80.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp90.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp91.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp92.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp93.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp94.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp95.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp96.ppm ']; 
    filename(end + 1, :) = [name, '/', name, '_gimp97.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp98.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp99.ppm '];
    filename(end + 1, :) = [name, '/', name, '_gimp100.ppm'];

    for i = 1:n 
        file = dir(strrep(strrep(filename(i, :),[name,'_'],'ecs_cemu_'),'.ppm','.bin'));
        filesize_KByts(i) = file.bytes / 1024;
        compress_ratio = 1./(filesize_KByts * 1024 / (1920*1080*3)); 
    end

    tabletitle = {'filename', 'size_KB', 'compress_ratio','SNR', 'PSNR', 'SSIM', 'PSNR2MOS', 'SSIM2MOS'};

    csvdata = table(filename, filesize_KByts(:), compress_ratio(:), snrval(:), peaksnr(:), ssimval(:), MOSpsnr(:), MOSssim(:), 'VariableNames', tabletitle);
    writetable(csvdata, [name,'/',name,'_evaluation.csv']);
    writetable(csvdata, [name,'_evaluation.csv']);
end
