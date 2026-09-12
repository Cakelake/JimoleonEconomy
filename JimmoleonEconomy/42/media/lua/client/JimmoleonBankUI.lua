JimmoleonBankUI = JimmoleonBankUI or {}

local selectedValuable = nil

JimmoleonBankUI.depositValuables = {
    { name = "Cash", itemType = "Base.Money", value = 1 },
    { name = "Silver Coin", itemType = "Base.SilverCoin", value = 25 },
    { name = "Gold Coin", itemType = "Base.GoldCoin", value = 100 },
    { name = "Silver Ingot", itemType = "Base.SilverBar", value = 250 },
    { name = "Gold Ingot", itemType = "Base.GoldBar", value = 1000 },
    { name = "Diamond", itemType = "Base.Diamond", value = 500 },
    { name = "Ruby", itemType = "Base.Ruby", value = 500 },
    { name = "Sapphire", itemType = "Base.Sapphire", value = 500 },
    { name = "Emerald", itemType = "Base.Emerald", value = 500 },
}

function JimmoleonBankUI:ClosePanel()
    if JimmoleonBankUI.instance then
        JimmoleonBankUI.instance:setVisible(false)
        JimmoleonBankUI.instance:removeFromUIManager()
        JimmoleonBankUI.instance = nil
    end
end

function JimmoleonBankUI.open(pl)
    if pl == nil then return end

    JimmoleonBankUI:ClosePanel()

    local md = pl:getModData()
    local accountID = md.JimmoleonAccountID or "UNKNOWN"
    local balance = md.JimmoleonBalance or 0

    local width, height = 450, 360
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    JimmoleonBankUI.instance = ISPanel:new(x, y, width, height)
    JimmoleonBankUI.instance:initialise()
    JimmoleonBankUI.instance.moveWithMouse = true
    JimmoleonBankUI.instance:setAlwaysOnTop(true)
    JimmoleonBankUI.instance.backgroundColor = { r = 0.05, g = 0.05, b = 0.05, a = 0.95 }
    JimmoleonBankUI.instance.borderColor = { r = 0.2, g = 0.8, b = 0.2, a = 1 }

    local window = JimmoleonBankUI.instance

    window:addChild(ISLabel:new(20, 20, 25, "JIMMOLEON BANK", 1, 1, 1, 1, UIFont.Large, true))
    window:addChild(ISLabel:new(20, 65, 25, "Account: " .. tostring(accountID), 1, 1, 1, 1, UIFont.Medium, true))
    window:addChild(ISLabel:new(20, 100, 25, "Balance: " .. tostring(balance) .. " Jimoleons", 0.3, 1, 0.3, 1, UIFont.Medium, true))

    local depositButton = ISButton:new(110, 145, 230, 35, "Deposit", window, function()
        JimmoleonBankUI.openDeposit(pl)
    end)

    depositButton:initialise()
    window:addChild(depositButton)

    local transferButton = ISButton:new(110, 190, 230, 35, "Transfer", window, function()
        JimmoleonBankUI.openTransfer(pl)
    end)

    transferButton:initialise()
    window:addChild(transferButton)

    local transactionButton = ISButton:new(110, 235, 230, 35, "Transactions", window, function()
        JimmoleonBankUI.openTransactions(pl)
    end)

    transactionButton:initialise()
    window:addChild(transactionButton)

    local closeButton = ISButton:new(175, 305, 100, 30, "Close", window, function()
        JimmoleonBankUI:ClosePanel()
    end)

    closeButton:initialise()
    window:addChild(closeButton)

    window:addToUIManager()
    window:setVisible(true)

    return window
end

