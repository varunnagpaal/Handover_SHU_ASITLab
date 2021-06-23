for i = 1:25
    cl{i} = log(i).class;
end
[~, ind] = sort(cl);
for i = 1:25
    log_A2F(i) = log(ind(i));
end
