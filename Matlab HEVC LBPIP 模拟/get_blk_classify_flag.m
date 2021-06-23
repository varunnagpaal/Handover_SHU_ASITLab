function blkkind = get_blk_classify_flag(mode_all, size_all, blflag_all, maxsize, ctux, ctuy)
    %     initGlobals(100);
    %     CTU =load('size_mode_np.mat');
    %     用来测试的数据
    %     测试时假设一共9个CTU，当前CTU为正中间那个，起始坐标即为65,65
    %    maxsize=64;
    %    minblk=3;
    %    ctux=1;
    %    ctuy=1;
    %    mode_all=CTU.mode_all;
    %    size_all=CTU.size_all;
    %sizeall64=load('sizeall.mat');
    %modeall64=load('modeall.mat');
    %size_all64=sizeall64.sizeall;
    %mode_all64=modeall64.modeall;
    %mode_all=[mode_all64,mode_all64,mode_all64;mode_all64,mode_all64,mode_all64;mode_all64,mode_all64,mode_all64];
    mode_all_blk = mode_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1) - 1;
    size_all_blk = size_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    blflag_all_blk = blflag_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    %情况1-11
    a1 = 0; %分割为4小块
    a2 = 0; %不保留四角块状-块状预测
    a3 = 0; %不保留四角块状-环状预测
    a4 = 0; %保留左上角-块状预测
    a5 = 0; %保留左上角-环状预测
    a6 = 0; %保留右上角-块状预测
    a7 = 0; %保留右上角-环状预测
    a8 = 0; %保留左下角-块状预测
    a9 = 0; %保留左下角-环状预测
    a10 = 0; %保留右下角-块状预测
    a11 = 0; %保留右下角-环状预测
    idx = 0;
    c = 1;
    d = 1;
    temp = 0;

    %初步将矩阵中的数据转换为[行坐标，列坐标，块大小，0（存放标记非正方形块是哪个方向的信息）]的样子
    for i = 1:4:maxsize%这里的ij坐标须为当前点在当前CTU中的相对坐标
        for j = 1:4:maxsize
            if mod(size_all_blk(i, j), 2) == 0
                a = (floor(i / size_all_blk(i, j))) * size_all_blk(i, j) + 1;
                b = (floor(j / size_all_blk(i, j))) * size_all_blk(i, j) + 1;
            else
                sqwidth = (size_all_blk(i, j) - 1) * 2;
                a = floor(i / sqwidth) * sqwidth + 1; %(sizeall(i,j)-1)*2为非正方形补为正方形之后的宽度
                b = floor(j / sqwidth) * sqwidth + 1;
            end
            if (a ~= c || b ~= d) || (a == c && b == d && size_all_blk(i, j) ~= temp)
                idx = idx + 1;
            end

            L{idx} = [a, b, size_all_blk(i, j), 0];
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
    %包括左上角是块状预测的情况，这种情况下定位点不属于该非正方形块内部
    s = size(P);
    for k = 1:s(2)%先处理正方形块
        if mod(P{k}(3), 2) == 0 && P{k}(3) ~= 4
            if ~blflag_all_blk(P{k}(1), P{k}(2))
                a2 = a2 + 1;
            else %方形块的环状预测,情况a3
                a3 = a3 + 1;
            end
        end
    end
    %处理L型块
    for k = 1:s(2)
        if mod(P{k}(3), 2) ~= 0
            for y = 1:s(2)%通过能否找到对应位置的块坐标信息来判断属于哪种情况
                if y == k
                    continue;
                end
                if P{k}(1) == P{y}(1) && P{k}(2) == P{y}(2)%保留左上的情况
                    location = 1;

                elseif P{y}(1) == P{k}(1) && ...%保留右上的情况
                    P{y}(2) == P{k}(2) + size_all_blk(P{k}(1), P{k}(2)) - 1
                    location = 2;

                elseif P{y}(1) == P{k}(1) + size_all_blk(P{k}(1), P{k}(2)) - 1 && ...%保留左下的情况
                    P{y}(2) == P{k}(2)
                    location = 3;

                elseif P{y}(1) == P{k}(1) + size_all_blk(P{k}(1), P{k}(2)) - 1 && ...%保留右下的情况
                    P{y}(2) == P{k}(2) + size_all_blk(P{k}(1), P{k}(2)) - 1
                    location = 4;

                end
            end
            switch location
                case 1
                    modetemp = zeros(1, (P{k}(3) - 1) * 2);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_all_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + i - 1);
                    end
                    if blflag_all_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + (P{k}(3) - 1) * 2 - 1)%环状预测  情况a5
                        a5 = a5 + 1;
                    else %说明是块状预测 情况a4
                        a4 = a4 + 1;
                    end
                case 2
                    modetemp = zeros(1, (P{k}(3) - 1) * 2);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_all_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + i - 1);
                    end

                    if blflag_all_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + (P{k}(3) - 1) * 2 - 1)%环状预测  情况a7
                        a7 = a7 + 1;
                    else %说明是块状预测 情况a6
                        a6 = a6 + 1;
                    end
                case 3
                    modetemp = zeros(1, (P{k}(3) - 1) * 2);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_all_blk(P{k}(1) + i - 1, P{k}(2) + i - 1);
                    end

                    if blflag_all_blk(P{k}(1), P{k}(2))
                        a9 = a9 + 1;

                    else
                        a8 = a8 + 1;
                    end
                case 4
                    modetemp = zeros(P{k}(3) - 1, 1);
                    for i = 1:P{k}(3) - 1
                        modetemp(i) = mode_all_blk(P{k}(1) + i - 1, P{k}(2) + i - 1);
                    end

                    if blflag_all_blk(P{k}(1), P{k}(2))
                        a11 = a11 + 1;
                    else
                        a10 = a10 + 1;
                    end
            end
        end
    end

    for k = 1:s(2)
        if mod(P{k}(3), 2) ~= 0
            P{k}(3) = (P{k}(3) - 1) * 2;
        end
    end
    %统计被分割为4个小块了的各个块数量，即情况a1
    for w = [8, 16, 32, 64]
        for i = 1:w:maxsize%分别以8,16,32,64的间隔遍历整个CTU
            for j = 1:w:maxsize
                for k = 1:s(2)
                    if i == P{k}(1) && j == P{k}(2) && w > P{k}(3)
                        for q = 1:s(2)
                            ff = 0;
                            if i == P{q}(1) && j + w / 2 == P{q}(2) && w > P{q}(3)
                                a1 = a1 + 1;
                                ff = 1; %说明当前快是被分割了的且大小为w的块
                                break
                            end
                        end
                        if ff == 1
                            break
                        end
                    end
                end
            end
        end
    end
    blkkind = [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11];
end