function JimmoleonBankUI.openDeposit(pl)
    if pl == nil then return end

    JimmoleonBankUI:ClosePanel()

    local inv = pl:getInventory()
    local width, height = 520, 390
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    JimmoleonBankUI.instance = ISPanel:new(x, y, width, height)
    JimmoleonBankUI.instance:initialise()
    JimmoleonBankUI.instance.moveWithMouse = true
    JimmoleonBankUI.instance:setAlwaysOnTop(true)
    JimmoleonBankUI.instance.backgroundColor = { r = 0.05, g = 0.05, b = 0.05, a = 0.95 }
    JimmoleonBankUI.instance.borderColor = { r = 0.2, g = 0.8, b = 0.2, a = 1 }

    local window = JimmoleonBankUI.instance

    window:addChild(ISLabel:new(20, 20, 25, "DEPOSIT", 1, 1, 1, 1, UIFont.Large, true))
    window:addChild(ISLabel:new(20, 70, 25, "Valuable:", 1, 1, 1, 1, UIFont.Medium, true))

    local valuableCombo = ISComboBox:new(140, 65, 300, 30, window, function(target, combo)
        selectedValuable = combo:getSelectedData()

        if selectedValuable == nil then return end

        JimmoleonBankUI.updateDepositInformation(window, inv)

        if window.amountBox ~= nil then
            window.amountBox:setText("0")
        end
    end)

    valuableCombo:initialise()

    for _, valuable in ipairs(JimmoleonBankUI.depositValuables) do
        valuableCombo:addOptionWithData(valuable.name, valuable)
    end

    valuableCombo.selected = 1
    selectedValuable = JimmoleonBankUI.depositValuables[1]

    window:addChild(valuableCombo)

    local initialCount = inv:getItemCount(selectedValuable.itemType)
    local availableLabel = ISLabel:new(20, 120, 25, "You Have: " .. tostring(initialCount), 0.8, 0.8, 0.8, 1, UIFont.Medium, true)

    window.availableLabel = availableLabel
    window:addChild(availableLabel)

    local valueLabel = ISLabel:new(20, 155, 25, "Value: " .. tostring(selectedValuable.value) .. " Jimoleons each", 0.3, 1, 0.3, 1, UIFont.Medium, true)

    window.valueLabel = valueLabel
    window:addChild(valueLabel)

    window:addChild(ISLabel:new(20, 205, 25, "Amount:", 1, 1, 1, 1, UIFont.Medium, true))

    local amountBox = ISTextEntryBox:new("0", 140, 200, 120, 30)
    amountBox:initialise()

    window.amountBox = amountBox
    window:addChild(amountBox)

    local depositButton = ISButton:new(280, 200, 160, 35, "Deposit", window, function()
        if selectedValuable == nil then return end

        local amount = tonumber(amountBox:getText())

        if amount == nil then
            pl:setHaloNote("Enter a valid amount.", 1, 0, 0, 300)
            return
        end

        sendClientCommand("JimmoleonEconomy", "DepositValuable", {
            itemType = selectedValuable.itemType,
            amount = amount
        })
    end)

    depositButton:initialise()
    window:addChild(depositButton)

    local backButton = ISButton:new(120, 300, 130, 35, "Back to Bank", window, function()
        JimmoleonBankUI.open(pl)
    end)

    backButton:initialise()
    window:addChild(backButton)

    local closeButton = ISButton:new(270, 300, 130, 35, "Close", window, function()
        JimmoleonBankUI:ClosePanel()
    end)

    closeButton:initialise()
    window:addChild(closeButton)

    window:addToUIManager()
    window:setVisible(true)

    return window
end

