print("========================================")
print("JIMOLEON ECONOMY SYSTEM")
print("========================================")


--------------------------------------------------
-- PAYCHECK SETTINGS
--------------------------------------------------

local function getPaycheckSettings()

    local settings =
        ModData.getOrCreate(
            "JimmoleonSettings"
        )

    if settings.PaycheckEnabled == nil then
        settings.PaycheckEnabled = true
    end

    if settings.PaycheckIntervalHours == nil then
        settings.PaycheckIntervalHours = 1
    end

    if settings.PaycheckAmount == nil then
        settings.PaycheckAmount = 100
    end

    return settings

end


--------------------------------------------------
-- PLAYER SESSION DATA
--------------------------------------------------

local sessionData = {}


--------------------------------------------------
-- ACCOUNT REGISTRY
--------------------------------------------------

local function getAccountRegistry()

    local registry =
        ModData.getOrCreate(
            "JimmoleonAccounts"
        )

    if registry.Accounts == nil then
        registry.Accounts = {}
    end

    return registry

end


--------------------------------------------------
-- GENERATE UNIQUE ACCOUNT ID
--------------------------------------------------

local function generateUniqueAccountID()

    local registry =
        getAccountRegistry()

    local accountID

    repeat

        accountID =
            "JM-" ..
            tostring(
                ZombRand(
                    100000,
                    999999
                )
            )

    until registry.Accounts[accountID] == nil

    return accountID

end


--------------------------------------------------
-- GET ACCOUNT BY ID
--------------------------------------------------

local function getAccountByID(
    accountID
)

    if accountID == nil then
        return nil
    end

    local registry =
        getAccountRegistry()

    return registry.Accounts[
        tostring(
            accountID
        )
    ]

end


--------------------------------------------------
-- TRANSACTION RECORDING
--------------------------------------------------

local function recordTransaction(
    player,
    transactionType,
    amount,
    description
)

    if player == nil then
        return
    end

    local modData =
        player:getModData()

    if modData.JimmoleonTransactions == nil then

        modData.JimmoleonTransactions = {}

    end

    local transaction = {

        type =
            transactionType,

        amount =
            amount,

        description =
            description,

        worldHours =
            getGameTime():getWorldAgeHours()

    }

    table.insert(
        modData.JimmoleonTransactions,
        transaction
    )


    --------------------------------------------------
    -- LOG
    --------------------------------------------------

    print("========================================")
    print("JIMOLEON: TRANSACTION RECORDED")

    print(
        "Character: " ..
        tostring(
            player:getDisplayName()
        )
    )

    print(
        "Type: " ..
        tostring(
            transactionType
        )
    )

    print(
        "Amount: " ..
        tostring(
            amount
        )
    )

    print(
        "Description: " ..
        tostring(
            description
        )
    )

    print("========================================")

end


--------------------------------------------------
-- REGISTER ACCOUNT
--------------------------------------------------

