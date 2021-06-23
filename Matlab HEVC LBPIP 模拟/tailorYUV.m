maindir = 'F:\HEVC_test_sequence'; % 设置数据存放的主路径
subdir = dir(maindir);
id = 1;
for i = 1:length(subdir)
    %如果不是目录则跳过
    if (isequal(subdir(i).name, '.') || isequal(subdir(i).name, '..') ||~subdir(i).isdir)
        continue;
    end
    subdirpath = fullfile(maindir, subdir(i).name, '*.yuv');
    yuv = dir(subdirpath); % 显示文件夹下所有符合后缀名为.yuv文件的完整信息
    for j = 1:length(yuv)
        flag = regexp(yuv(j).name, '^*_10bit_*', 'match');
        if isempty(flag)%排除10bit文件
            %准备yuvRead函数的输入参数存入结构体f中
            strtemp = regexp(yuv(j).name, '(?<=_)[0-9]*x[0-9]*', 'match');
            str = strsplit(strtemp{1}, 'x'); %分割开
            width = str2num(str{1, 1});
            height = str2num(str{1, 2});
            f(id).filename = yuv(j).name; %构造包含名称，宽，高，帧数的结构体
            f(id).width = width;
            f(id).height = height;
            f(id).nFrame = 1;
            f(id).subdir = subdir(i).name;
            id = id + 1;
        end
    end
end

for k = 1:length(f)%因为时间有点长就测试了前两个,实际操作赢使用length(f)
    [Y, U, V] = yuvRead(fullfile(maindir, f(k).subdir, f(k).filename), f(k).width, f(k).height, f(k).nFrame);
    Y = Y(1:floor(f(k).height / 64) * 64, 1:floor(f(k).width / 64) * 64); %将宽和高截取为64的整数倍
    U = U(1:floor(f(k).height / 64/2) * 64, 1:floor(f(k).width / 64/2) * 64); %将宽和高截取为64的整数倍
    V = V(1:floor(f(k).height / 64/2) * 64, 1:floor(f(k).width / 64/2) * 64); %将宽和高截取为64的整数倍
    Ydata{k} = Y;
    Udata{k} = U;
    Vdata{k} = V;
    YUV(k).filename = f(k).filename; %将当前yuv文件的名称、类别、截取后数据、截取前实际宽高存入结构体
    YUV(k).class = f(k).subdir;
    YUV(k).Ydata = Ydata{k};
    YUV(k).Udata = Udata{k};
    YUV(k).Vdata = Vdata{k};
    YUV(k).width = f(k).width;
    YUV(k).height = f(k).height;
end
