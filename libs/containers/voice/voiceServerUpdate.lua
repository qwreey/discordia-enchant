-- patch for reconnecting

local eventHandler = require("../../eventHandler")
local null = json.null

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
	local connection = channel._connection or guild._oldConnection;
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
	connection._ready = nil
	local result = client._voice:_prepareConnection(state, connection)
	if oldchannel and oldchannel ~= channel then
		if not connection._ready then
			connection:_await()
		end
		guild._reconnect = false
		client:emit("voiceConnectionMove",oldchannel,channel,result)
	else guild._reconnect = false
	end
	return result
end)

eventHandler.make("VOICE_STATE_UPDATE",function (d, client)
	local guild = client._guilds:get(d.guild_id)
	if not guild then return warning(client, 'Guild', d.guild_id, 'VOICE_STATE_UPDATE') end
	local member = d.member and guild._members:_insert(d.member) or guild._members:get(d.user_id)
	if not member then return warning(client, 'Member', d.user_id, 'VOICE_STATE_UPDATE') end
	local states = guild._voice_states
	local channels = guild._voice_channels
	local new_channel_id = d.channel_id
	local state = states[d.user_id]
	if state then -- user is already connected
		local old_channel_id = state.channel_id
		load(state, d)
		if new_channel_id ~= null then -- state changed, but user has not disconnected
			if new_channel_id == old_channel_id then -- user did not change channels
				client:emit('voiceUpdate', member)
			else -- user changed channels
				local old = channels:get(old_channel_id)
				local new = channels:get(new_channel_id)
				-- if d.user_id == client._user._id then -- move connection to new channel
				-- 	local connection = old._connection
				-- 	if connection then
				-- 		new._connection = connection
				-- 		old._connection = nil
				-- 		-- connection._channel = new
				-- 		if connection._continue then
				-- 			connection:_continue(true)
				-- 		end
				-- 	end
				-- end
				client:emit('voiceChannelLeave', member, old)
				client:emit('voiceChannelJoin', member, new)
			end
		else -- user has disconnected
			states[d.user_id] = nil
			local old = channels:get(old_channel_id)
			client:emit('voiceChannelLeave', member, old)
			client:emit('voiceDisconnect', member)
		end
	else -- user has connected
		states[d.user_id] = d
		local new = channels:get(new_channel_id)
		client:emit('voiceConnect', member)
		client:emit('voiceChannelJoin', member, new)
	end
end)
