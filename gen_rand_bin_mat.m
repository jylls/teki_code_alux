function rnd_bin_mat=gen_rand_bin_mat(s1,s2,c_sum)
rnd_bin_mat=zeros(s1,s2);
rand_vects=zeros(c_sum,s2);
for i=1:s2
    temp_vects=sort(randsample(s1,c_sum,false));
    while ismember(temp_vects.',rand_vects.','rows')
        temp_vects=sort(randsample(s1,c_sum,false))
    end
    rand_vects(:,i)=temp_vects;
end
disp(rand_vects)
for i=1:s2
    for j=1:c_sum
        rnd_bin_mat(rand_vects(j,i),i)=1;
    end
end
    
end