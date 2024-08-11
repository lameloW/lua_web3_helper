-- tx.lua

local scan_api = require("scan_api")
local common = require("./utils/common")

local scan_api_key = ""
local contract_address = ""

local function get_decode_tx_info(tx_detail)
    if tx_detail.hash then
        local info = common.decode_data(tx_detail.input)

        return {
            timestamp = tx_detail.timestamp,
            hash = tx_detail.hash,
            blockNumber = tx_detail.blockNumber,

            token_address = info.token_address,
            addresses = info.addresses,
            amounts = info.amounts
        }
    else
        print("Failed to get tx_detail")

        return {}
    end
end

local function get_tx(contract_address, start_block, end_block, page, offset, sort)
    local response, err = scan_api.get_internal_transactions(contract_address, start_block, end_block, page, offset, sort)

    if response then
        if response.status == "1" and response.message == "OK" then

            local filter_txs = {}
            for _, item in ipairs(response.result) do
                if item.input then
                    local method_signature = string.sub(item.input, 1, 10)
                    if method_signature == "" then
                        table.insert(filter_txs, item)
                    end
                end
            end

            table.sort(filter_txs, function(a, b)
                return a.timeStamp > b.timeStamp
            end)

            return filter_txs
        else
            print("Error:", err)
            return {}
        end
    else
        print("Error:", err)
        return {}
    end
end

local function main()
    scan_api.init(scan_api_key)

    local txs = get_tx(contract_address, "0", "99999999", "1", "4000", "desc")
    print(#txs)

    if #txs > 0 then
        local tx_info = get_decode_tx_info(txs[1])

        if tx_info.hash then
            common.print_table(tx_info)
        end
    end
end

main()