function JimmoleonBankUI.openTransfer(pl)
    if pl == nil then return end

    JimmoleonBankUI:ClosePanel()

    local md = pl:getModData()
    local currentBalance = md.JimmoleonBalance or 0

    local width, height = 520, 390
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    JimmoleonBankUI.instance = ISPanel:new(x, y, width, height)
    JimmoleonBankUI.instance:initialise()
    JimmoleonBankUI.instance.moveWithMouse = true
    JimmoleonBankUI.instance:setAlwaysOnTop(true)
    JimmoleonBankUI.instance.backgroundColor = { r = 0.05, g = 0.05, b = 0.05, a = 0.95 }
    JimmoleonBankUI.instance.borderColor = { r = 0.2, g = 0.8, b = 0.2, a = 1 }

    local window = JimmoleonBankUI.instance

    window:addChild(ISLabel:new(20, 20, 25, "TRANSFER JIMOLEONS", 1, 1, 1, 1, UIFont.Large, true))
    window:addChild(ISLabel:new(20, 70, 25, "Available: " .. tostring(currentBalance) .. " Jimoleons", 0.3, 1, 0.3, 1, UIFont.Medium, true))
    window:addChild(ISLabel:new(20, 120, 25, "Recipient Account:", 1, 1, 1, 1, UIFont.Medium, true))

    local recipientBox = ISTextEntryBox:new("", 20, 150, 400, 35)
    recipientBox:initialise()
    window.recipientBox = recipientBox
    window:addChild(recipientBox)

    window:addChild(ISLabel:new(20, 205, 25, "Amount:", 1, 1, 1, 1, UIFont.Medium, true))

    local amountBox = ISTextEntryBox:new("0", 20, 235, 180, 35)
    amountBox:initialise()
    window.amountBox = amountBox
    window:addChild(amountBox)

    local transferButton = ISButton:new(225, 235, 195, 40, "Transfer", window, function()
        local recipientAccountID = recipientBox:getText()
        local amount = tonumber(amountBox:getText())

        if recipientAccountID == nil or tostring(recipientAccountID) == "" then
            pl:setHaloNote("Enter a recipient account ID.", 1, 0, 0, 300)
            return
        end

        if amount == nil then
            pl:setHaloNote("Enter a valid amount.", 1, 0, 0, 300)
            return
        end

        sendClientCommand("JimmoleonEconomy", "TransferJimoleons", {
            recipientAccountID = tostring(recipientAccountID),
            amount = amount,
        })
    end)

    transferButton:initialise()
    window:addChild(transferButton)

    local backButton = ISButton:new(120, 315, 130, 35, "Back to Bank", window, function()
        JimmoleonBankUI.open(pl)
    end)

    backButton:initialise()
    window:addChild(backButton)

    local closeButton = ISButton:new(270, 315, 130, 35, "Close", window, function()
        JimmoleonBankUI:ClosePanel()
    end)

    closeButton:initialise()
    window:addChild(closeButton)

    window:addToUIManager()
    window:setVisible(true)

    return window
end

function JimmoleonBankUI.openTransactions(pl)
    if pl == nil then return end

    JimmoleonBankUI:ClosePanel()

    local md = pl:getModData()
    local transactions = md.JimmoleonTransactions or {}

    local width, height = 700, 500
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    JimmoleonBankUI.instance = ISPanel:new(x, y, width, height)
    JimmoleonBankUI.instance:initialise()
    JimmoleonBankUI.instance.moveWithMouse = true
    JimmoleonBankUI.instance:setAlwaysOnTop(true)
    JimmoleonBankUI.instance.backgroundColor = { r = 0.05, g = 0.05, b = 0.05, a = 0.95 }
    JimmoleonBankUI.instance.borderColor = { r = 0.2, g = 0.8, b = 0.2, a = 1 }

    local window = JimmoleonBankUI.instance

    window:addChild(ISLabel:new(20, 20, 25, "TRANSACTION HISTORY", 1, 1, 1, 1, UIFont.Large, true))

    local accountID = md.JimmoleonAccountID or "UNKNOWN"

    window:addChild(ISLabel:new(20, 60, 25, "Account: " .. tostring(accountID), 0.8, 0.8, 0.8, 1, UIFont.Small, true))

    local yPosition = 100

    if #transactions == 0 then
        window:addChild(ISLabel:new(20, yPosition, 25, "No transactions yet.", 0.7, 0.7, 0.7, 1, UIFont.Medium, true))
    else
        local displayed = 0

        for i = #transactions, 1, -1 do
            local transaction = transactions[i]
            local amount = transaction.amount or 0
            local description = transaction.description or "Unknown Transaction"
            local fType = transaction.type or "UNKNOWN"
            local prefix = ""

            if amount >= 0 then
                prefix = "+"
            end

            window:addChild(ISLabel:new(20, yPosition, 25, prefix .. tostring(amount) .. " Jimoleons", 0.3, 1, 0.3, 1, UIFont.Medium, true))
            window:addChild(ISLabel:new(210, yPosition, 25, tostring(description), 1, 1, 1, 1, UIFont.Medium, true))
            window:addChild(ISLabel:new(500, yPosition, 25, tostring(fType), 0.6, 0.6, 0.6, 1, UIFont.Small, true))

            yPosition = yPosition + 50
            displayed = displayed + 1

            if displayed >= 7 then
                break
            end
        end
    end

    local backButton = ISButton:new(240, 445, 120, 30, "Back to Bank", window, function()
        JimmoleonBankUI.open(pl)
    end)

    backButton:initialise()
    window:addChild(backButton)

    local closeButton = ISButton:new(380, 445, 80, 30, "Close", window, function()
        JimmoleonBankUI:ClosePanel()
    end)

    closeButton:initialise()
    window:addChild(closeButton)

    window:addToUIManager()
    window:setVisible(true)

    return window
