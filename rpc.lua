-- rpc.lua

local https = require("ssl.https")
local ltn12 = require("ltn12")
local cjson = require("cjson")

local rpc = {}

function rpc.init(rpc_url)
    rpc.url = rpc_url
end

function rpc.request(method, params)
    if type(params) ~= "table" then
        params = {}
    end

    if #params == 0 then
        params = cjson.empty_array
    end

    local request_body = cjson.encode({
        jsonrpc = "2.0",
        method = method,
        params = params,
        id = 1
    })

    print("Request Body:", request_body)

    local response_body = {}
    local res, code, response_headers = https.request {
        url = rpc.url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#request_body)
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    }

    if not res then
        return nil, code
    end

    local response_data = table.concat(response_body)
    print("Response Body:", response_data)
    return cjson.decode(response_data)
end

function rpc.query_logs(from_block, to_block, contract_address, topics)
    local filter = {
        fromBlock = from_block,
        toBlock = to_block,
        address = contract_address,
        topics = topics
    }

    local params = { filter }
    return rpc.request("eth_getLogs", params)
end

function rpc.get_tx(tx_hash)
    local transaction = rpc.get_transaction(tx_hash)

    if transaction then
        if transaction.error then
            print("Error: " .. transaction.error.message)

            return {}
        else
            return {
                transactionHash = tx_hash,
                data = transaction.result.input
            }
        end
    else
        print("Failed to retrieve transaction details.")

        return {}
    end
end

function rpc.get_transaction(tx_hash)
    local params = { tx_hash }
    return rpc.request("eth_getTransactionByHash", params)
end



return rpc