local function registerAccount(
    player
)

    if player == nil then
        return nil
    end

    local modData =
        player:getModData()


    --------------------------------------------------
    -- CREATE ACCOUNT ID
    --------------------------------------------------

    if modData.JimmoleonAccountID == nil then

        modData.JimmoleonAccountID =
            generateUniqueAccountID()

    end


    --------------------------------------------------
    -- MAKE SURE LOCAL DATA EXISTS
    --------------------------------------------------

    if modData.JimmoleonBalance == nil then
        modData.JimmoleonBalance = 0
    end

    if modData.JimmoleonTransactions == nil then

        modData.JimmoleonTransactions = {}

    end


    --------------------------------------------------
    -- GET REGISTRY
    --------------------------------------------------

    local registry =
        getAccountRegistry()

    local accountID =
        modData.JimmoleonAccountID

    local account =
        registry.Accounts[accountID]


    --------------------------------------------------
    -- CREATE ACCOUNT
    --------------------------------------------------

    if account == nil then

        registry.Accounts[accountID] = {

            characterName =
                player:getDisplayName(),

            balance =
                modData.JimmoleonBalance,

            pendingTransactions = {}

        }

        account =
            registry.Accounts[accountID]

    else

        account.characterName =
            player:getDisplayName()

    end


    --------------------------------------------------
    -- REGISTRY IS SOURCE OF TRUTH
    --------------------------------------------------

    modData.JimmoleonBalance =
        tonumber(
            account.balance
        ) or 0


    --------------------------------------------------
    -- MAKE SURE PENDING LIST EXISTS
    --------------------------------------------------

    if account.pendingTransactions == nil then

        account.pendingTransactions = {}

    end


    --------------------------------------------------
    -- PROCESS PENDING TRANSACTIONS
    --------------------------------------------------

    local pendingCount =
        #account.pendingTransactions


    if pendingCount > 0 then

        for _, pending in ipairs(
            account.pendingTransactions
        ) do

            recordTransaction(
                player,
                pending.type,
                pending.amount,
                pending.description
            )

        end


        --------------------------------------------------
        -- CLEAR PENDING TRANSACTIONS
        --------------------------------------------------

        account.pendingTransactions = {}

    end


    return accountID

end


--------------------------------------------------
-- VALUABLE VALUES
--------------------------------------------------

local valuableValues = {

    ["Base.Money"] = {
        value = 1,
        name = "Cash"
    },

    ["Base.SilverCoin"] = {
        value = 25,
        name = "Silver Coin"
    },

    ["Base.GoldCoin"] = {
        value = 100,
        name = "Gold Coin"
    },

    ["Base.SilverBar"] = {
        value = 250,
        name = "Silver Ingot"
    },

    ["Base.GoldBar"] = {
        value = 1000,
        name = "Gold Ingot"
    },

    ["Base.Diamond"] = {
        value = 500,
        name = "Diamond"
    },

    ["Base.Ruby"] = {
        value = 500,
        name = "Ruby"
    },

    ["Base.Sapphire"] = {
        value = 500,
        name = "Sapphire"
    },

    ["Base.Emerald"] = {
        value = 500,
        name = "Emerald"
    }

}


--------------------------------------------------
-- PLAYER MESSAGE
--------------------------------------------------

local function showMessage(
    player,
    message
)

    if player == nil then
        return
    end

    player:setHaloNote(
        message,
        0,
        1,
        0,
        300
    )

end


--------------------------------------------------
-- INITIALIZE PLAYER DATA
--------------------------------------------------

local function initializePlayerData(
    player
)

    if player == nil then
        return
    end

    local accountID =
        registerAccount(
            player
        )

    local modData =
        player:getModData()


    --------------------------------------------------
    -- BALANCE
    --------------------------------------------------

    if modData.JimmoleonBalance == nil then

        modData.JimmoleonBalance = 0

    end


    --------------------------------------------------
    -- TRANSACTIONS
    --------------------------------------------------

    if modData.JimmoleonTransactions == nil then

        modData.JimmoleonTransactions = {}

    end


    return accountID

end


--------------------------------------------------
-- PLAYER LOGIN
--------------------------------------------------

local function playerStarted(
    playerNum,
    player
)

    if player == nil then
        return
    end


    --------------------------------------------------
    -- INITIALIZE ACCOUNT
    --------------------------------------------------

    initializePlayerData(
        player
    )


    --------------------------------------------------
    -- SESSION
    --------------------------------------------------

    local currentWorldHours =
        getGameTime():getWorldAgeHours()

    sessionData[playerNum] = {

        player =
            player,

        characterName =
            player:getDisplayName(),

        startHour =
            currentWorldHours

    }


    --------------------------------------------------
    -- MESSAGE
    --------------------------------------------------

    showMessage(
        player,
        "Session Started"
    )

end


--------------------------------------------------
-- PAYCHECK
--------------------------------------------------

