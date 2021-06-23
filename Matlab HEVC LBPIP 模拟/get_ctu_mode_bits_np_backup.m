function sum = get_ctu_mode_bits_np_backup(mode_all, size_all, blflag_all, maxsize, ctux, ctuy, minblk)
    %blflag_all��Ϊ����״Ԥ��Ϳ�״Ԥ�����Ϣ
    %     CTU =load('size_mode_np.mat');
    %
    %     maxsize=64;
    %     minblk=3;
    %     ctux=1;
    %     ctuy=1;
    %     mode_all=CTU.mode_all;
    %     size_all=CTU.size_all;
    mode_all = mode_all - 1; %ģʽ�������1
    %  initGlobals(100);
    mode_blk = mode_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    size_blk = size_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    blflag_blk = blflag_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    idx = 0;
    c = 1;
    d = 1;
    sum = 0;
    temp = 0;

    %�����������е�����ת��Ϊ[�����꣬�����꣬���С��0����ű�Ƿ������ο����ĸ��������Ϣ��]������
    for i = 1:4:maxsize%�����ij������Ϊ��ǰ���ڵ�ǰCTU�е��������
        for j = 1:4:maxsize
            if mod(size_blk(i, j), 2) == 0
                a = (floor(i / size_blk(i, j))) * size_blk(i, j) + 1;
                b = (floor(j / size_blk(i, j))) * size_blk(i, j) + 1;
            else
                sqwidth = (size_blk(i, j) - 1) * 2;
                a = floor(i / sqwidth) * sqwidth + 1; %(sizeall(i,j)-1)*2Ϊ�������β�Ϊ������֮��Ŀ��
                b = floor(j / sqwidth) * sqwidth + 1;
            end
            if (a ~= c || b ~= d) || (a == c && b == d && size_blk(i, j) ~= temp)
                idx = idx + 1;
            end

            L{idx} = [a, b, size_blk(i, j), 0];
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
    %�������Ͻ��ǿ�״Ԥ����������������¶�λ�㲻���ڸ÷������ο�
    s = size(P);

    for k = 1:s(2)%�ȴ��������ο�
        ai = P{k}(1) + ctux - 1; %����֡��ʵ������(��ǰ�����Ͻǵ�һ��������)
        aj = P{k}(2) + ctuy - 1;
        if mod(P{k}(3), 2) == 0

            if ~blflag_blk(P{k}(1), P{k}(2))%���Ϊ0��ʾ��״Ԥ��
                [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);
                if flag == 0%ȷ�ϣ�flag=0��ʾ�ں�ѡ�б��У�ʹ��3bit
                    sum = sum + 3;
                else
                    sum = sum + 6; %��������6bit
                end
            else %���ο�Ļ�״Ԥ��
                modetemp = zeros(1, P{k}(3));
                for l = 1:P{k}(3)
                    modetemp(l) = mode_blk(P{k}(1) + P{k}(3) - 1, P{k}(2) + l - 1); %�����һ�м��ܵõ�����ģʽ��
                end
                %�����׸�ģʽ�в����modediff
                if ai == 1
                    modediff = modetemp(1) - 0;
                else
                    modediff = modetemp(1) - mode_all(ai - 1, aj);
                end
                sum = sum + huffman_testsize([modediff, diff(modetemp(1:P{k}(3) - minblk + 1))]);
            end
        end
    end
    %����L�Ϳ�
    for k = 1:s(2)
        ai = P{k}(1) + ctux - 1; %����֡��ʵ������
        aj = P{k}(2) + ctuy - 1;
        if mod(P{k}(3), 2) ~= 0
            for y = 1:s(2)%ͨ���ܷ��ҵ���Ӧλ�õĿ�������Ϣ���ж������������
                if y == k
                    continue;
                end
                if P{k}(1) == P{y}(1) && P{k}(2) == P{y}(2)%�������ϵ����
                    location = 1;

                elseif P{y}(1) == P{k}(1) && ...%�������ϵ����
                    P{y}(2) == P{k}(2) + size_blk(P{k}(1), P{k}(2)) - 1
                    location = 2;

                elseif P{y}(1) == P{k}(1) + size_blk(P{k}(1), P{k}(2)) - 1 && ...%�������µ����
                    P{y}(2) == P{k}(2)
                    location = 3;

                elseif P{y}(1) == P{k}(1) + size_blk(P{k}(1), P{k}(2)) - 1 && ...%�������µ����
                    P{y}(2) == P{k}(2) + size_blk(P{k}(1), P{k}(2)) - 1
                    location = 4;

                end
            end
            switch location
                case {1, 2}
                    modetemp = zeros(1, (P{k}(3) - 1) * 2);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + i - 1);
                    end

                    if blflag_blk(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + (P{k}(3) - 1) * 2 - 1)%=1Ϊ��״Ԥ��

                        if ai == 1
                            modediff = modetemp(1) - 0;
                        else
                            modediff = modetemp(1) - mode_all(ai - 1, aj);
                        end

                        sum = sum + huffman_testsize([modediff, diff(modetemp(1:(P{k}(3) - 1) * 2 - minblk + 1))]);

                    else %˵���ǿ�״Ԥ��
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);

                        if flag == 0%ȷ�ϣ�flag0��ʾ�ں�ѡ�б���
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end

                case 3
                    modetemp = zeros(1, (P{k}(3) - 1) * 2);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_blk(P{k}(1) + i - 1, P{k}(2) + i - 1);
                    end

                    if blflag_blk(P{k}(1), P{k}(2))
                        if ai == 1
                            modediff = modetemp(1) - 0;
                        else
                            modediff = modetemp(1) - mode_all(ai - 1, aj);
                        end

                        sum = sum + huffman_testsize([modediff, diff(modetemp(1:(P{k}(3) - 1) * 2 - minblk + 1))]);
                    else
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);

                        if flag == 0%ȷ�ϣ�flag0��ʾ�ں�ѡ�б���
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end
                case 4
                    modetemp = zeros(P{k}(3) - 1, 1);
                    modediff = zeros(P{k}(3) - 1, 1);
                    for i = 1:P{k}(3) - 1
                        modetemp(i) = mode_blk(P{k}(1) + i - 1, P{k}(2) + i - 1);
                    end
                    if blflag_blk(P{k}(1), P{k}(2))
                        if ai == 1
                            modediff(1) = modetemp(1) - 0;
                        else
                            modediff(1) = modetemp(1) - mode_all(ai - 1, aj);
                        end
                        for x = 2:P{k}(3) - 1
                            modediff(x) = modetemp(x) - modetemp(x - 1);
                        end
                        sum = sum + huffman_testsize(modediff);
                    else
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);
                        if flag == 0%ȷ�ϣ�flag0��ʾ�ں�ѡ�б���
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end
            end
        end
    end
end
