function blkkind = get_blk_classify_flag(mode_all, size_all, blflag_all, maxsize, ctux, ctuy)
    %     initGlobals(100);
    %     CTU =load('size_mode_np.mat');
    %     �������Ե�����
    %     ����ʱ����һ��9��CTU����ǰCTUΪ���м��Ǹ�����ʼ���꼴Ϊ65,65
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
    %���1-11
    a1 = 0; %�ָ�Ϊ4С��
    a2 = 0; %�������Ľǿ�״-��״Ԥ��
    a3 = 0; %�������Ľǿ�״-��״Ԥ��
    a4 = 0; %�������Ͻ�-��״Ԥ��
    a5 = 0; %�������Ͻ�-��״Ԥ��
    a6 = 0; %�������Ͻ�-��״Ԥ��
    a7 = 0; %�������Ͻ�-��״Ԥ��
    a8 = 0; %�������½�-��״Ԥ��
    a9 = 0; %�������½�-��״Ԥ��
    a10 = 0; %�������½�-��״Ԥ��
    a11 = 0; %�������½�-��״Ԥ��
    idx = 0;
    c = 1;
    d = 1;
    temp = 0;

    %�����������е�����ת��Ϊ[�����꣬�����꣬���С��0����ű�Ƿ������ο����ĸ��������Ϣ��]������
    for i = 1:4:maxsize%�����ij������Ϊ��ǰ���ڵ�ǰCTU�е��������
        for j = 1:4:maxsize
            if mod(size_all_blk(i, j), 2) == 0
                a = (floor(i / size_all_blk(i, j))) * size_all_blk(i, j) + 1;
                b = (floor(j / size_all_blk(i, j))) * size_all_blk(i, j) + 1;
            else
                sqwidth = (size_all_blk(i, j) - 1) * 2;
                a = floor(i / sqwidth) * sqwidth + 1; %(sizeall(i,j)-1)*2Ϊ�������β�Ϊ������֮��Ŀ��
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
    %ȥ��Ԫ���������ظ���Ԫ����������Ϊ��ȡ��������Ϣ��Ϊһ��Сbug����һ�����ظ���
    L = cellfun(@num2str, L, 'un', 0);
    K = unique(L);
    P = cellfun(@str2num, K, 'un', 0);
    %�õ�ÿ��������꣬size��Ϣ
    %����ע�⣬���з������ο�Ķ�λ����ͳһ���ڽ��䲹��Ϊ�����κ����Ͻǵ�һ����
    %�������Ͻ��ǿ�״Ԥ����������������¶�λ�㲻���ڸ÷������ο��ڲ�
    s = size(P);
    for k = 1:s(2)%�ȴ��������ο�
        if mod(P{k}(3), 2) == 0 && P{k}(3) ~= 4
            if ~blflag_all_blk(P{k}(1), P{k}(2))
                a2 = a2 + 1;
            else %���ο�Ļ�״Ԥ��,���a3
                a3 = a3 + 1;
            end
        end
    end
    %����L�Ϳ�
    for k = 1:s(2)
        if mod(P{k}(3), 2) ~= 0
            for y = 1:s(2)%ͨ���ܷ��ҵ���Ӧλ�õĿ�������Ϣ���ж������������
                if y == k
                    continue;
                end
                if P{k}(1) == P{y}(1) && P{k}(2) == P{y}(2)%�������ϵ����
                    location = 1;

                elseif P{y}(1) == P{k}(1) && ...%�������ϵ����
                    P{y}(2) == P{k}(2) + size_all_blk(P{k}(1), P{k}(2)) - 1
                    location = 2;

                elseif P{y}(1) == P{k}(1) + size_all_blk(P{k}(1), P{k}(2)) - 1 && ...%�������µ����
                    P{y}(2) == P{k}(2)
                    location = 3;

                elseif P{y}(1) == P{k}(1) + size_all_blk(P{k}(1), P{k}(2)) - 1 && ...%�������µ����
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
                    if blflag_all_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + (P{k}(3) - 1) * 2 - 1)%��״Ԥ��  ���a5
                        a5 = a5 + 1;
                    else %˵���ǿ�״Ԥ�� ���a4
                        a4 = a4 + 1;
                    end
                case 2
                    modetemp = zeros(1, (P{k}(3) - 1) * 2);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_all_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + i - 1);
                    end

                    if blflag_all_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + (P{k}(3) - 1) * 2 - 1)%��״Ԥ��  ���a7
                        a7 = a7 + 1;
                    else %˵���ǿ�״Ԥ�� ���a6
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
    %ͳ�Ʊ��ָ�Ϊ4��С���˵ĸ����������������a1
    for w = [8, 16, 32, 64]
        for i = 1:w:maxsize%�ֱ���8,16,32,64�ļ����������CTU
            for j = 1:w:maxsize
                for k = 1:s(2)
                    if i == P{k}(1) && j == P{k}(2) && w > P{k}(3)
                        for q = 1:s(2)
                            ff = 0;
                            if i == P{q}(1) && j + w / 2 == P{q}(2) && w > P{q}(3)
                                a1 = a1 + 1;
                                ff = 1; %˵����ǰ���Ǳ��ָ��˵��Ҵ�СΪw�Ŀ�
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
