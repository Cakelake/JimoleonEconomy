print("========================================")
print("JIMMOLEON BANK UI LOADED")
print("========================================")


--------------------------------------------------
-- MAIN UI TABLE
--------------------------------------------------

JimmoleonBankUI = {}


--------------------------------------------------
-- ACTIVE WINDOW
--------------------------------------------------

local activeWindow = nil


--------------------------------------------------
-- CURRENT SELECTED VALUABLE
--------------------------------------------------

local selectedValuable = nil


--------------------------------------------------
-- DEPOSIT ITEMS
--------------------------------------------------

local depositValuables = {

    {
        name = "Cash",
        itemType = "Base.Money",
        value = 1
    },

    {
        name = "Silver Coin",
        itemType = "Base.SilverCoin",
        value = 25
    },

    {
        name = "Gold Coin",
        itemType = "Base.GoldCoin",
        value = 100
    },

    {
        name = "Silver Ingot",
        itemType = "Base.SilverBar",
        value = 250
    },

    {
        name = "Gold Ingot",
        itemType = "Base.GoldBar",
        value = 1000
    },

    {
        name = "Diamond",
        itemType = "Base.Diamond",
        value = 500
    },

    {
        name = "Ruby",
        itemType = "Base.Ruby",
        value = 500
    },

    {
        name = "Sapphire",
        itemType = "Base.Sapphire",
        value = 500
    },

    {
        name = "Emerald",
        itemType = "Base.Emerald",
        value = 500
    }

}


--------------------------------------------------
-- CLOSE ACTIVE WINDOW
--------------------------------------------------

local function closeActiveWindow()

    if activeWindow ~= nil then

        activeWindow:close()

        activeWindow = nil

    end

end


--------------------------------------------------
-- CREATE MOVABLE WINDOW
--------------------------------------------------

local function createWindow(
    x,
    y,
    width,
    height
)

    closeActiveWindow()

    local window =
        ISPanel:new(
            x,
            y,
            width,
            height
        )

    window:initialise()

    window.moveWithMouse =
        true

    window:setAlwaysOnTop(
        true
    )

    window.backgroundColor =
        {
            r = 0.05,
            g = 0.05,
            b = 0.05,
            a = 0.95
        }

    window.borderColor =
        {
            r = 0.2,
            g = 0.8,
            b = 0.2,
            a = 1
        }

    activeWindow =
        window

    return window

end


--------------------------------------------------
-- CLOSE WINDOW
--------------------------------------------------

local function closeWindow(
    window
)

    if window ~= nil then

        window:close()

    end

    if activeWindow == window then

        activeWindow = nil

    end

end


--------------------------------------------------
-- SERVER RESPONSE
--------------------------------------------------

local function onServerCommand(
    module,
    command,
    args
)

    if module ~=
        "JimmoleonEconomy"
    then
        return
    end

    if args == nil then
        return
    end


    --------------------------------------------------
    -- DEPOSIT RESULT
    --------------------------------------------------

    if command ==
        "DepositResult"
    then

        local player =
            getPlayer()

        if args.success == true then

            print(
                "JIMOLEON DEPOSIT SUCCESS: +" ..
                tostring(
                    args.amount
                )
            )

            if player ~= nil then

                player:setHaloNote(
                    "+" ..
                    tostring(
                        args.amount
                    ) ..
                    " Jimoleons",
                    0,
                    1,
                    0,
                    300
                )


                if activeWindow ~= nil
                and selectedValuable ~= nil
                then

                    updateDepositInformation(
                        activeWindow,
                        player:getInventory()
                    )


                    if activeWindow.amountBox ~= nil then

                        activeWindow.amountBox:setText(
                            "0"
                        )

                    end

                end

            end

        else

            print(
                "JIMOLEON DEPOSIT FAILED: " ..
                tostring(
                    args.message
                )
            )

            if player ~= nil then

                player:setHaloNote(
                    tostring(
                        args.message
                    ),
                    1,
                    0,
                    0,
                    300
                )

            end

        end

        return

    end


    --------------------------------------------------
    -- TRANSFER RESULT
    --------------------------------------------------

    if command ==
        "TransferResult"
    then

        local player =
            getPlayer()

        if args.success == true then

            print(
                "JIMOLEON TRANSFER SUCCESS: -" ..
                tostring(
                    args.amount
                )
            )

            if player ~= nil then

                player:setHaloNote(
                    "Transferred " ..
                    tostring(
                        args.amount
                    ) ..
                    " Jimoleons to " ..
                    tostring(
                        args.recipientName
                    ),
                    0,
                    1,
                    0,
                    300
                )

                JimmoleonBankUI.open(
                    player
                )

            end

        else

            print(
                "JIMOLEON TRANSFER FAILED: " ..
                tostring(
                    args.message
                )
            )

            if player ~= nil then

                player:setHaloNote(
                    tostring(
                        args.message
                    ),
                    1,
                    0,
                    0,
                    300
                )

            end

        end

        return

    end


    --------------------------------------------------
    -- TRANSFER RECEIVED
    --------------------------------------------------

    if command ==
        "TransferReceived"
    then

        local player =
            getPlayer()

        if player ~= nil then

            player:setHaloNote(
                "Received " ..
                tostring(
                    args.amount
                ) ..
                " Jimoleons from " ..
                tostring(
                    args.senderName
                ),
                0,
                1,
                0,
                300
            )

        end

        return

    end

