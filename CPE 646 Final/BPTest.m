gTrue = [];
gFalse = [];

trueCountTrain = 0;
falseCountTrain = 0;

trueCountTest = 0;
falseCountTest = 0;

for k = 1:+1:13456
    gTrue(k) = a*y1(k,:)';
end

for k=1:1:4269
    gFalse(k) = a*y2(k,:)';
end

for k = 1:+1:13456
    if gTrue(k) > 0
        trueCountTrain = trueCountTrain + 1;
    end
end
    
for k = 1:+1:4269
     if gFalse(k) > 0
        falseCountTrain = falseCountTrain + 1;
    end
end


y1Test = vertcat(XTrueTest{:});
y2Test = vertcat(XFalseTest{:});


for k = 1:+1:3363
    for i = 1:+1:21
        for j = 1:+1:21
            if i~=j
                y1Test(k,20*i+j) = y1Test(k,i)*y1Test(k,j);
            end
        end
    end
    y1Test(k,441) = 1;
end




for k=1:1:1067
   for i = 1:+1:21
        for j = 1:+1:21
            if i~=j
                y2Test(k,20*i+j) = y2Test(k,i)*y2Test(k,j);
            end
        end
    end
    y2Test(k,441) = 1;
end

y2Test = y2Test*-1;

gTrueTest = [];
gFalseTest = [];


for k = 1:+1:3363
    gTrueTest(k) = a*y1Test(k,:)';
end

for k=1:1:1067
    gFalseTest(k) = a*y2Test(k,:)';
end

for k = 1:+1:3363
    if gTrueTest(k) > 0
        trueCountTest = trueCountTest + 1;
    end
end
    
for k = 1:+1:1067
     if gFalseTest(k) > 0
        falseCountTest = falseCountTest + 1;
    end
end