end

function JimmoleonBankUI.onServerCommand(module, command, args)
    if module ~= "JimmoleonEconomy" then return end
    if args == nil then return end

    if command == "DepositResult" then
        local pl = getPlayer()

        if args.success == true then
            print("JIMOLEON DEPOSIT SUCCESS: +" .. tostring(args.amount))

            if pl ~= nil then
                pl:setHaloNote("+" .. tostring(args.amount) .. " Jimoleons", 0, 1, 0, 300)

                if JimmoleonBankUI.instance ~= nil and selectedValuable ~= nil then
                    JimmoleonBankUI.updateDepositInformation(JimmoleonBankUI.instance, pl:getInventory())

                    if JimmoleonBankUI.instance.amountBox ~= nil then
                        JimmoleonBankUI.instance.amountBox:setText("0")
                    end
                end
            end
        else
            print("JIMOLEON DEPOSIT FAILED: " .. tostring(args.message))

            if pl ~= nil then
                pl:setHaloNote(tostring(args.message), 1, 0, 0, 300)
            end
        end

        return
    end

    if command == "TransferResult" then
        local pl = getPlayer()

        if args.success == true then
            print("JIMOLEON TRANSFER SUCCESS: -" .. tostring(args.amount))

            if pl ~= nil then
                pl:setHaloNote("Transferred " .. tostring(args.amount) .. " Jimoleons to " .. tostring(args.recipientName), 0, 1, 0, 300)
                JimmoleonBankUI.open(pl)
            end
        else
            print("JIMOLEON TRANSFER FAILED: " .. tostring(args.message))

            if pl ~= nil then
                pl:setHaloNote(tostring(args.message), 1, 0, 0, 300)
            end
        end

        return
    end

    if command == "TransferReceived" then
        local pl = getPlayer()

        if pl ~= nil then
            pl:setHaloNote("Received " .. tostring(args.amount) .. " Jimoleons from " .. tostring(args.senderName), 0, 1, 0, 300)
        end

        return
    end
end

Events.OnServerCommand.Add(JimmoleonBankUI.onServerCommand)

function JimmoleonBankUI.updateDepositInformation(window, inv)
    if selectedValuable == nil then return end

    local count = inv:getItemCount(selectedValuable.itemType)

    if window.availableLabel ~= nil then
        window.availableLabel:setName("You Have: " .. tostring(count))
    end

    if window.valueLabel ~= nil then
        window.valueLabel:setName("Value: " .. tostring(selectedValuable.value) .. " Jimoleons each")
    end
end

print("========================================")
print("JIMMOLEON BANK UI LOADED")
print("========================================")