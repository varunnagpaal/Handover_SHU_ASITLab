function sumt = gettreesize_3bitsper8163264blk(size_all64, maxsize)
    %initGlobals(100);
    %�������Ե�����
    %����ʱ����һ��9��CTU����ǰCTUΪ���м��Ǹ�����ʼ���꼴Ϊ65,65
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
    %�����������е�����ת��Ϊ[�����꣬�����꣬���С��0����ű�Ƿ������ο����ĸ��������Ϣ��]������
    for i = 1:4:maxsize%�����ij������Ϊ��ǰ���ڵ�ǰCTU�е��������
        for j = 1:4:maxsize
            if mod(size_all64(i, j), 2) == 0
                a = (floor(i / size_all64(i, j))) * size_all64(i, j) + 1;
                b = (floor(j / size_all64(i, j))) * size_all64(i, j) + 1;
            else
                sqwidth = (size_all64(i, j) - 1) * 2;
                a = floor(i / sqwidth) * sqwidth + 1; %(sizeall(i,j)-1)*2Ϊ�������β�Ϊ������֮��Ŀ��
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
    %ȥ��Ԫ���������ظ���Ԫ����������Ϊ��ȡ��������Ϣ��Ϊһ��Сbug����һ�����ظ���
    L = cellfun(@num2str, L, 'un', 0);
    K = unique(L);
    P = cellfun(@str2num, K, 'un', 0);
    %�õ�ÿ��������꣬size��Ϣ
    %����ע�⣬���з������ο�Ķ�λ����ͳһ���ڽ��䲹��Ϊ�����κ����Ͻǵ�һ����
    %�������Ͻ��ǿ�״Ԥ����������������¶�λ�㲻���ڸ÷������ο�
    s = size(P);

    for k = 1:s(2)
        if mod(P{k}(3), 2) ~= 0
            P{k}(3) = (P{k}(3) - 1) * 2;
        end
    end

    for k = 1:s(2)
        %��ͳ��Υ���ָ�ĸ����ߴ�Ŀ�����
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
    %��ͳ�Ʊ��ָ�Ϊ4��С���˵ĸ���������
    % aaaaaaaa = zeros(10);
    % for w = [8, 16, 32, 64]
    %     for i = 1:w:maxsize%�ֱ���8,16,32,64�ļ����������CTU
    %         for j = 1:w:maxsize
    %             for k = 1:s(2)
    %                 if i == P{k}(1) && j == P{k}(2) && w > P{k}(3)
    %                     for q = 1:s(2)
    %                         ff = 0;
    %                         if i == P{q}(1) && j + w / 2 == P{q}(2) && w > P{q}(3)
    %                             sumtsplit = sumtsplit + 4;
    %                             aaaaaaaa(log2(w)) = aaaaaaaa(log2(w)) + 1;
    %                             ff = 1; %˵����ǰ���Ǳ��ָ��˵��Ҵ�СΪw�Ŀ�
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
