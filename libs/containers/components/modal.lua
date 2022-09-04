---@class component_modal:table
local this = {};

local allBindings = {};
local interaction = require("../interaction");
local enums = require("../../enums");
local modal = enums.interactionType.modalSubmit;

---@class enchent_modal_props:table
---@field public title string title of modal
---@field public custom_id string a developer-defined identifier for the input, max 100 characters
---@field public components table child components

---@param props enchent_modal_props
---@return component_modal
function this.new(props)
	local func = props.func;
	if func then
		allBindings[props.custom_id] = func;
		props.func = nil;
	end

    return props
end

local function runBindings(id,interaction)
	local binding = allBindings[id];
	if binding then
		binding(interaction);
	end
end
local warp = coroutine.wrap;

local function parseModalComponents(modalComponents,t)
	if not t then
		t = {};
		for _,child in ipairs(modalComponents) do
			parseModalComponents(child,t);
		end
		return t;
	end

	if modalComponents.type == 1 then
		local components = modalComponents.components;
		if components then
			for _,child in ipairs(components) do
				parseModalComponents(child,t);
			end
		end
	else
		t[modalComponents.custom_id] = modalComponents.value;
	end

end

local evnetHandler = require("../../eventHandler");
evnetHandler.make("INTERACTION_CREATE",function (data, client)
	if data.type == modal then
		local new = interaction(data,client);
		local modalId = new.modalId;
		warp(runBindings)(modalId,new);
		return true,client:emit('modalSubmitted',modalId,parseModalComponents(new.modalComponents),new);
	end
	return false;
end);

return this;
