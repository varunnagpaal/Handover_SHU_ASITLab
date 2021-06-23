function sumt = gettreesize_3bitsper8163264blk(size_all64, maxsize)
    %initGlobals(100);
    %用来测试的数据
    %测试时假设一共9个CTU，当前CTU为正中间那个，起始坐标即为65,65
    %maxsize=64;
    %ctux=65;
    %ctuy=65;
    %sizeall64=load('sizeall.mat');
    %modeall64=load('modeall.mat');
    %size_all64=sizeall64.sizeall;
    %mode_all64=modeall64.modeall;
    %mode_all=[mode_all64,mode_all64,mode_all64;mode_all64,mode_all64,mode_all64;mode_all64,mode_all64,mode_all64];
    %mode_all64=mode_all(ctux:ctux+maxsize-1,ctuy:ctuy+maxsize-1);
    %size_all64=size_all(ctux:ctux+maxsize-1,ctuy:ctuy+maxsize-1);
    idx = 0;
    c = 1;
    d = 1;
    temp = 0;
    %sumt=0;
    sumt4 = 0;
    sumt8 = 0;
    sumt16 = 0;
    sumt32 = 0;
    sumt64 = 0;
    sumtsplit = 0;
    %初步将矩阵中的数据转换为[行坐标，列坐标，块大小，0（存放标记非正方形块是哪个方向的信息）]的样子
    for i = 1:4:maxsize%这里的ij坐标须为当前点在当前CTU中的相对坐标
        for j = 1:4:maxsize
            if mod(size_all64(i, j), 2) == 0
                a = (floor(i / size_all64(i, j))) * size_all64(i, j) + 1;
                b = (floor(j / size_all64(i, j))) * size_all64(i, j) + 1;
            else
                sqwidth = (size_all64(i, j) - 1) * 2;
                a = floor(i / sqwidth) * sqwidth + 1; %(sizeall(i,j)-1)*2为非正方形补为正方形之后的宽度
                b = floor(j / sqwidth) * sqwidth + 1;
            end
            if (a ~= c || b ~= d) || (a == c && b == d && size_all64(i, j) ~= temp)
                idx = idx + 1;
            end

            L{idx} = [a, b, size_all64(i, j)];
            c = L{idx}(1);
            d = L{idx}(2);
            temp = L{idx}(3);
        end
    end
    %去除元胞数组中重复的元素项（这个是因为提取出来的信息因为一点小bug会有一部分重复）
    L = cellfun(@num2str, L, 'un', 0);
    K = unique(L);
    P = cellfun(@str2num, K, 'un', 0);
    %得到每个块的坐标，size信息
    %其中注意，所有非正方形块的定位坐标统一放在将其补齐为正方形后，左上角第一个点
    %包括左上角是块状预测的情况，这种情况下定位点不属于该非正方形块
    s = size(P);

    for k = 1:s(2)
        if mod(P{k}(3), 2) ~= 0
            P{k}(3) = (P{k}(3) - 1) * 2;
        end
    end

    for k = 1:s(2)
        %先统计违背分割的各个尺寸的块数量
        switch P{k}(3)
            case 4
                sumt4 = sumt4 + 1;
            case 8
                sumt8 = sumt8 + 1;
            case 16
                sumt16 = sumt16 + 1;
            case 32
                sumt32 = sumt32 + 1;
            case 64
                sumt64 = sumt64 + 1;
        end
    end
    %再统计被分割为4个小块了的各个块数量
    % aaaaaaaa = zeros(10);
    % for w = [8, 16, 32, 64]
    %     for i = 1:w:maxsize%分别以8,16,32,64的间隔遍历整个CTU
    %         for j = 1:w:maxsize
    %             for k = 1:s(2)
    %                 if i == P{k}(1) && j == P{k}(2) && w > P{k}(3)
    %                     for q = 1:s(2)
    %                         ff = 0;
    %                         if i == P{q}(1) && j + w / 2 == P{q}(2) && w > P{q}(3)
    %                             sumtsplit = sumtsplit + 4;
    %                             aaaaaaaa(log2(w)) = aaaaaaaa(log2(w)) + 1;
    %                             ff = 1; %说明当前快是被分割了的且大小为w的块
    %                             break
    %                         end
    %                     end
    %                     if ff == 1
    %                         break
    %                     end
    %                 end
    %             end
    %         end
    %     end
    % end
    sumt = sumt4 + (sumt8 + sumt16 + sumt32 + sumt64) * 3;
