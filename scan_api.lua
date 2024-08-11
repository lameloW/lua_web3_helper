local https = require("ssl.https")
local ltn12 = require("ltn12")
local cjson = require("cjson")
local config = require("config")

local bscscan = {}

function bscscan.init(api_key)
    bscscan.api_key = api_key
end

function bscscan.request(params)
    local base_url = config.rpc_url
    
    local query_string = {}
    for key, value in pairs(params) do
        table.insert(query_string, string.format("%s=%s", key, value))
    end
    table.insert(query_string, string.format("apikey=%s", bscscan.api_key))

    local url = base_url .. "?" .. table.concat(query_string, "&")
    print("Request URL:", url)

    local response_body = {}
    local res, code, response_headers = https.request{
        url = url,
        sink = ltn12.sink.table(response_body)
    }

    if not res then
        return nil, "HTTP request failed with status code " .. tostring(code)
    end

    local response_data = table.concat(response_body)
    -- print("Response Body:", response_data)
    return cjson.decode(response_data)
end

function bscscan.get_internal_transactions(contract_address, start_block, end_block, page, offset, sort)
    local params = {
        module = "account",
        action = "txlist",
        address = contract_address,
        startblock = start_block,
        endblock = end_block,
        page = page,
        offset = offset,
        sort = sort
    }

    return bscscan.request(params)
end

return bscscan