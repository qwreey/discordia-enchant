-- patch for reconnecting

local eventHandler = require("../../eventHandler")

local function warning(client, object, id, event)
	return client:warning('Uncached %s (%s) on %s', object, id, event)
end

local function load(obj, d)
	for k, v in pairs(d) do obj[k] = v end
end

eventHandler.make("VOICE_SERVER_UPDATE",function (d, client)
	local guild = client._guilds:get(d.guild_id)
	if not guild then return warning(client, 'Guild', d.guild_id, 'VOICE_SERVER_UPDATE') end
	local state = guild._voice_states[client._user._id]
	if not state then return client:warning('Voice state not initialized before VOICE_SERVER_UPDATE') end
	load(state, d)
	local channel = guild._voice_channels:get(state.channel_id)
	if not channel then return warning(client, 'GuildVoiceChannel', state.channel_id, 'VOICE_SERVER_UPDATE') end
	local connection = channel._connection or guild._oldConnection
	if not connection then
        return client:warning('Voice connection not initialized before VOICE_SERVER_UPDATE')
    end
	local oldchannel = connection._channel
    if oldchannel and oldchannel ~= channel then
        oldchannel._connection = nil
        connection._channel = channel
        channel._connection = channel
    end
    guild._connection = connection
	local result = client._voice:_prepareConnection(state, connection)
	if oldchannel and oldchannel ~= channel then
        client:emit("voiceConnectionMove",oldchannel,channel,result)
    end
    return result
end)
