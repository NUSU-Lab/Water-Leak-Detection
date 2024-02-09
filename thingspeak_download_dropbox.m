% ThingSpeak 채널 및 API 키
channelID = YOUR_CHANNEL_ID;
writeAPIKey = 'YOUR_API_KEY'; % 본인의 쓰기 API 키로 대체해주세요

% 텔레그램 봇 토큰 및 채팅 ID 설정
% 텔레그램 봇 토큰 및 채팅 ID 설정
botToken = 'YOUR_TELEGRAM_BOT_TOKEN';
clientID = 'YOUR_TELEGRAM_CHAT_ID';

% Dropbox 액세스 토큰
dropboxAccessToken = 'YOUR_DROPBOX_ACCESS_TOKEN';

% 다운로드할 파일 이름
fileNames = 'knn_model2.mat';

% 파일 다운로드
downloadFromDropbox(dropboxAccessToken,fileNames)

% MATLAB 파일 로드
loadedVars=load(fileNames);
model= loadedVars.mdl;

% ThingSpeak에서 가장 최근 데이터 가져오기
recentData = thingSpeakRead(channelID, 'Fields', [1:5], 'NumPoints', 1, 'ReadKey', writeAPIKey);

% 예시 데이터 설정
newData = recentData; % 가장 최근 데이터 사용

% 예측 결과 계산 
prediction = model.predict(newData);

% ThingSpeak에 예측 결과 업데이트
thingSpeakWrite(channelID, 'Fields', 7, 'Values', prediction, 'writeKey', writeAPIKey);

% Telegram 메시지 작성 및 전송
if prediction == 0
    message = "누수가 발생하고 있습니다. 확인해주세요!";
else
    message = "누수가 발생하고 있지 않습니다. 안심하세요!";
end

url = ['https://api.telegram.org/bot' botToken '/sendMessage'];
options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json');
params = struct('chat_id', clientID, 'text', message);
webwrite(url, params, options);

disp('Telegram message sent successfully');

% Dropbox에서 파일 다운로드하는 함수
function downloadFromDropbox(dropboxAccessToken, fileNames, varargin)
    narginchk(2,3);

    if isequal(nargin,2)
        downloadPath = pwd; 
    elseif isequal(nargin,3)
        if ~exist(varargin{1},'dir')
            throw(MException('downloadFromDropbox:pathNotFound','Download path does not exist.'));
        else
            downloadPath = varargin{1};
        end    
    end

    headerFields = {'Authorization', ['Bearer ', dropboxAccessToken]};
    headerFields(2,1) = {'Dropbox-API-Arg'};
    headerFields(2,2) = {sprintf('{"path": "/%s"}',fileNames)};
    headerFields(3,1) = {'Content-Type'};
    headerFields(3,2) = {'application/octet-stream'};

    opt = weboptions;
    opt.MediaType = 'application/octet-stream';
    opt.CharacterEncoding = 'ISO-8859-1';
    opt.RequestMethod = 'post';
    opt.HeaderFields = headerFields;

    try
        rawData = webread('https://content.dropboxapi.com/2/files/download', opt);
    catch someException
        throw(addCause(MException('downloadFromDropbox:unableToDownloadFile',strcat('Unable to download file:',fileNames)),someException));
    end

    fullPath = fullfile(downloadPath, fileNames);

    try
        fileID = fopen(fullPath,'w');
        fwrite(fileID,rawData);
        fclose(fileID);
    catch someException
        throw(addCause(MException('downloadFromDropbox:unableToSaveFile', sprintf('Unable to save downloaded file %s in the downloadPath',fileNames)),someException));
    end
end
