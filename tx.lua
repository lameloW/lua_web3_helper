-- tx.lua

local rpc = require("rpc")
local common = require("./utils/common")

local rpc_url = "https://arb1.arbitrum.io/rpc" -- Rpc url
local from_block = "0x0" -- Starting block
local to_block = "latest" -- Ending block
local contract_address = "" -- Disperser contract address
local topics = {
    { "" }
    -- Add more topics as needed
}

local function getLogs()
    local response = rpc.query_logs(from_block, to_block, contract_address, topics)

    if response then
        if response.error then
            print("Error: " .. response.error.message)

            return {}
        else
            local logs = {}

            print("Logs: ")
            for _, log in ipairs(response.result) do

                local season = tonumber(log.topics[2]:sub(3), 16)
                local timestamp = tonumber(log.data:sub(3), 16)
                local transactionHash = log.transactionHash

                logs[season] = {
                    season = season,
                    timestamp = timestamp,
                    transactionHash = transactionHash,
                }
            end

            table.sort(logs, function(a, b)
                return a.season < b.season
            end)

            return logs
        end
    else
        print("Failed to retrieve logs.")

        return {}
    end
end

local function getDecodeTxInfo(log_detail)
    local tx_detail = rpc.get_tx(log_detail.transactionHash)

    if tx_detail.data then
        local info = common.decode_data(tx_detail.data)

        return {
            season = log_detail.season,
            timestamp = log_detail.timestamp,
            transactionHash = log_detail.transactionHash,

            token_address = info.token_address,
            addresses = info.addresses,
            amounts = info.amounts
        }
    else
        print("Failed to get tx_detail")

        return {}
    end
end

local function main()
    rpc.init(rpc_url)
    
    local logs = getLogs()
    
    local tx_info = getDecodeTxInfo(logs[#logs])

    if tx_info.transactionHash then
        common.print_table(tx_info)
    end

end

main()