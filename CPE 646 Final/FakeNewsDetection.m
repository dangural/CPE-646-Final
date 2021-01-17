filename = "gossipcop_real.csv";
data = gossipcopreal;
head(data)

data.label = categorical(data.label); %Grabs labels

f = figure;
f.Position(3) = 1.5*f.Position(3);

h = histogram(data.label); % Makes Histogram
xlabel("Class")
ylabel("Frequency")
title("Class Distribution")

classCounts = h.BinCounts;
classNames = h.Categories;

idxLowCounts = classCounts < 10;
infrequentClasses = classNames(idxLowCounts);

idxInfrequent = ismember(data.label,infrequentClasses);
data(idxInfrequent,:) = [];
data.label = removecats(data.label); 

f = figure;
f.Position(3) = 1.5*f.Position(3);

counter = rowfun(@func,data,'InputVariables',4);
data = [data counter];




cvp = cvpartition(data.label,'Holdout',0.3); %Make training and testing and observation 70 - 30
dataTrain = data(training(cvp),:);
dataHeldOut = data(test(cvp),:);

cvp = cvpartition(dataHeldOut.label,'HoldOut',0.5); %15 - 15
dataValidation = dataHeldOut(training(cvp),:);
dataTest = dataHeldOut(test(cvp),:);

textDataTrain = dataTrain.title; %Extraction
textDataValidation = dataValidation.title;
textDataTest = dataTest.title;
YTrain = dataTrain.label;
YValidation = dataValidation.label;
YTest = dataTest.label;

textDataTrain = lower(textDataTrain); %turns all the text into lower case
documentsTrain = tokenizedDocument(textDataTrain); %splits the document into tokens
documentsTrain = erasePunctuation(documentsTrain); %erases all punctuation

textDataValidation = lower(textDataValidation);
documentsValidation = tokenizedDocument(textDataValidation);
documentsValidation = erasePunctuation(documentsValidation);

documentsTrain(1:5)

enc = wordEncoding(documentsTrain); % Puts all the words into an array

documentLengths = doclength(documentsTrain); %Create histogram of document lengths
figure
histogram(documentLengths)
title("Document Lengths")
xlabel("Length")
ylabel("Number of Documents")


XTrain = doc2sequence(enc,documentsTrain,'Length',21); %Forms sequences to prepare for deep learning
XTrain(1:5)

XValidation = doc2sequence(enc,documentsValidation,'Length',21);

inputSize = 1; %Start forming the Nueral Network, this is the input layer
embeddingDimension = 100; %Second layer is 100 and embeds the input
numHiddenUnits = enc.NumWords; %Second layer needs to know number of words
hiddenSize = 180; %third layer is hidden and is used as a LSTM layer
hiddenSize2 = 160;
numClasses = numel(categories(YTrain)); %Final layer is equal to the number of categories we have (Two)

layers = [ ...
    sequenceInputLayer(inputSize)
    wordEmbeddingLayer(embeddingDimension,numHiddenUnits)
    lstmLayer(hiddenSize,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]

options = trainingOptions('adam', ...
    'MaxEpochs',10, ...    
    'GradientThreshold',1, ...
    'InitialLearnRate',0.01, ...
    'ValidationData',{XValidation,YValidation}, ...
    'Plots','training-progress', ...
    'Verbose',false);

net = trainNetwork(XTrain,YTrain,layers,options);

textDataTest = lower(textDataTest);
documentsTest = tokenizedDocument(textDataTest);
documentsTest = erasePunctuation(documentsTest);

XTest = doc2sequence(enc,documentsTest,'Length',21);
XTest(1:5)

YPred = classify(net,XTest);

accuracy = sum(YPred == YTest)/numel(YPred);
yval = YTest;
pred_val = YPred;


  actual_positives = sum(yval == "True News");
  actual_negatives = sum(yval == "Fake News");
  true_positives = sum((pred_val == "True News") & (yval == "True News"));
  false_positives = sum((pred_val == "True News") & (yval == "Fake News"));
  false_negatives = sum((pred_val == "Fake News") & (yval == "True News"));
 
  precision = true_positives / (true_positives + false_positives);

  recall = true_positives / (true_positives + false_negatives); 


  F1 = 2 * precision * recall / (precision + recall);
   
  