end


--------------------------------------------------
-- SERVER EVENT
--------------------------------------------------

Events.OnServerCommand.Add(
    onServerCommand
)


--------------------------------------------------
-- UPDATE DEPOSIT INFORMATION
--------------------------------------------------

function updateDepositInformation(
    window,
    inventory
)

    if selectedValuable == nil then
        return
    end

    local count =
        inventory:getItemCount(
            selectedValuable.itemType
        )


    if window.availableLabel ~= nil then

        window.availableLabel:setName(
            "You Have: " ..
            tostring(
                count
            )
        )

    end


    if window.valueLabel ~= nil then

        window.valueLabel:setName(
            "Value: " ..
            tostring(
                selectedValuable.value
            ) ..
            " Jimoleons each"
        )

    end

end


--------------------------------------------------
-- DEPOSIT WINDOW
--------------------------------------------------

function JimmoleonBankUI.openDeposit(
    player
)

    if player == nil then
        return
    end

    local inventory =
        player:getInventory()

    local width = 520
    local height = 390

    local x =
        (
            getCore():getScreenWidth()
            - width
        ) / 2

    local y =
        (
            getCore():getScreenHeight()
            - height
        ) / 2

    local window =
        createWindow(
            x,
            y,
            width,
            height
        )


    --------------------------------------------------
    -- TITLE
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            20,
            25,
            "DEPOSIT",
            1,
            1,
            1,
            1,
            UIFont.Large,
            true
        )
    )


    --------------------------------------------------
    -- VALUABLE LABEL
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            70,
            25,
            "Valuable:",
            1,
            1,
            1,
            1,
            UIFont.Medium,
            true
        )
    )


    --------------------------------------------------
    -- VALUABLE DROPDOWN
    --------------------------------------------------

    local valuableCombo

    valuableCombo =
        ISComboBox:new(
            140,
            65,
            300,
            30,
            window,

            function(
                target,
                combo
            )

                selectedValuable =
                    combo:getSelectedData()

                if selectedValuable == nil then
                    return
                end

                updateDepositInformation(
                    window,
                    inventory
                )

                if window.amountBox ~= nil then

                    window.amountBox:setText(
                        "0"
                    )

                end

            end
        )

    valuableCombo:initialise()


    for _, valuable in ipairs(
        depositValuables
    ) do

        valuableCombo:addOptionWithData(
            valuable.name,
            valuable
        )

    end


    valuableCombo.selected =
        1

    selectedValuable =
        depositValuables[1]


    window:addChild(
        valuableCombo
    )


    --------------------------------------------------
    -- YOU HAVE
    --------------------------------------------------

    local initialCount =
        inventory:getItemCount(
            selectedValuable.itemType
        )

    local availableLabel =
        ISLabel:new(
            20,
            120,
            25,
            "You Have: " ..
            tostring(
                initialCount
            ),
            0.8,
            0.8,
            0.8,
            1,
            UIFont.Medium,
            true
        )

    window.availableLabel =
        availableLabel

    window:addChild(
        availableLabel
    )


    --------------------------------------------------
    -- VALUE
    --------------------------------------------------

    local valueLabel =
        ISLabel:new(
            20,
            155,
            25,
            "Value: " ..
            tostring(
                selectedValuable.value
            ) ..
            " Jimoleons each",
            0.3,
            1,
            0.3,
            1,
            UIFont.Medium,
            true
        )

    window.valueLabel =
        valueLabel

    window:addChild(
        valueLabel
    )


    --------------------------------------------------
    -- AMOUNT
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            205,
            25,
            "Amount:",
            1,
            1,
            1,
            1,
            UIFont.Medium,
            true
        )
    )


    local amountBox =
        ISTextEntryBox:new(
            "0",
            140,
            200,
            120,
            30
        )

    amountBox:initialise()

    window.amountBox =
        amountBox

    window:addChild(
        amountBox
    )


    --------------------------------------------------
    -- DEPOSIT BUTTON
    --------------------------------------------------

    local depositButton =
        ISButton:new(
            280,
            200,
            160,
            35,
            "Deposit",
            window,

            function()

                if selectedValuable == nil then
                    return
                end

                local amount =
                    tonumber(
                        amountBox:getText()
                    )

                if amount == nil then

                    player:setHaloNote(
                        "Enter a valid amount.",
                        1,
                        0,
                        0,
                        300
                    )

                    return

                end


                sendClientCommand(
                    "JimmoleonEconomy",
                    "DepositValuable",
                    {
                        itemType =
                            selectedValuable.itemType,

                        amount =
                            amount
                    }
                )

            end
        )

    depositButton:initialise()

    window:addChild(
        depositButton
    )


    --------------------------------------------------
    -- BACK TO BANK
    --------------------------------------------------

    local backButton =
        ISButton:new(
            120,
            300,
            130,
            35,
            "Back to Bank",
            window,

            function()

                JimmoleonBankUI.open(
                    player
                )

            end
        )

    backButton:initialise()

    window:addChild(
        backButton
    )


    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local closeButton =
        ISButton:new(
            270,
            300,
            130,
            35,
            "Close",
            window,

            function()

                closeWindow(
                    window
                )

            end
        )

    closeButton:initialise()

    window:addChild(
        closeButton
    )


    window:addToUIManager()

    return window

