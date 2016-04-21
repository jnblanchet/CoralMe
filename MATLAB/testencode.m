% Decoding
data = load('message.mat');
data = data.message;

split = strsplit(data,',');
header = upper(split{1});
image = split{2};
image = base64decode(image);

fmt = {'JPEG','JPG','PNG','BMP','CUR','PPM','GIF','PBM','RAS','HDF4','PCX','TIFF','ICO','PGM','XWD'};
f = -1;
for i=1:numel(fmt)
    if ~isempty(strfind(header,['/' fmt{i}]))
        f = i;
        break;
    end
end

result = imdecode( image, fmt{f});

% encoding
header = 'data:image/jpeg;base64,';
body = imencode( result, 'JPEG');
body64 = base64encode(body);

data2 = strcat(header, body64);

assert_equal(data,data2);


