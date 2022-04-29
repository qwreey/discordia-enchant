local discordia = require("discordia");
local classes = discordia.class.classes;
local Guild = classes.Guild;
local enums = discordia.enums;
local channelType = enums.channelType;

function Guild:createTextChannel(name)
    local data;
    if type(name) == "table" then
        data = name;
    else
        data = {name = name};
    end
    data.type = channelType.text;

	local data, err = self.client._api:createGuildChannel(self._id, data);
	if data then
		return self._text_channels:_insert(data);
	else
		return nil, err;
	end
end

function Guild:createVoiceChannel(name)
    local data;
    if type(name) == "table" then
        data = name;
    else
        data = {name = name};
    end
    data.type = channelType.voice;

	local data, err = self.client._api:createGuildChannel(self._id, data);
	if data then
		return self._voice_channels:_insert(data);
	else
		return nil, err;
	end
end