end


--------------------------------------------------
-- TRANSFER WINDOW
--------------------------------------------------

function JimmoleonBankUI.openTransfer(
    player
)

    if player == nil then
        return
    end


    local modData =
        player:getModData()

    local currentBalance =
        modData.JimmoleonBalance or
        0


    --------------------------------------------------
    -- WINDOW SIZE
    --------------------------------------------------

    local width = 520
    local height = 390


    local x =
        (
            getCore():getScreenWidth()
            - width
        ) / 2


    local y =
        (
            getCore():getScreenHeight()
            - height
        ) / 2


    local window =
        createWindow(
            x,
            y,
            width,
            height
        )


    --------------------------------------------------
    -- TITLE
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            20,
            25,
            "TRANSFER JIMOLEONS",
            1,
            1,
            1,
            1,
            UIFont.Large,
            true
        )
    )


    --------------------------------------------------
    -- CURRENT BALANCE
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            70,
            25,
            "Available: " ..
            tostring(
                currentBalance
            ) ..
            " Jimoleons",
            0.3,
            1,
            0.3,
            1,
            UIFont.Medium,
            true
        )
    )


    --------------------------------------------------
    -- RECIPIENT ACCOUNT LABEL
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            120,
            25,
            "Recipient Account:",
            1,
            1,
            1,
            1,
            UIFont.Medium,
            true
        )
    )


    --------------------------------------------------
    -- RECIPIENT ACCOUNT BOX
    --------------------------------------------------

    local recipientBox =
        ISTextEntryBox:new(
            "",
            20,
            150,
            400,
            35
        )

    recipientBox:initialise()

    window.recipientBox =
        recipientBox

    window:addChild(
        recipientBox
    )


    --------------------------------------------------
    -- AMOUNT LABEL
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            205,
            25,
            "Amount:",
            1,
            1,
            1,
            1,
            UIFont.Medium,
            true
        )
    )


    --------------------------------------------------
    -- AMOUNT BOX
    --------------------------------------------------

    local amountBox =
        ISTextEntryBox:new(
            "0",
            20,
            235,
            180,
            35
        )

    amountBox:initialise()

    window.amountBox =
        amountBox

    window:addChild(
        amountBox
    )


    --------------------------------------------------
    -- TRANSFER BUTTON
    --------------------------------------------------

    local transferButton =
        ISButton:new(
            225,
            235,
            195,
            40,
            "Transfer",
            window,

            function()

                local recipientAccountID =
                    recipientBox:getText()

                local amount =
                    tonumber(
                        amountBox:getText()
                    )


                --------------------------------------------------
                -- VALIDATE RECIPIENT
                --------------------------------------------------

                if recipientAccountID == nil
                or tostring(
                    recipientAccountID
                ) == ""
                then

                    player:setHaloNote(
                        "Enter a recipient account ID.",
                        1,
                        0,
                        0,
                        300
                    )

                    return

                end


                --------------------------------------------------
                -- VALIDATE AMOUNT
                --------------------------------------------------

                if amount == nil then

                    player:setHaloNote(
                        "Enter a valid amount.",
                        1,
                        0,
                        0,
                        300
                    )

                    return

                end


                --------------------------------------------------
                -- SEND TO SERVER
                --------------------------------------------------

                sendClientCommand(
                    "JimmoleonEconomy",
                    "TransferJimoleons",
                    {

                        recipientAccountID =
                            tostring(
                                recipientAccountID
                            ),

                        amount =
                            amount

                    }
                )

            end
        )

    transferButton:initialise()

    window:addChild(
        transferButton
    )


    --------------------------------------------------
    -- BACK TO BANK
    --------------------------------------------------

    local backButton =
        ISButton:new(
            120,
            315,
            130,
            35,
            "Back to Bank",
            window,

            function()

                JimmoleonBankUI.open(
                    player
                )

            end
        )

    backButton:initialise()

    window:addChild(
        backButton
    )


    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local closeButton =
        ISButton:new(
            270,
            315,
            130,
            35,
            "Close",
            window,

            function()

                closeWindow(
                    window
                )

            end
        )

    closeButton:initialise()

    window:addChild(
        closeButton
    )


    window:addToUIManager()

    return window

