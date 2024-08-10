-- common.lua

local common = {}

function common.print_table(tbl, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)
    
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            print(indentStr .. tostring(k) .. ":")
            common.print_table(v, indent + 1)
        else
            print(indentStr .. tostring(k) .. ": " .. tostring(v))
        end
    end
end

function common.decode_data(data)
    local token_address = '';

    local offset = 10
    token_address = "0x" .. data:sub(offset + 25, offset + 64)

    local address_array_offset = tonumber(data:sub(offset + 65, offset + 128), 16) * 2
    local amount_array_offset = tonumber(data:sub(offset + 129, offset + 192), 16) * 2

    local address_array_len = tonumber(data:sub(offset + address_array_offset + 1, offset + address_array_offset + 64));
    local addresses = {}
    for i = 1, address_array_len do
        local address_param = "0x" .. data:sub(offset + address_array_offset + 25 + (64 * i), offset + address_array_offset + 64 + (64 * i))
        table.insert(addresses, address_param)
    end

    local amount_array_len = tonumber(data:sub(offset + amount_array_offset + 1, offset + amount_array_offset + 64));
    local amounts = {}
    for i = 1, amount_array_len do
        local amount_param = tonumber(data:sub(offset + amount_array_offset + 1 + (64 * i), offset + amount_array_offset + 64 + (64 * i)), 16)
        table.insert(amounts, amount_param)
    end

    return {
        token_address = token_address,
        addresses = addresses,
        amounts = amounts
    }
end

common.version = "1.0.0"

return common