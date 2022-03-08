local json = require('json')
local miniz = require('miniz')
local websocket = require('coro-websocket')

local inflate = miniz.inflate
local decode, null = json.decode, json.null
local ws_parseUrl, ws_connect = websocket.parseUrl, websocket.connect

local TEXT   = 1
local BINARY = 2
local CLOSE  = 8

local function connect(url, path)
	local options = assert(ws_parseUrl(url))
	options.pathname = path
	return assert(ws_connect(options))
end

local discordia = require("discordia");
local classes = discordia.class.classes;
local WebSocket = classes.WebSocket;
local VoiceSocket = classes.VoiceSocket

local function wconnect(self, url, path)

	local success, res, read, write = pcall(connect, url, path)

	if success then
		self._read = read
		self._write = write
		self._reconnect = nil
		self:info('Connected to %s', url)
		local parent = self._parent
		for message in self._read do
			local payload, str = self:parseMessage(message)
			if not payload then break end
			parent:emit('raw', str)
			if self.handlePayload then -- virtual method
				self:handlePayload(payload)
			end
		end
		self:info('Disconnected')
	else
		self:error('Could not connect to %s (%s)', url, res) -- TODO: get new url?
	end

	self._read = nil
	self._write = nil
	self._identified = nil

	if self.stopHeartbeat then -- virtual method
		self:stopHeartbeat()
	end

	if self.handleDisconnect then -- virtual method
		return self:handleDisconnect(url, path, self._closeCode)
	end

end

local function wparseMessage(self,message)

	local opcode = message.opcode
	local payload = message.payload

	if opcode == TEXT then

		return decode(payload, 1, null), payload

	elseif opcode == BINARY then

		payload = inflate(payload, 1)
		return decode(payload, 1, null), payload

	elseif opcode == CLOSE then

		local code, i = ('>H'):unpack(payload)
		local msg = #payload > i and payload:sub(i) or 'Connection closed'
		self:warning('%i - %s', code, msg)
		self._closeCode = code;
		return nil

	end

end

WebSocket.connect = wconnect
WebSocket.parseMessage = wparseMessage;
VoiceSocket.connect = wconnect
VoiceSocket.parseMessage = wparseMessage;