end


--------------------------------------------------
-- TRANSACTION HISTORY
--------------------------------------------------

function JimmoleonBankUI.openTransactions(
    player
)

    if player == nil then
        return
    end


    local modData =
        player:getModData()

    local transactions =
        modData.JimmoleonTransactions or {}


    local width = 700
    local height = 500


    local x =
        (
            getCore():getScreenWidth()
            - width
        ) / 2


    local y =
        (
            getCore():getScreenHeight()
            - height
        ) / 2


    local window =
        createWindow(
            x,
            y,
            width,
            height
        )


    --------------------------------------------------
    -- TITLE
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            20,
            25,
            "TRANSACTION HISTORY",
            1,
            1,
            1,
            1,
            UIFont.Large,
            true
        )
    )


    --------------------------------------------------
    -- ACCOUNT
    --------------------------------------------------

    local accountID =
        modData.JimmoleonAccountID or
        "UNKNOWN"


    window:addChild(
        ISLabel:new(
            20,
            60,
            25,
            "Account: " ..
            tostring(
                accountID
            ),
            0.8,
            0.8,
            0.8,
            1,
            UIFont.Small,
            true
        )
    )


    --------------------------------------------------
    -- TRANSACTIONS
    --------------------------------------------------

    local yPosition = 100


    if #transactions == 0 then

        window:addChild(
            ISLabel:new(
                20,
                yPosition,
                25,
                "No transactions yet.",
                0.7,
                0.7,
                0.7,
                1,
                UIFont.Medium,
                true
            )
        )

    else

        local displayed =
            0


        for i = #transactions, 1, -1 do

            local transaction =
                transactions[i]


            local amount =
                transaction.amount or
                0


            local description =
                transaction.description or
                "Unknown Transaction"


            local transactionType =
                transaction.type or
                "UNKNOWN"


            local prefix = ""


            if amount >= 0 then

                prefix = "+"

            end


            --------------------------------------------------
            -- AMOUNT
            --------------------------------------------------

            window:addChild(
                ISLabel:new(
                    20,
                    yPosition,
                    25,
                    prefix ..
                    tostring(
                        amount
                    ) ..
                    " Jimoleons",
                    0.3,
                    1,
                    0.3,
                    1,
                    UIFont.Medium,
                    true
                )
            )


            --------------------------------------------------
            -- DESCRIPTION
            --------------------------------------------------

            window:addChild(
                ISLabel:new(
                    210,
                    yPosition,
                    25,
                    tostring(
                        description
                    ),
                    1,
                    1,
                    1,
                    1,
                    UIFont.Medium,
                    true
                )
            )


            --------------------------------------------------
            -- TYPE
            --------------------------------------------------

            window:addChild(
                ISLabel:new(
                    500,
                    yPosition,
                    25,
                    tostring(
                        transactionType
                    ),
                    0.6,
                    0.6,
                    0.6,
                    1,
                    UIFont.Small,
                    true
                )
            )


            yPosition =
                yPosition + 50


            displayed =
                displayed + 1


            if displayed >= 7 then
                break
            end

        end

    end


    --------------------------------------------------
    -- BACK TO BANK
    --------------------------------------------------

    local backButton =
        ISButton:new(
            240,
            445,
            120,
            30,
            "Back to Bank",
            window,

            function()

                JimmoleonBankUI.open(
                    player
                )

            end
        )

    backButton:initialise()

    window:addChild(
        backButton
    )


    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local closeButton =
        ISButton:new(
            380,
            445,
            80,
            30,
            "Close",
            window,

            function()

                closeWindow(
                    window
                )

            end
        )

    closeButton:initialise()

    window:addChild(
        closeButton
    )


    window:addToUIManager()

    return window

