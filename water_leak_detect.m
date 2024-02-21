% ThingSpeak channel ID and API key
channels = [];
readKeys = {};
options = weboptions('ContentType','json');

% Telegram bot token and chat ID
botToken = '';
clientID = '';

% Dropbox access token
dropboxAccessToken = '';

fileNames = 'RFModel.mat';

% File download from Dropbox
downloadFromDropbox(dropboxAccessToken,fileNames)

% MATLAB file load
loadedVars = load(fileNames);
model = loadedVars.RFModel;

% Get data from Thingspeak
for i = 1:length(channels)
    channel = channels(i);
    readKey = readKeys{i};
    
    url = ['https://api.thingspeak.com/channels/', num2str(channel), '/feeds.json?api_key=', readKey, '&results=4'];
    response = webread(url, options);
    
    % value = response.feeds(1).field1;
    % firstFourHex = value(1:4);
    % firstFourDec = hex2dec(firstFourHex);
    
    % disp(value)
    % disp(firstFourDec)
    
    % flowData(i) = firstFourDec;

    averageFlow = 0;

    for j = 1:length(response.feeds)
        value = response.feeds(j).field1;
        firstFourHex = value(1:4);
        firstFourDec = hex2dec(firstFourHex);
        
        averageFlow = averageFlow + firstFourDec;
    end
    
    flowData(i) = round(averageFlow / length(response.feeds));
end

% flowData(1) = 1641;
% flowData(2) = 400;
% flowData(3) = 400;
% flowData(4) = 400;

prediction = model.predict(flowData);

flowDataStr = sprintf("Flow data of sensor 1 : %d\nFlow data of sensor 2 : %d\nFlow data of sensor 3 : %d\nFlow data of sensor 4 : %d.", flowData(1), flowData(2), flowData(3), flowData(4));

if prediction == 0
    message = sprintf("There is no water leak.\n%s", flowDataStr);
elseif prediction == 1
    message = sprintf("A water leak was detected at point 1.\n%s", flowDataStr);
elseif prediction == 2
    message = sprintf("A water leak was detected at point 2.\n%s", flowDataStr);
elseif prediction == 3
    message = sprintf("A water leak was detected at point 3.\n%s", flowDataStr);
else
    message = sprintf("Else. %s", flowDataStr);
end

% Send message by Telegram
url = ['https://api.telegram.org/bot' botToken '/sendMessage'];
options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json');
params = struct('chat_id', clientID, 'text', message);
webwrite(url, params, options);

disp('Telegram message sent successfully.');

% Download file from Dropbox 
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