-- enable voice fixer
require("containers/voice/VoiceSocket");
require("containers/voice/FFmpegProcess");
require("containers/voice/VoiceConnection");
require("client");
require("shard");
require("webSocket");
require("containers/voice/voiceServerUpdate");
require("api9"); -- inject api 9
require("containers/message");
require("containers/textChannel");
require("containers/guild");
local eventHandler = require("eventHandler");
local appliactionCommand = require("containers/appliactionCommand"); -- inject appliactionCommand into client

return {
	---@type enchent_enums
	enums = require("enums");
	---@type interaction
	interaction = require("containers/interaction");
	components = {
		---@type component_actionRow
		actionRow = require("containers/components/actionRow");
		---@type component_button
		button = require("containers/components/button");
		---@type component_emoji
		emoji = require("containers/components/emoji");
		---@type component_textInput
		textInput = require("containers/components/textInput");
		---@type component_modal
		modal = require("containers/components/modal");
	};
	---inject enchent libs into client
	---@param client Client
	inject = function(client)
		eventHandler.mount(client._events); ---@diagnostic disable-line
		appliactionCommand(client);
	end;
};
