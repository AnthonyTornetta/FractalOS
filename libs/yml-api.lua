-- 
-- A very simple yml parser/decoder
-- This does not support anything but tables, use JSON (json-api) for anything more complex
-- 


local api = {}

function split(str, delimiter) -- in string-api
    local result = {}
    local from  = 1
    local delim_from, delim_to = string.find( str, delimiter, from  )
    while delim_from do
        table.insert( result, string.sub( str, from , delim_from-1 ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from  )
    end
    table.insert( result, string.sub( str, from  ) )
    return result
end

function api.encode(table)
    local encoded = ""

    local wrap = function(x, b)
        if b then
            return "\"" .. x .. "\""
        else
            return x
        end
    end

    for k, v in pairs(table) do
        local kStr = type(k) == "string"
        local vStr = type(v) == "string"

        if type(k) == "boolean" then
            if k then
                k = "true"
            else
                k = "false"
            end
        end
        if type(v) == "boolean" then
            if v then
                v = "true"
            else
                v = "false"
            end
        end

        encoded = encoded .. wrap(k, kStr) .. ":" .. wrap(v, vStr) .. "\n"
    end
    
    return encoded
end

function toRawType(str)
    checkArg(1, str, "string")

    local temp = tonumber(str)

    if temp == nil then
        if str == "true" then
            str = true
        elseif str == "false" then
            str = false
        elseif str == "nil" then
            str = nil
        end

        return str
    end

    return temp
end

function api.decode(yml)
    checkArg(1, yml, "string")

    local decoded = {}

    local lines = split(yml, "\n");
    
    for k, v in ipairs(lines) do
        if string.len(v) ~= 0 then
            local splitApart = split(v, ":");
            
            local key
            if string.sub(splitApart[1], 1, 1) == "\"" then
                key = string.sub(splitApart[1], 2, string.len(splitApart[1]) - 1) -- It's 100% a string
            else
                key = toRawType(splitApart[1]) -- It's most likely not a string
            end

            local val
            if string.sub(splitApart[2], 1, 1) == "\"" then
                val = string.sub(splitApart[2], 2, string.len(splitApart[2]) - 1) -- It's 100% a string
            else
                val = toRawType(splitApart[2]) -- It's most likely not a string
            end

            decoded[key] = val
        end
    end
    
    return decoded
end

return api