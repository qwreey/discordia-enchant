---Handler for actionRow component
---@class component_textInput:table
local this = {};
local enums = require("../../enums");
local textInput = enums.componentType.textInput;

---@class enchent_textInput_props:table
---@field public custom_id string a developer-defined identifier for the input, max 100 characters
---@field public style enchent_enums_textInputStyle_child the Text Input Style
---@field public label string the label for this component, max 45 characters
---@field public min_length number|nil the minimum input length for a text input, min 0, max 4000
---@field public max_length number|nil the maximum input length for a text input, min 1, max 4000
---@field public required boolean|nil whether this component is required to be filled, default true
---@field public value string|nil a pre-filled value for this component, max 4000 characters
---@field public placeholder string|nil ustom placeholder text if the input is empty, max 100 characters

---Create new emoji object
---@param textInputObject enchent_textInput_props table that containing textInput data
---@return component_textInput
function this.new(textInputObject)
    textInputObject.type = textInput;
    return textInputObject;
end

return this;
