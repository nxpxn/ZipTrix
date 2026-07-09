local addonName, ns = ...

-- Localize globals for performance
local C_Map = C_Map
local GetSubZoneText = GetSubZoneText
local GetBindLocation = GetBindLocation
local C_QuestLog = C_QuestLog
local GetAchievementInfo = GetAchievementInfo
local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo
local table = table
local string = string
local ipairs = ipairs
local type = type
-- Data source for the "Everything Else" page in the Gateway panel
function ns.GetEverythingElseEntries()
    local sections = {
    }

    -- Logic to detect Secret Seat of Knowledge
    -- We check if the subzone is "Seat of Knowledge" but NOT in the Vale of Eternal Blossoms (Map 390)
    local mapID = C_Map.GetBestMapForUnit("player")
    local subZone = GetSubZoneText()
    local inSecretSeat = (subZone == "Seat of Knowledge" and mapID ~= 390)

    local bindLoc = GetBindLocation()
    local isHearthSet = (bindLoc == "Seat of Knowledge")

    if inSecretSeat or isHearthSet then
        local mindSeekerSection = {
            title = "Mind-Seeker",
            items = {
                { text = "Completing 17 secrets will gain the Mind-Seeker Feat of Strength.", isKnown = true, iconID = false },
                { text = "Speak to Anakron to claim this feat.", isKnown = true, iconID = false },
                { text = "Speak with Jeremy Feasel to make this Inn your home.", isKnown = true, iconID = false },
            },
            isCollapsible = true
        }
        table.insert(sections, mindSeekerSection)

        if isHearthSet then
            local totalRecords = 0
            -- Dropdowns for secrets
            local function Add(title, header, url, tags, content)
                totalRecords = totalRecords + 1
                local items = {}
                local progressFunc = nil

                -- Extract progress script from tags if present
                if tags then
                    for _, t in ipairs(tags) do
                        if type(t) == "table" and t.text == "Check Progress" and t.script then
                            -- Convert /run script to a tooltip-friendly function if possible
                            -- This is a simplified parser for the specific format used in records.md
                            local scriptBody = t.script:gsub("^/run%s+", "")
                            progressFunc = function()
                                -- We can't easily execute the print loop to a tooltip, 
                                -- so we'll define custom handlers for known secrets below.
                                return "Right-click to print progress to chat."
                            end
                        end
                    end
                end

                -- Header
                table.insert(items, { text = header, type = "subheader", isKnown = true })
                
                -- URL Pill
                if url then
                    table.insert(items, { text = url, type = "url", url = url, isKnown = true })
                end
                
                -- Tags Row
                if tags and #tags > 0 then
                    local row = { type = "tags_row", items = {} }
                    for _, t in ipairs(tags) do
                        if type(t) == "table" then
                            if t.text ~= "Check Progress" then
                                table.insert(row.items, { text = t.text, type = "script", script = t.script })
                            else
                                -- Keep "Check Progress" as a clickable script pill too, for chat output
                                table.insert(row.items, { text = t.text, type = "script", script = t.script })
                            end
                        else
                            table.insert(row.items, { text = t, type = "tag" })
                        end
                    end
                    if #row.items > 0 then
                        table.insert(items, row)
                    end
                end
                
                -- Body Content
                for _, c in ipairs(content) do
                    local item = { text = c.text, isKnown = true }
                    if c.way then
                        item.type = "waypoint"
                        item.macroText = c.way
                    elseif c.script then
                        item.type = "script" -- Inline script in body
                        item.script = c.script
                    else
                        item.type = "body"
                        -- Detect bullet points
                        if c.text:match("^%s*%-") then
                            item.isBullet = true
                        end
                    end
                    table.insert(items, item)
                end
                
                table.insert(sections, { 
                    title = title, 
                    items = items, 
                    isCollapsible = true,
                    progressScript = progressFunc -- Pass function for tooltip
                })
            end

            Add("Record of Lost Obsidian Treasures", "Lost Obsidian Cache", "https://warcraft-secrets.com/guides/lost-obsidian-cache", nil, {
                { text = "Sour Apples", way = "/way #2022 43.7 71.7 Sour Apples" },
                { text = "Blacktalon Shadowclaw", way = "/way #2022 43.2 67.2 Blacktalon Shadowclaw" },
                { text = " " },
                { text = "Lost Cache Key", way = "/way #2022 43.6 49.6 Lost Cache Key" },
                { text = "Lost Obsidian Cache", way = "/way #2022 44.6 70.1 Lost Obsidian Cache" },
            })

            Add("Record of Drust Rituals", "Wicker Pup", "https://warcraft-secrets.com/guides/secret-battle-pets#Wicker_Pup", nil, {
                { text = "Wicker Pup is a battle pet that is created by combining several items looted from treasure chests in Drustvar." },
                { text = " " },
                { text = "- Bundle of Wicker Sticks - Looted from Hexed Chest" },
                { text = "- Miniature Stag Skull - Looted from Ensorcelled Chest" },
                { text = "- Wolf Pup Spine - Looted from Enchanted Chest" },
                { text = "- Spooky Incantation - Looted from Bespelled Chest" },
                { text = " " },
                { text = "Hexed Chest", way = "/way #896 18.5 51.3 Hexed Chest" },
                { text = "Ensorcelled Chest", way = "/way #896 67.6 73.6 Ensorcelled Chest" },
                { text = "Enchanted Chest", way = "/way #896 25.6 24.0 Enchanted Chest" },
                { text = "Bespelled Chest", way = "/way #896 55.4 51.5 Bespelled Chest" },
            })

            Add("Record of Glimmering Hope", "Glimr", "https://warcraft-secrets.com/guides/glimr", nil, {
                { text = "Glimmerfin Scout", way = "/way #116 18.4 88.2 Glimmerfin Scout" },
                { text = "King Mrgl-Mrgl", way = "/way #114 43.5 13.9 King Mrgl-Mrgl" },
                { text = "Glimmergut", way = "/way #116 17.8 93.2 Glimmergut" },
                { text = "Horker", way = "/way #116 10.3 85.1 Horker" },
                { text = "Giant Pearl", way = "/way #116 22.3 93.0 Giant Pearl" },
                { text = "Trainer Grrglin", way = "/way #116 21.4 88.7 Trainer Grrglin" },
                { text = "Great Mua'kin", way = "/way #116 8.8 91.1 Great Mua'kin" },
            })

            Add("Record of Rumors", "Tobias", "https://warcraft-secrets.com/guides/secrets-of-azeroth-world-event", nil, {})

            Add("Record of Visions of Void", "Voidfire Deathcycle", "https://warcraft-secrets.com/guides/voidfire-deathcycle", nil, {})

            Add("Record of Indecipherable Mo'arg Technology", "Incognitro, the Indecipherable Felcycle", "https://warcraft-secrets.com/guides/incognitro-the-indecipherable-felcycle", nil, {})

            Add("Record of Necromantic Knowledge", "Leaders of Scholomance", "https://warcraft-secrets.com/guides/memory-of-scholomance", nil, {})

            Add("Record of the Secrets Behind You", "Slime Serpent", "https://warcraft-secrets.com/guides/slime-serpent", nil, {})

            Add("Record of Abyssal Blood", "Nazjatar Blood Serpent", "https://warcraft-secrets.com/guides/nazjatar-blood-serpent", nil, {})

            Add("Record of Collectible Courage", "Courage", "https://warcraft-secrets.com/guides/courage", nil, {})

            Add("Record of Drak'thul's Madness", "Kosumoth the Hungering", "https://warcraft-secrets.com/guides/kosumoth-the-hungering", nil, {})

            Add("Record of Taming the Maw", "Bound Shadehound", nil, nil, {})

            Add("Record of the Riddler", "Riddler's Mind-Worm", "https://warcraft-secrets.com/guides/riddlers-mind-worm", nil, {})

            Add("Record of Rising Ashes", "Phoenix Wishwing", "https://warcraft-secrets.com/guides/phoenix-wishwing", nil, {})

            Add("Record of the Caverns of Consumption", "Sun Darter Hatchling", "https://warcraft-secrets.com/guides/sun-darter-hatchling", nil, {})

            Add("Trophy of Revelations", "Mind-Seeker", "https://warcraft-secrets.com/guides/mind-seeker", nil, {})

            Add("Record of Collaborative Cogitation", "Enlightened Hearthstone", "https://warcraft-secrets.com/guides/enlightened-hearthstone", nil, {
                { text = "- Gather 6 players who already have the toy Sphere of Enlightened Cogitation (chance to drop from The Enlightened paragon chest)" },
                { text = "- Go to the following locations beneath the Forge of Afterlives in Zereth Mortis." },
                { text = "South Pillar", way = "/way 47.5 57.0 South Pillar" },
                { text = "Southwest Pillar", way = "/way 45.5 55.3 Southwest Pillar" },
                { text = "Northwest Pillar", way = "/way 45.5 51.8 Northwest Pillar" },
                { text = "North Pillar", way = "/way 47.5 50.0 North Pillar" },
                { text = "Northeast Pillar", way = "/way 49.6 51.7 Northeast Pillar" },
                { text = "Southeast Pillar", way = "/way 49.6 55.3 Southeast Pillar" },
                { text = "- Use /sit emote and use the sphere toy" },
                { text = "Zone wide emote will appear \"The Ponderer's Portal has opened\" anyone close can collect for a few minutes." },
            })

            Add("Record of Ephemeral Crystals", "Long-Forgotten Hippogryph", "https://warcraft-secrets.com/guides/long-forgotten-hippogryph", nil, {})

            Add("Record of Buried Treasure", "Wan'be's Buried Goods", "https://warcraft-secrets.com/guides/treasure-hunt-wanbes-buried-goods", nil, {})

            Add("Record of a Friend in the Darkness", "Uuna's Secret Storyline", "https://warcraft-secrets.com/guides/uuna", nil, {})

            Add("Record of Cartel Cyphers", "Xy Trustee's Gearglider", "https://warcraft-secrets.com/guides/xy-trustees-gearglider", nil, {})

            -- Custom Progress Function for Baa'l
            local function BaalProgress()
                local ids = {52819,52809,52810,52818,52817,52816,52815,52814,52813,52812,53632,53633,53634,52827,52828,52829}
                local names = {"Note","Pebble 1","Pebble 2","Pebble 3","Pebble 4","Pebble 5","Pebble 6","Pebble 7","Pebble 8","Pebble 9","Pebble 10","Pebble 11","Pebble 12","Pebble 13","Baa'l","Seek Knowledge"}
                local lines = {}
                for i, id in ipairs(ids) do
                    local done = C_QuestLog.IsQuestFlaggedCompleted(id)
                    local color = done and "|cff00ff00" or "|cffff0000"
                    table.insert(lines, color .. names[i] .. ": " .. (done and "Done" or "Not Done") .. "|r")
                end
                return table.concat(lines, "\n")
            end

            Add("Record of Omniously Ordinary Pebbles", "Baa'l", "https://warcraft-secrets.com/guides/baal", {
                "Pet Battle", "Uuna",
                { text = "Check Progress", script = "/run local n,t={\"Note\",1,2,3,4,5,6,7,8,9,10,11,12,13,\"Baa'l\",\"Seek Knowledge\"},{52819,52809,52810,52818,52817,52816,52815,52814,52813,52812,53632,53633,53634,52827,52828,52829}for i=1,#n do print(n[i],\"=\",C_QuestLog.IsQuestFlaggedCompleted(t[i]))end" }
            }, {
                { text = " " },
                { text = "Conspicuous Note - Nazmir", way = "/way #863 51.8 59.1 Conspicuous Note" },
                { text = "Pebble 1 - Broken Shore", way = "/way #646 37.5 71.6 First Pebble - on the table" },
                { text = "Pebble 2 - Boralus (Cave Entrance)", way = "/way #1161 49.4 40.0 Cave Entrance - walk through the net" },
                { text = "Pebble 2 - Boralus (Pebble)", way = "/way #1161 44.7 38.5 Second Pebble - on the ground" },
                { text = "Pebble 3 - Zuldazar (Cave Entrance)", way = "/way #862 31.5 36.0 Cave Entrance" },
                { text = "Pebble 3 - Zuldazar (Pebble)", way = "/way #862 31.9 35.3 Third Pebble - at the base of a tree" },
                { text = "Pebble 4 - Drustvar (Cave Entrance)", way = "/way #896 35.0 54.9 Cave Entrance" },
                { text = "Pebble 4 - Drustvar (Pebble)", way = "/way #896 36.3 53.8 Fourth Pebble - in the effigy's head" },
                { text = "Pebble 5 - Voldun (Cave Entrance)", way = "/way #864 63.1 21.3 Cave Entrance" },
                { text = "Pebble 5 - Voldun (Pebble)", way = "/way #864 63.1 21.6 Fifth Pebble" },
                { text = "Pebble 6 - Stormsong Valley (Cave Entrance)", way = "/way #942 68.4 10.9 Cave Entrance" },
                { text = "Pebble 6 - Stormsong Valley (Pebble)", way = "/way #942 67.9 12.9 Sixth Pebble - on a wheelbarrow" },
                { text = "Pebble 7 - South Seas", way = "/way #875 54.5 7.3 Seventh Pebble - on the skull vitral" },
                { text = "Pebble 8 - Boralus (Basement Entrance)", way = "/way #1161 37.6 80.3 Basement Entrance" },
                { text = "Pebble 8 - Boralus (Pebble)", way = "/way #1161 37.3 79.8 Eight Pebble - behind the keg and the crates" },
                { text = "Pebble 9 - Drustvar (Path Start)", way = "/way #896 18.3 7.4 Path Start" },
                { text = "Pebble 9 - Drustvar (Pebble)", way = "/way #896 17.2 6.5 Ninth Pebble - near the cave's entrance" },
                { text = "Pebble 10 - Tirigarde Sound (Cave Entrance)", way = "/way #895 75.4 70.6 Cave Entrance" },
                { text = "Pebble 10 - Tirigarde Sound (Pebble)", way = "/way #895 74.3 70.9 Tenth Pebble - next to a carcass of meat" },
                { text = "Pebble 11 - Tiragarde Sound (Cave Entrance)", way = "/way #895 80.1 19.1 Cave Entrance" },
                { text = "Pebble 11 - Tiragarde Sound (Pebble)", way = "/way #895 79.6 18.0 Eleventh Pebble - under the scroll" },
                { text = "Pebble 12 - Boralus (Underwater Cave Entrance)", way = "/way #1161 10.0 82.8 Underwater Cave Entrance" },
                { text = "Pebble 12 - Boralus (Pebble)", way = "/way #895 59.7 41.8 Twelfth Pebble - under the seaweed" },
                { text = "Pebble 13 - Vol'dun (Underwater Cave)", way = "/way #875 55.7 -10.2 Underwater Cave" },
                { text = "Kurgthuk the Merciless in Frostfire Ridge", way = "/way #525 62.2 22.8 Baa'l (Frostfire Ridge, Draenor)" },
            })
            
            -- Inject custom progress function for Baa'l
            sections[#sections].progressScript = BaalProgress

            Add("Record of Time Wasted", "Waist of Time", "https://warcraft-secrets.com/guides/waist-of-time", {
                "Baa'l", "Uuna",
                { text = "Check Progress", script = "/run local n,t={\"Note\",1,2,3,4,5,6,7,8,9,10,11,12,13,\"Baa'l\",\"Seek Knowledge\"},{52819,52809,52810,52818,52817,52816,52815,52814,52813,52812,53632,53633,53634,52827,52828,52829}for i=1,#n do print(n[i],\"=\",C_QuestLog.IsQuestFlaggedCompleted(t[i]))end" },
                { text = "Hidden Objects", script = "/run local quests={52830,52831,52898,52899,52900,52901,52902,52903,52904,52905,52906,52907,52908,52909,52910,52911,52912,52913,52914,52915} for i,questID in ipairs(quests) do print(\"Hidden Object \"..i, C_QuestLog.IsQuestFlaggedCompleted(questID)) end" },
                { text = "Grimmy's Progress", script = "/run local n={\"List of Friends\",\"Secrets\",\"List of Enemies\",\"Secrets Revealed\",\"Favorite Recipe\",\"Reward\",\"Waist of Time\"} local t=52916 for i,s in ipairs(n) do print(\"Grimmy's \"..s..\":\", C_QuestLog.IsQuestFlaggedCompleted(t+i-1)) end" }
            }, {
                { text = "Craft or Purchase at Auction house: Windwool Hood, Deathsilk Shoulders, Netherweave Tunic, Frostwoven Leggings" },
                { text = "Purchase from auction house or vendors: Formula: Enchant Ring - Striking, Punctured Pelt, Rough Wooden Staff, Proximo's Rudius" },
                { text = " " },
                { text = "1. Lit Orb", way = "/way #542 35.5 32 Lit Orb (Spires of Arak)" },
                { text = "2. Small Red Strange Seed", way = "/way #13 42.32 75.24 Small Red Strange Seed (Eastern Kingdoms Map)" },
                { text = "3. Tiny Frog", way = "/way #542 53.5 10.7 Tiny Frog (Spires of Arak)" },
                { text = "4. Brittle Bone", way = "/way #105 33.65 58.2 Brittle Bone (Blade's Edge Mountains)" },
                { text = "5. Misplaced Candle", way = "/way #542 68 41 Misplaced Candle (Spires of Arak)" },
                { text = "6. Odd Cup", way = "/way #539 45.7 26.2 Odd Cup (Shadowmoon Valley, Draenor)" },
                { text = "7. Interesting Rock", way = "/way #104 51.63 43.75 Interesting Rock (Shadowmoon Valley, Outland)" },
                { text = "8. Blooming Lily", way = "/way #51 58.05 31.56 Blooming Lily (Swamp of Sorrows)" },
                { text = "9. Pretty Flower", way = "/way #23 24.22 78.23 Pretty Flower (Eastern Plaguelands)" },
                { text = "10. Old Book", way = "/way #42 41.2 78.95 Old Book (Deadwind Pass)" },
                { text = "11. Dead Fish", way = "/way #33 77.9 44.3 Dead Fish (Blackrock Mountain)" },
                { text = "12. Scratched Board", way = "/way #47 52 62.35 Scratched Board (Duskwood)" },
                { text = "13. Lost Ring", way = "/way #25 44.6 26.4 Lost Ring (Hillsbrad Foothills)" },
                { text = "14. Spoiled Apple", way = "/way #15 90.05 37.95 Spoiled Apple (Badlands)" },
                { text = "15. Broken Tooth", way = "/way #17 36.78 27.62 Broken Tooth (Blasted Lands)" },
                { text = "16. Worn Helm", way = "/way #36 27.1 47.05 Worn Helm (Burning Steppes)" },
                { text = "17. Leafy Leaf", way = "/way #125 42.8 20.2 Leafy Leaf (Northrend Dalaran)" },
                { text = "18. Musty Cloth", way = "/way #108 40.2 72.5 Musty Cloth (Terokkar Forest)" },
                { text = "19. Broken Tablet", way = "/way #241 17.05 57.85 Broken Tablet (Twilight Highlands)" },
                { text = "20. Ashed Torch", way = "/way #69 60.8 67.8 Ashed Torch (Feralas)" },
                { text = " " },
                { text = "Please use the weblink provided above to complete Ginnys tasks." },
            })

            Add("Record of Karazhan's Kitten", "Jenafur", "https://warcraft-secrets.com/guides/jenafur", nil, {})

            Add("Record of a Slippery Find", "Otto", "https://warcraft-secrets.com/guides/otto", nil, {
                { text = "1. Get Aquatic Shades:" },
                { text = "- Farm Coins of the Isles until you have 1 Gold Coin of the Isles." },
                { text = "75 Coppper Coin = 5 Silver Coin = 1 Gold Coin of the Isles" },
                { text = "Purchase at the Great Swog" },
                { text = "The Great Swog", way = "/way #2023 82.2 73.2 The Great Swog" },
                { text = " " },
                { text = "Use Elusive Croaking Crab to spawn Sir Pinchalot in the Forbidden Reach" },
                { text = "Empty Crab Trap respawns after 5-10 minutes." },
                { text = "Empty Crab Trap 1", way = "/way #2151 23.2 66.8 Empty Crab Trap" },
                { text = "Empty Crab Trap 2", way = "/way #2151 47.8 90.9 Empty Crab Trap" },
                { text = "Empty Crab Trap 3", way = "/way #2151 70.5 41.5 Empty Crab Trap" },
                { text = " " },
                { text = "Elusive Croaking Crab - Auction House" },
                { text = "Coins can be fished, increase chances by increasing Perception:" },
                { text = "- Aqirite Fisherfriend fishing tool." },
                { text = "- Enchant Tool - Algari Perception and apply it to your fishing tool" },
                { text = "- Crystalline Phial of Perception." },
                { text = " " },
                { text = "2. Use Aquatic Shades at \"The Bubble Bath\" dive bar." },
                { text = "Head North of Obsidian Citadel." },
                { text = "The Bubble Bath", way = "/way #2022 19.6 36.5 The Bubble Bath" },
                { text = "Use shades, dive into water" },
                { text = "Stand on dance stage, debuff: Dance, Dance 'till  You're Dead" },
                { text = "After 5min debuff will expire and you will be teleported to the Hissing Grotto" },
                { text = "Interact with Empty Fish Barrel" },
                { text = " " },
                { text = "Fish the following to fill the Empty Fish Barrel." },
                { text = "100x Frigid Flow Fish: Fished from open waters around Iskaara" },
                { text = "25x Calamnitous Carp: Fished from lava flows around obsidian citadel." },
                { text = "Kingfin, the Wise Whiskerfish: Fished from open waters around Algeth'ar Academy" },
                { text = "Kingfin, the Wise Whiskerfish", way = "/way #2025 56.0 44.5 Kingfin, the Wise Whiskerfish" },
                { text = " " },
                { text = "After filling the Empty Fish Barrel, talk to Otto and complete the Way to an Otto's Heart quest to receive Otto." },
                { text = "Otto", way = "/way #2022 20.3 39.7 Otto" },
                { text = "Note: Otto will wear Aquatic Shades if your wearing Aquatic Shades." },
            })

            Add("Record of a Dominant Hand", "Hand of Nilganihmaht", nil, nil, {})

            Add("Record of Mimiron's Master Mind", "Mimiron's Jumpjets", "https://warcraft-secrets.com/guides/secrets-of-azeroth-world-event#Mimirons_Jumpjets", {"Team of 4"}, {
                { text = "First Booster Part - Jaguero Isle in the Cap of Stranglethorn" },
                { text = "Jaguero Isle", way = "/way #210 59.4 79.0 Jaguero Isle" },
                { text = "3-Players" },
                { text = "Torch of Pyrreth to light up three braziers" },
                { text = "Defeat the Enigma Ward and loot" },
                { text = " " },
                { text = "Second Booster Part - Irontree Woods in Felwood" },
                { text = "Irontree Woods", way = "/way #77 50.0 26.4 Irontree Woods" },
                { text = "4-Players" },
                { text = "Use the spell Envelope to absorb 3 other players" },
                { text = "elemental will explode and leave the second part on the ground!" },
                { text = " " },
                { text = "Third Booster Part - Dark Portal in the Blasted Land" },
                { text = "The Dark Portal", way = "/way #17 54.8 52.1 The Dark Portal" },
                { text = "2-Players min" },
                { text = "Destroy the two Legion Flak Cannon nearby" },
                { text = "Have other players protect you from attackers while you interact with the Mimiron's Booster Part. After 12 seconds, you will loot the third part!" },
                { text = " " },
                { text = "Empowered Arcane Forge" },
                { text = "Arcane Forge", way = "/way #2112 36.5 61.9 Arcane Forge" },
                { text = "Bring the 3 booster parts to the Arcane Forge in Valdrakken to create Mimiron's Jumpjets!" },
            })

            Add("Record of the Siren's Song", "Thrayir, Eyes of the Siren", "https://warcraft-secrets.com/guides/thrayir-eyes-of-the-siren", nil, {
                { text = "Note: To unlock the spell Runecaster's Eye, you must complete the Siren Isle questline A Song of Secrets." },
                { text = " " },
                { text = "Each rune can only be attained during the storm, speak to Suzie Boltwrench to enter the storm." },
                { text = "Suzie Boltwrench", way = "/way #2369 69.0 49.2 Suzie Boltwrench" },
                { text = " " },
                { text = "Cyclonic Runekey: Drop from Zek'ul and also possible to fish in surrounding waters waiting for rare to spawn." },
                { text = "Zek'ul the Shipbreaker", way = "/way #2369 33.0 73.6 Zek'ul the Shipbreaker" },
                { text = " " },
                { text = "Turbulent Runekey: Combine 3 Turbulent Fragments" },
                { text = "Dirt Pile", way = "/way #2369 38.2 51.9 Dirt Pile" },
                { text = "Runic Fragment #1", way = "/way #2369 67.2 78.8 Runic Fragment #1" },
                { text = "Spirit Scarred Cave", way = "/way #2369 50.2 42.4 Spirit Scarred Cave" },
                { text = "Runic Fragment #2", way = "/way #2369 52.6 38.6 Runic Fragment #2" },
                { text = " " },
                { text = "Whirling Runekey: Drop from Ksvir, found in the southearn room in The Forgotten Vault." },
                { text = "Cave Entrance", way = "/way #2369 44.8 22.4 Cave Entrance" },
                { text = "Singing Tablet", way = "/way #2369 50.2 15.5 Singing Tablet" },
                { text = "Ksvir the Forgotten", way = "/way #2375 39.0 75.0 Ksvir the Forgotten" },
                { text = " " },
                { text = "Torrential Runekey: Combine 7 Torrential Fragments, drops from any creature" },
                { text = "Recommended to farm Brinebound Wraiths and Kvaldir, which can be found around the northern end of the isle" },
                { text = "Brinebound Wraiths & Kvaldir", way = "/way #2369 40.0 20.0 Brinebound Wraiths & Kvaldir" },
                { text = " " },
                { text = "Thunderous Runekey: Combine 5 Thunderouis Fragments, Rune Storm Caches." },
                { text = " " },
                { text = "Head to the Forgotten Vault and free Thrayir." },
                { text = "Cave Entrance", way = "/way #2369 44.8 22.4 Cave Entrance" },
                { text = "Singing Tablet", way = "/way #2369 50.2 15.5 Singing Tablet" },
                { text = "Thrayir, Eyes of the Siren", way = "/way #2375 72.7 61.4 Thrayir, Eyes of the Siren" },
            })

            Add("Record of a Grggly Stash", "Crimson Tidestallion", "https://warcraft-secrets.com/guides/mrrls-secret-stash", nil, {})

            Add("Record of a Bad Horse", "Sinrunner Blanchy", "https://warcraft-secrets.com/guides/sinrunner-blanchy", nil, {})

            Add("Record of the Hivemind", "The Hivemind", "https://warcraft-secrets.com/guides/the-hivemind", nil, {
                { text = "Purchase and Equip Talisman of True Treasure Tracking from Griftah in Shattrath" },
                { text = "Griftah", way = "/way Shattrath 65 69" },
                { text = " " },
                { text = "...to be continued..." },
            })

            Add("Record of the Endless Nightmare", "Lucid Nightmare", "https://warcraft-secrets.com/guides/lucid-nightmare", nil, {})

            -- Update Mind-Seeker header with progress
            local completedRecords = 0
            local achID = 14517 -- The Mind-Seeker
            if GetAchievementInfo(achID) then
                local numCriteria = GetAchievementNumCriteria(achID)
                for i = 1, numCriteria do
                    local _, _, completed = GetAchievementCriteriaInfo(achID, i)
                    if completed then
                        completedRecords = completedRecords + 1
                    end
                end
            end
            mindSeekerSection.title = string.format("Secrets: %d/%d", completedRecords, totalRecords)
        end
    else
        table.insert(sections, {
            title = "?????",
            items = {
                { text = "Seat of Knowledge", isKnown = true, iconID = false, type = "body" },
                { text = "Travel to Vashj'ir and locate the Pearl of the Abyss", isKnown = true, iconID = false, type = "body" },
                { text = "found in the fatigue waters south of the Abyssal Depths.", isKnown = true, iconID = false, type = "body" },
                { text = " ", isKnown = true, iconID = false, type = "body" },
                { text = "1. Obtain water breathing via one of the following options:", isKnown = true, iconID = false, type = "body" },
                { text = "    - Elixir: Draenic Water Breathing", isKnown = true, iconID = false, type = "body" },
                { text = "    - Consumable: Shimmerscale Diving Helmet", isKnown = true, iconID = false, type = "body" },
                { text = "    - Spell: Aquatic Form, Touch of the Grave or Unending Breath", isKnown = true, iconID = false, type = "body" },
                { text = "2. Use an underwater mount of or underwater swim spell.", isKnown = true, iconID = false, type = "body" },
                { text = "3. Go to Vashj'ir", isKnown = true, iconID = false, type = "body" },
                { text = "4. /way #2255 60.0 66.2 Al'kubian", isKnown = true, iconID = false, macroText = "/way #2255 60.0 66.2 Al'kubian", type = "waypoint" },
                { text = "5. /way #13 26.45 70.60 Safe Location", isKnown = true, iconID = false, macroText = "/way #13 26.45 70.60 Safe Location", type = "waypoint" },
                { text = "6. Use consumables, mount, swim to the bones.", isKnown = true, iconID = false, type = "body" },
                { text = "7. Swim downward, adjusting into the gray to avoid fatigue", isKnown = true, iconID = false, type = "body" },
                { text = "8. Once screen turns into a vivid blue, swim directly to pearl.", isKnown = true, iconID = false, type = "body" },
                { text = "9. /way #13 26.45 71.67 Pearl", isKnown = true, iconID = false, macroText = "/way #13 26.45 71.67 Pearl", type = "waypoint" },
                { text = "10. Click on Pearl", isKnown = true, iconID = false, type = "body" },
            }
        })
    end

    return sections
end