end


--------------------------------------------------
-- MAIN BANK WINDOW
--------------------------------------------------

function JimmoleonBankUI.open(
    player
)

    if player == nil then
        return
    end


    local modData =
        player:getModData()


    local accountID =
        modData.JimmoleonAccountID or
        "UNKNOWN"


    local balance =
        modData.JimmoleonBalance or
        0


    local width = 450
    local height = 360


    local x =
        (
            getCore():getScreenWidth()
            - width
        ) / 2


    local y =
        (
            getCore():getScreenHeight()
            - height
        ) / 2


    local window =
        createWindow(
            x,
            y,
            width,
            height
        )


    --------------------------------------------------
    -- TITLE
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            20,
            25,
            "JIMMOLEON BANK",
            1,
            1,
            1,
            1,
            UIFont.Large,
            true
        )
    )


    --------------------------------------------------
    -- ACCOUNT ID
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            65,
            25,
            "Account: " ..
            tostring(
                accountID
            ),
            1,
            1,
            1,
            1,
            UIFont.Medium,
            true
        )
    )


    --------------------------------------------------
    -- BALANCE
    --------------------------------------------------

    window:addChild(
        ISLabel:new(
            20,
            100,
            25,
            "Balance: " ..
            tostring(
                balance
            ) ..
            " Jimoleons",
            0.3,
            1,
            0.3,
            1,
            UIFont.Medium,
            true
        )
    )


    --------------------------------------------------
    -- DEPOSIT
    --------------------------------------------------

    local depositButton =
        ISButton:new(
            110,
            145,
            230,
            35,
            "Deposit",
            window,

            function()

                JimmoleonBankUI.openDeposit(
                    player
                )

            end
        )

    depositButton:initialise()

    window:addChild(
        depositButton
    )


    --------------------------------------------------
    -- TRANSFER
    --------------------------------------------------

    local transferButton =
        ISButton:new(
            110,
            190,
            230,
            35,
            "Transfer",
            window,

            function()

                JimmoleonBankUI.openTransfer(
                    player
                )

            end
        )

    transferButton:initialise()

    window:addChild(
        transferButton
    )


    --------------------------------------------------
    -- TRANSACTIONS
    --------------------------------------------------

    local transactionButton =
        ISButton:new(
            110,
            235,
            230,
            35,
            "Transactions",
            window,

            function()

                JimmoleonBankUI.openTransactions(
                    player
                )

            end
        )

    transactionButton:initialise()

    window:addChild(
        transactionButton
    )


    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local closeButton =
        ISButton:new(
            175,
            305,
            100,
            30,
            "Close",
            window,

            function()

                closeWindow(
                    window
                )

            end
        )

    closeButton:initialise()

    window:addChild(
        closeButton
    )


    window:addToUIManager()

    return window

end