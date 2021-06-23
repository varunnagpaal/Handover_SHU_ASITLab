maindir = 'F:\HEVC_test_sequence'; % �������ݴ�ŵ���·��
subdir = dir(maindir);
id = 1;
for i = 1:length(subdir)
    %�������Ŀ¼������
    if (isequal(subdir(i).name, '.') || isequal(subdir(i).name, '..') ||~subdir(i).isdir)
        continue;
    end
    subdirpath = fullfile(maindir, subdir(i).name, '*.yuv');
    yuv = dir(subdirpath); % ��ʾ�ļ��������з��Ϻ�׺��Ϊ.yuv�ļ���������Ϣ
    for j = 1:length(yuv)
        flag = regexp(yuv(j).name, '^*_10bit_*', 'match');
        if isempty(flag)%�ų�10bit�ļ�
            %׼��yuvRead�����������������ṹ��f��
            strtemp = regexp(yuv(j).name, '(?<=_)[0-9]*x[0-9]*', 'match');
            str = strsplit(strtemp{1}, 'x'); %�ָ
            width = str2num(str{1, 1});
            height = str2num(str{1, 2});
            f(id).filename = yuv(j).name; %����������ƣ����ߣ�֡���Ľṹ��
            f(id).width = width;
            f(id).height = height;
            f(id).nFrame = 1;
            f(id).subdir = subdir(i).name;
            id = id + 1;
        end
    end
end

for k = 1:length(f)%��Ϊʱ���е㳤�Ͳ�����ǰ����,ʵ�ʲ���Ӯʹ��length(f)
    [Y, U, V] = yuvRead(fullfile(maindir, f(k).subdir, f(k).filename), f(k).width, f(k).height, f(k).nFrame);
    Y = Y(1:floor(f(k).height / 64) * 64, 1:floor(f(k).width / 64) * 64); %����͸߽�ȡΪ64��������
    U = U(1:floor(f(k).height / 64/2) * 64, 1:floor(f(k).width / 64/2) * 64); %����͸߽�ȡΪ64��������
    V = V(1:floor(f(k).height / 64/2) * 64, 1:floor(f(k).width / 64/2) * 64); %����͸߽�ȡΪ64��������
    Ydata{k} = Y;
    Udata{k} = U;
    Vdata{k} = V;
    YUV(k).filename = f(k).filename; %����ǰyuv�ļ������ơ���𡢽�ȡ�����ݡ���ȡǰʵ�ʿ�ߴ���ṹ��
    YUV(k).class = f(k).subdir;
    YUV(k).Ydata = Ydata{k};
    YUV(k).Udata = Udata{k};
    YUV(k).Vdata = Vdata{k};
    YUV(k).width = f(k).width;
    YUV(k).height = f(k).height;
end