local function checkPlaytime()

    local settings =
        getPaycheckSettings()

    if settings.PaycheckEnabled ~= true then
        return
    end

    local currentWorldHours =
        getGameTime():getWorldAgeHours()


    for playerNum, data in pairs(
        sessionData
    ) do

        local player =
            data.player

        if player ~= nil then

            local hoursPlayed =
                currentWorldHours -
                data.startHour


            if hoursPlayed >=
                settings.PaycheckIntervalHours
            then

                local rewardsEarned =
                    math.floor(
                        hoursPlayed /
                        settings.PaycheckIntervalHours
                    )

                local amountEarned =
                    rewardsEarned *
                    settings.PaycheckAmount

                local modData =
                    player:getModData()


                --------------------------------------------------
                -- BALANCE
                --------------------------------------------------

                if modData.JimmoleonBalance == nil then

                    modData.JimmoleonBalance = 0

                end

                modData.JimmoleonBalance =
                    modData.JimmoleonBalance +
                    amountEarned


                --------------------------------------------------
                -- UPDATE ACCOUNT REGISTRY
                --------------------------------------------------

                local accountID =
                    modData.JimmoleonAccountID

                local account =
                    getAccountByID(
                        accountID
                    )

                if account ~= nil then

                    account.balance =
                        modData.JimmoleonBalance

                end


                --------------------------------------------------
                -- RECORD
                --------------------------------------------------

                recordTransaction(
                    player,
                    "DEPOSIT",
                    amountEarned,
                    "Playtime Paycheck"
                )


                data.startHour =
                    currentWorldHours


                showMessage(
                    player,
                    "Paycheck Earned"
                )

            end

        end

    end

end


--------------------------------------------------
-- GENERIC VALUABLE DEPOSIT
--------------------------------------------------

local function depositValuable(
    player,
    itemType,
    requestedAmount
)

    if player == nil then
        return
    end

    if itemType == nil then
        return
    end


    --------------------------------------------------
    -- ITEM
    --------------------------------------------------

    itemType =
        tostring(
            itemType
        )

    local valuable =
        valuableValues[itemType]


    if valuable == nil then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "DepositResult",
            {
                success = false,

                message =
                    "This item is not accepted."
            }
        )

        return

    end


    --------------------------------------------------
    -- AMOUNT
    --------------------------------------------------

    local amount =
        tonumber(
            requestedAmount
        )

    if amount == nil then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "DepositResult",
            {
                success = false,

                message =
                    "Enter a valid amount."
            }
        )

        return

    end


    amount =
        math.floor(
            amount
        )


    if amount <= 0 then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "DepositResult",
            {
                success = false,

                message =
                    "Enter an amount greater than 0."
            }
        )

        return

    end


    --------------------------------------------------
    -- INVENTORY
    --------------------------------------------------

    local inventory =
        player:getInventory()

    local itemCount =
        inventory:getItemCount(
            itemType
        )


    if amount > itemCount then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "DepositResult",
            {
                success = false,

                message =
                    "You only have " ..
                    tostring(
                        itemCount
                    ) ..
                    " " ..
                    tostring(
                        valuable.name
                    ) ..
                    "."
            }
        )

        return

    end


    --------------------------------------------------
    -- REMOVE ITEMS
    --------------------------------------------------

    for i = 1, amount do

        local item =
            inventory:getItemFromType(
                itemType
            )


        if item == nil then

            sendServerCommand(
                player,
                "JimmoleonEconomy",
                "DepositResult",
                {
                    success = false,

                    message =
                        "The deposit failed."
                }
            )

            return

        end


        inventory:Remove(
            item
        )

        sendRemoveItemFromContainer(
            inventory,
            item
        )

    end


    --------------------------------------------------
    -- CALCULATE JIMOLEONS
    --------------------------------------------------

    local jimoleonsEarned =
        amount *
        valuable.value

    local modData =
        player:getModData()


    if modData.JimmoleonBalance == nil then

        modData.JimmoleonBalance = 0

    end


    modData.JimmoleonBalance =
        modData.JimmoleonBalance +
        jimoleonsEarned


    --------------------------------------------------
    -- UPDATE REGISTRY
    --------------------------------------------------

    local accountID =
        modData.JimmoleonAccountID

    local account =
        getAccountByID(
            accountID
        )


    if account ~= nil then

        account.balance =
            modData.JimmoleonBalance

    end


    --------------------------------------------------
    -- TRANSACTION
    --------------------------------------------------

    recordTransaction(
        player,
        "DEPOSIT",
        jimoleonsEarned,
        valuable.name ..
        " Deposit"
    )


    --------------------------------------------------
    -- RESULT
    --------------------------------------------------

    sendServerCommand(
        player,
        "JimmoleonEconomy",
        "DepositResult",
        {
            success = true,

            amount =
                jimoleonsEarned,

            newBalance =
                modData.JimmoleonBalance,

            message =
                valuable.name ..
                " deposited."
        }
    )

