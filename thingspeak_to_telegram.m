% 텔레그램 봇 토큰 및 채팅 ID 설정
botToken = 'YOUR_TELEGRAM_BOT_TOKEN';
chatID = 'YOUR_TELEGRAM_CHAT_ID';

% Channel ID to read data from 
channelID = YOUR_CHANNEL_ID; 

readAPIKey = 'YOUR_API_KEY'; 

data = thingSpeakRead(channelID, 'ReadKey', readAPIKey, 'NumPoints', 85);
    
% Display the first row of the data
firstRow = data(1, :);
disp('First Row of Data:');
disp(firstRow);

% Features (입력 변수)와 Labels (출력 변수) 추출
features = data(:, 1:7);
labels = data(:, 8);

% Split your data into training and testing sets
rng(1); % For reproducibility
splitRatio = 0.8;
splitIdx = round(splitRatio * size(data, 1));

X_train = features(1:splitIdx, :); % Features for training
y_train = labels(1:splitIdx);      % Labels for training

X_test = features(splitIdx+1:end, :); % Features for testing
y_test = labels(splitIdx+1:end);      % Labels for testing

% Train the KNN model
knnModel = fitcknn(X_train, y_train, 'NumNeighbors', 5); % You can adjust 'NumNeighbors' as needed

% Make predictions on the test set
y_pred = predict(knnModel, X_test);

% Evaluate the accuracy
accuracy = sum(y_pred == y_test) / numel(y_test);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);

% 모델 성능 프린트
modelPerformance = sprintf('모델 성능: 정확도 %.2f%%', accuracy * 100);

% 보낼 메세지 설정
message = modelPerformance;

% 텔레그램으로 메세지 보내는 API 호출
url = ['https://api.telegram.org/bot' botToken '/sendMessage'];
options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json');
params = struct('chat_id', chatID, 'text', message);
webwrite(url, params, options);
