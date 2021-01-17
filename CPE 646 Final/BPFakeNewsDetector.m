data = gossipcopreal;
head(data)

%Remove low count classes so there are only two
classCounts = h.BinCounts;
classNames = h.Categories;

idxLowCounts = classCounts < 10;
infrequentClasses = classNames(idxLowCounts);

idxInfrequent = ismember(data.label,infrequentClasses);
data(idxInfrequent,:) = [];
data.label = removecats(data.label); 

%Seperate the data by label
dataTitle = data.title;
dataTrue = dataTitle(1:16818);
dataFalse = dataTitle(16819:end);

textDataTrainTrue = lower(dataTrue); %turns all the text into lower case
documentsTrainTrue = tokenizedDocument(textDataTrainTrue); %splits the document into tokens
documentsTrainTrue = erasePunctuation(documentsTrainTrue); %erases all punctuation

textDataTrainFalse = lower(dataFalse); %turns all the text into lower case
documentsTrainFalse = tokenizedDocument(textDataTrainFalse); %splits the document into tokens
documentsTrainFalse = erasePunctuation(documentsTrainFalse); %erases all punctuation

textDataTrain = lower(dataTitle); %Needed for encoding
documentsTrain = tokenizedDocument(textDataTrain);
documentsTrain = erasePunctuation(documentsTrain); 

enc = wordEncoding(documentsTrain); % Puts all the words into an array

XTrue = doc2sequence(enc,documentsTrainTrue,'Length',21); 
XFalse = doc2sequence(enc,documentsTrainFalse,'Length',21);

XTrueTest = XTrue(1:3363);
XTrueTrain = XTrue(3363:end);

XFalseTest = XFalse(1:1067);
XFalseTrain = XFalse(1067:end);


y1 = vertcat(XTrueTrain{:});
y2 = vertcat(XFalseTrain{:});


a = [];






for k = 1:+1:13456 %Populate y1
    for i = 1:+1:21
        for j = 1:+1:21
            if i~=j
                y1(k,20*i+j) = y1(k,i)*y1(k,j);
            end
        end
    end
    y1(k,441) = 1;
end




for k=1:1:4269  %Populate y2
   for i = 1:+1:21
        for j = 1:+1:21
            if i~=j
                y2(k,20*i+j) = y2(k,i)*y2(k,j);
            end
        end
    end
    y2(k,441) = 1;
end

y2 = y2*-1;

%%

sumArray = zeros(1,441);

%% Find sum
for k = 1:+1:13456
    for i=1:1:441
        sumArray(1,i) = sumArray(1,i) + y1(k,i);
    end
end


for k=1:1:4269
   for i=1:1:441
        sumArray(1,i) = sumArray(1,i) + y2(k,i);
    end
end


%%Find G array
a = sumArray;
gTrue = [];
gFalse = [];

for k = 1:+1:13456
    gTrue(k) = a*y1(k,:)';
end

for k=1:1:4269
    gFalse(k) = a*y2(k,:)';
end
disp("initial gFalse\n");
disp(gFalse(1));

%%Start training
while sqrt(sumArray*sumArray') > 1
    y1Reclass = [];
    y2Reclass = [];
    for k = 1:+1:13456
        if gTrue(k) < 0
            y1Reclass(k,:) = y1(k,:);
        else
            y1Reclass(k,:) = zeros(1,441);
        end
    end
    
    for k = 1:+1:4269
        if gFalse(k) < 0
            y2Reclass(k,:) = y2(k,:);
        else
            y2Reclass(k,:) = zeros(1,441);
        end
    end
    
    disp("y2 Reclass\n");
    disp(y2Reclass(1,:));
    disp("Theta convergence\n");
    disp(sqrt(sumArray*sumArray'));
    
    for k = 1:+1:13456
        for i=1:1:441
            sumArray(1,i) = sumArray(1,i) + y1Reclass(k,i);
        end
    end


    for k=1:1:4269
       for i=1:1:441
            sumArray(1,i) = sumArray(1,i) + y2Reclass(k,i);
        end
    end
    
    for i = 1:+1:441
        a(i) = a(i) + sumArray(1,i);
    end
   
    

    gTrue = [];
    gFalse = [];

    for k = 1:+1:13456
        gTrue(k) = a*y1(k,:)';
    end

    for k=1:1:4269
        gFalse(k) = a*y2(k,:)';
    end
    
    
end