end


--------------------------------------------------
-- TRANSFER JIMOLEONS
--------------------------------------------------

local function transferJimoleons(
    player,
    recipientAccountID,
    requestedAmount
)

    if player == nil then
        return
    end


    --------------------------------------------------
    -- RECIPIENT ACCOUNT ID
    --------------------------------------------------

    if recipientAccountID == nil then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "TransferResult",
            {
                success = false,

                message =
                    "Enter a recipient account ID."
            }
        )

        return

    end


    recipientAccountID =
        tostring(
            recipientAccountID
        )

    recipientAccountID =
        string.upper(
            recipientAccountID
        )


    --------------------------------------------------
    -- AMOUNT
    --------------------------------------------------

    local amount =
        tonumber(
            requestedAmount
        )


    if amount == nil then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "TransferResult",
            {
                success = false,

                message =
                    "Enter a valid amount."
            }
        )

        return

    end


    amount =
        math.floor(
            amount
        )


    if amount <= 0 then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "TransferResult",
            {
                success = false,

                message =
                    "Transfer amount must be greater than 0."
            }
        )

        return

    end


    --------------------------------------------------
    -- SENDER
    --------------------------------------------------

    local senderModData =
        player:getModData()

    local senderAccountID =
        senderModData.JimmoleonAccountID

    local senderAccount =
        getAccountByID(
            senderAccountID
        )


    if senderAccount == nil then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "TransferResult",
            {
                success = false,

                message =
                    "Your account could not be found."
            }
        )

        return

    end


    --------------------------------------------------
    -- PREVENT SELF TRANSFER
    --------------------------------------------------

    if recipientAccountID ==
        tostring(
            senderAccountID
        )
    then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "TransferResult",
            {
                success = false,

                message =
                    "You cannot transfer to yourself."
            }
        )

        return

    end


    --------------------------------------------------
    -- RECIPIENT
    --------------------------------------------------

    local recipientAccount =
        getAccountByID(
            recipientAccountID
        )


    if recipientAccount == nil then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "TransferResult",
            {
                success = false,

                message =
                    "That account does not exist."
            }
        )

        return

    end


    --------------------------------------------------
    -- CHECK SENDER BALANCE
    --------------------------------------------------

    if senderModData.JimmoleonBalance == nil then

        senderModData.JimmoleonBalance = 0

    end


    senderAccount.balance =
        senderModData.JimmoleonBalance


    if amount >
        senderModData.JimmoleonBalance
    then

        sendServerCommand(
            player,
            "JimmoleonEconomy",
            "TransferResult",
            {
                success = false,

                message =
                    "You do not have enough Jimoleons."
            }
        )

        return

    end


    --------------------------------------------------
    -- REMOVE FROM SENDER
    --------------------------------------------------

    senderModData.JimmoleonBalance =
        senderModData.JimmoleonBalance -
        amount

    senderAccount.balance =
        senderModData.JimmoleonBalance


    --------------------------------------------------
    -- ADD TO RECIPIENT
    --------------------------------------------------

    recipientAccount.balance =
        tonumber(
            recipientAccount.balance
        ) or 0

    recipientAccount.balance =
        recipientAccount.balance +
        amount


    --------------------------------------------------
    -- SENDER TRANSACTION
    --------------------------------------------------

    recordTransaction(
        player,
        "TRANSFER",
        -amount,
        "Transfer to " ..
        tostring(
            recipientAccount.characterName
        )
    )


    --------------------------------------------------
    -- ONLINE RECIPIENT CHECK
    --------------------------------------------------

    local recipientOnline = false


    for playerNum, session in pairs(
        sessionData
    ) do

        local recipientPlayer =
            session.player


        if recipientPlayer ~= nil then

            local recipientModData =
                recipientPlayer:getModData()


            if recipientModData.JimmoleonAccountID ==
                recipientAccountID
            then

                recipientOnline = true


                --------------------------------------------------
                -- UPDATE ONLINE BALANCE
                --------------------------------------------------

                recipientModData.JimmoleonBalance =
                    recipientAccount.balance


                --------------------------------------------------
                -- RECIPIENT TRANSACTION
                --------------------------------------------------

                recordTransaction(
                    recipientPlayer,
                    "TRANSFER",
                    amount,
                    "Transfer from " ..
                    tostring(
                        player:getDisplayName()
                    )
                )


                --------------------------------------------------
                -- RECIPIENT MESSAGE
                --------------------------------------------------

                sendServerCommand(
                    recipientPlayer,
                    "JimmoleonEconomy",
                    "TransferReceived",
                    {
                        amount =
                            amount,

                        newBalance =
                            recipientAccount.balance,

                        senderName =
                            player:getDisplayName()
                    }
                )


                break

            end

        end

    end


    --------------------------------------------------
    -- OFFLINE RECIPIENT
    --------------------------------------------------

    if recipientOnline == false then


        if recipientAccount.pendingTransactions == nil then

            recipientAccount.pendingTransactions = {}

        end


        table.insert(
            recipientAccount.pendingTransactions,
            {

                type =
                    "TRANSFER",

                amount =
                    amount,

                description =
                    "Transfer from " ..
                    tostring(
                        player:getDisplayName()
                    )

            }
        )

    end


    --------------------------------------------------
    -- SENDER RESULT
    --------------------------------------------------

    sendServerCommand(
        player,
        "JimmoleonEconomy",
        "TransferResult",
        {
            success = true,

            amount =
                amount,

            newBalance =
                senderModData.JimmoleonBalance,

            recipientName =
                recipientAccount.characterName,

            recipientAccountID =
                recipientAccountID,

            message =
                "Transfer successful."
        }
    )

end


--------------------------------------------------
-- CLIENT COMMANDS
--------------------------------------------------

local function onClientCommand(
    module,
    command,
    player,
    args
)

    if module ~=
        "JimmoleonEconomy"
    then

        return

    end


    if player == nil then
        return
    end


    if args == nil then

        args = {}

    end


    --------------------------------------------------
    -- DEPOSIT
    --------------------------------------------------

    if command ==
        "DepositValuable"
    then

        depositValuable(
            player,
            args.itemType,
            args.amount
        )

        return

    end


    --------------------------------------------------
    -- TRANSFER
    --------------------------------------------------

    if command ==
        "TransferJimoleons"
    then

        transferJimoleons(
            player,
            args.recipientAccountID,
            args.amount
        )

        return

    end

end


--------------------------------------------------
-- EVENTS
--------------------------------------------------

Events.OnCreatePlayer.Add(
    playerStarted
)

Events.EveryOneMinute.Add(
    checkPlaytime
)

Events.OnClientCommand.Add(
    onClientCommand
)