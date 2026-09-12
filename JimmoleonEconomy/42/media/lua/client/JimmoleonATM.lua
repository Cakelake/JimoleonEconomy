print("========================================")
print("JIMOLEON ATM SYSTEM")
print("========================================")


--------------------------------------------------
-- GLYTCH3R ATM TILE NAMES
--------------------------------------------------

local glytch3rATMTiles = {

    ["location_business_bank_01_64"] = true,
    ["location_business_bank_01_65"] = true,
    ["location_business_bank_01_66"] = true,
    ["location_business_bank_01_67"] = true

}


--------------------------------------------------
-- GET ATM SPRITE NAME
--------------------------------------------------

local function getSpriteName(
    worldObject
)

    if worldObject == nil then
        return nil
    end

    local sprite =
        worldObject:getSprite()

    if sprite == nil then
        return nil
    end

    return sprite:getName()

end


--------------------------------------------------
-- IS SUPPORTED GLYTCH3R ATM
--------------------------------------------------

local function isSupportedGlytch3rATM(
    worldObject
)

    if worldObject == nil then
        return false
    end


    --------------------------------------------------
    -- ALREADY CONVERTED GLYTCH3R ATM
    --------------------------------------------------

    if FunctionalATMs4 ~= nil
    and FunctionalATMs4.isFunctionalATM ~= nil
    then

        if FunctionalATMs4.isFunctionalATM(
            worldObject
        ) then

            return true

        end

    end


    --------------------------------------------------
    -- SUPPORTED ATM TILE
    --------------------------------------------------

    local spriteName =
        getSpriteName(
            worldObject
        )

    if spriteName == nil then
        return false
    end

    return glytch3rATMTiles[spriteName] == true

end


--------------------------------------------------
-- OPEN BANK
--------------------------------------------------

local function openBank(
    worldObject,
    playerNum
)

    local player =
        getSpecificPlayer(
            playerNum
        )

    if player == nil then

        print(
            "JIMOLEON ERROR: Player not found."
        )

        return

    end


    --------------------------------------------------
    -- MAKE SURE GLYTCH3R EXISTS
    --------------------------------------------------

    if FunctionalATMs4 == nil then

        player:setHaloNote(
            "Functional ATMs 4 is required.",
            1,
            0,
            0,
            300
        )

        print(
            "JIMOLEON ERROR: Functional_ATMs4 is not loaded."
        )

        return

    end


    --------------------------------------------------
    -- CONVERT / PREPARE ATM
    --------------------------------------------------

    local atm =
        worldObject


    if FunctionalATMs4.isFunctionalATM ~= nil then

        if not FunctionalATMs4.isFunctionalATM(
            worldObject
        ) then

            local spriteName =
                getSpriteName(
                    worldObject
                )

            if spriteName == nil
            or glytch3rATMTiles[spriteName] ~= true
            then

                print(
                    "JIMOLEON ERROR: Unsupported ATM."
                )

                return

            end


            if FunctionalATMs4.doConvert == nil then

                print(
                    "JIMOLEON ERROR: Glytch3r ATM conversion unavailable."
                )

                return

            end


            local container =
                worldObject:getContainer()


            atm =
                FunctionalATMs4.doConvert(
                    worldObject,
                    spriteName,
                    container
                )


            if atm == nil then

                print(
                    "JIMOLEON ERROR: ATM conversion failed."
                )

                return

            end

        end

    end


    --------------------------------------------------
    -- POWER CHECK
    --------------------------------------------------

    if FunctionalATMs4.isPowerOff ~= nil then

        if FunctionalATMs4.isPowerOff(
            atm
        ) then

            player:setHaloNote(
                "ATM requires power.",
                1,
                0,
                0,
                300
            )

            return

        end

    end


    --------------------------------------------------
    -- OPEN JIMOLEON BANK
    --------------------------------------------------

    if JimmoleonBankUI ~= nil then

        JimmoleonBankUI.open(
            player
        )

    else

        print(
            "JIMOLEON ERROR: Bank UI not loaded."
        )

    end

end


--------------------------------------------------
-- CONTEXT MENU
--------------------------------------------------

local function onFillWorldObjectContextMenu(
    playerNum,
    context,
    worldObjects,
    test
)

    if test then
        return
    end


    --------------------------------------------------
    -- MAKE SURE GLYTCH3R IS LOADED
    --------------------------------------------------

    if FunctionalATMs4 == nil then
        return
    end


    --------------------------------------------------
    -- FIND SUPPORTED ATM
    --------------------------------------------------

    for _, worldObject in ipairs(
        worldObjects
    ) do

        if isSupportedGlytch3rATM(
            worldObject
        ) then


            --------------------------------------------------
            -- ADD JIMOLEON BANK
            --------------------------------------------------

            local option =
                context:addOptionOnTop(
                    "Jimmoleon Bank",
                    worldObject,
                    openBank,
                    playerNum
                )


            --------------------------------------------------
            -- GLYTCH3R ATM ICON
            --------------------------------------------------

            local atmIcon =
                getTexture(
                    "media/textures/ui/atm4.png"
                )

            if atmIcon ~= nil then

                option.iconTexture =
                    atmIcon

            end


            --------------------------------------------------
            -- POWER STATUS
            --------------------------------------------------

            if FunctionalATMs4.isPowerOff ~= nil then

                if FunctionalATMs4.isPowerOff(
                    worldObject
                ) then

                    option.notAvailable =
                        true

                end

            end


            break

        end

    end

end


--------------------------------------------------
-- REGISTER EVENT
--------------------------------------------------

Events.OnFillWorldObjectContextMenu.Add(
    onFillWorldObjectContextMenu
)