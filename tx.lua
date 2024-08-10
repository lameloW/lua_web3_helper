-- tx.lua

local rpc = require("rpc")
local common = require("./utils/common")

-- local rpc_url = "https://arb1.arbitrum.io/rpc" -- Rpc url
local rpc_url = "https://rpc.ankr.com/bsc" -- Rpc url
local contract_address = "0xfabE62133473e11088B1cFa1dBD4c0b54F858bf5" -- Disperser contract address
local topics = {
    { "0x3af7f326060b91f1af55623af2f2950a6e653322c948f59b22f93ab9f699e1ed" }
    -- Add more topics as needed
}

local function getLogs(from_block, to_block)
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
    
    local from_block = "0x27556d7" -- Starting block 41244376
    local to_block = "latest" -- Ending block

    local logs = getLogs(from_block, to_block)
    
    local tx_info = getDecodeTxInfo(logs[#logs])

    if tx_info.transactionHash then
        common.print_table(tx_info)
    end

end

main()