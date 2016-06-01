require "old2dgeo"

class 'CollisionPE'
    HERO_ALL = 1
    HERO_ENEMY = 2
    HERO_ALLY = 3

    function SayHello()
        -- Print to the chat area
        PrintChat("Elo, Masz skrypt na omijanie", #FF00FF)
    end
     
    function OnLoad()
    	SayHello()
    end
 
    function CollisionPE:__init(sRange, projSpeed, sDelay, sWidth)
        uniqueId = uniqueId + 1
        self.uniqueId = uniqueId
 
        self.sRange = sRange
        self.projSpeed = projSpeed
        self.sDelay = sDelay
        self.sWidth = sWidth/2
 
        self.enemyMinions = minionManager(MINION_ALLY, 2000, myHero, MINION_SORT_HEALTH_ASC)
        self.minionupdate = 0
    end
 
    function CollisionPE:GetMinionCollision(pStart, pEnd)
        self.enemyMinions:update()
 
        local distance =  GetDistance(pStart, pEnd)
        local prediction = TargetPredictionVIP(self.sRange, self.projSpeed, self.sDelay, self.sWidth)
        local mCollision = {}
 
        if distance > self.sRange then
            distance = self.sRange
        end
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x *self.sWidth)
        local startLeftY = pStart.y + (y *self.sWidth)
        local startLeftZ = pStart.z + (z *self.sWidth)
        local endLeftX = pStart.x + (x * self.sWidth) + (t * distance)
        local endLeftY = pStart.y + (y * self.sWidth) + (i * distance)
        local endLeftZ = pStart.z + (z * self.sWidth) + (u * distance)
       
        local startRightX = pStart.x - (x * self.sWidth)
        local startRightY = pStart.y - (y * self.sWidth)
        local startRightZ = pStart.z - (z * self.sWidth)
        local endRightX = pStart.x - (x * self.sWidth) + (t * distance)
        local endRightY = pStart.y - (y * self.sWidth) + (i * distance)
        local endRightZ = pStart.z - (z * self.sWidth)+ (u * distance)
 
        local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
        local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
        local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
        local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
       
        local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
         for index, minion in pairs(self.enemyMinions.objects) do
            if minion ~= nil and minion.valid and not minion.dead then
                if GetDistance(pStart, minion) < distance then
                    local pos, t, vec = prediction:GetPrediction(minion)
                    local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                    local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                    local toScreen, toPoint
                    if pos ~= nil then
                        toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    else
                        toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    end
 
 
                    if poly:contains(toPoint) then
                        table.insert(mCollision, minion)
                    else
                        if pos ~= nil then
                            distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                            distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                        else
                            distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                            distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                        end
                        if (distance1 < (getHitBoxRadius(minion)*2+10) or distance2 < (getHitBoxRadius(minion) *2+10)) then
                            table.insert(mCollision, minion)
                        end
                    end
                end
            end
        end
        if #mCollision > 0 then return true, mCollision else return false, mCollision end
    end
 
    function CollisionPE:GetHeroCollision(pStart, pEnd, mode)
        if mode == nil then mode = HERO_ENEMY end
        local heros = {}
 
        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if (mode == HERO_ENEMY or mode == HERO_ALL) and hero.team ~= myHero.team then
                table.insert(heros, hero)
            elseif (mode == HERO_ALLY or mode == HERO_ALL) and hero.team == myHero.team and not hero.isMe then
                table.insert(heros, hero)
            end
        end
 
        local distance =  GetDistance(pStart, pEnd)
        local prediction = TargetPredictionVIP(self.sRange, self.projSpeed, self.sDelay, self.sWidth)
        local hCollision = {}
 
        if distance > self.sRange then
            distance = self.sRange
        end
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x *self.sWidth)
        local startLeftY = pStart.y + (y *self.sWidth)
        local startLeftZ = pStart.z + (z *self.sWidth)
        local endLeftX = pStart.x + (x * self.sWidth) + (t * distance)
        local endLeftY = pStart.y + (y * self.sWidth) + (i * distance)
        local endLeftZ = pStart.z + (z * self.sWidth) + (u * distance)
       
        local startRightX = pStart.x - (x * self.sWidth)
        local startRightY = pStart.y - (y * self.sWidth)
        local startRightZ = pStart.z - (z * self.sWidth)
        local endRightX = pStart.x - (x * self.sWidth) + (t * distance)
        local endRightY = pStart.y - (y * self.sWidth) + (i * distance)
        local endRightZ = pStart.z - (z * self.sWidth)+ (u * distance)
 
        local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
        local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
        local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
        local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
       
        local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
        for index, hero in pairs(heros) do
            if hero ~= nil and hero.valid and not hero.dead then
                if GetDistance(pStart, hero) < distance then
                    local pos, t, vec = prediction:GetPrediction(hero)
                    local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                    local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                    local toScreen, toPoint
                    if pos ~= nil then
                        toScreen = WorldToScreen(D3DXVECTOR3(pos.x, hero.y, pos.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    else
                        toScreen = WorldToScreen(D3DXVECTOR3(hero.x, hero.y, hero.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    end
 
 
                    if poly:contains(toPoint) then
                        table.insert(hCollision, hero)
                    else
                        if pos ~= nil then
                            distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                            distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                        else
                            distance1 = Point(hero.x, hero.z):distance(lineSegmentLeft)
                            distance2 = Point(hero.x, hero.z):distance(lineSegmentRight)
                        end
                        if (distance1 < (getHitBoxRadius(hero)*2+10) or distance2 < (getHitBoxRadius(hero) *2+10)) then
                            table.insert(hCollision, hero)
                        end
                    end
                end
            end
        end
        if #hCollision > 0 then return true, hCollision else return false, hCollision end
    end
 
    function CollisionPE:GetCollision(pStart, pEnd)
        local b , minions = self:GetMinionCollision(pStart, pEnd)
        local t , heros = self:GetHeroCollision(pStart, pEnd, HERO_ENEMY)
 
        if not b then return t, heros end
        if not t then return b, minions end
 
        local all = {}
 
        for index, hero in pairs(heros) do
            table.insert(all, hero)
        end
 
        for index, minion in pairs(minions) do
            table.insert(all, minion)
        end
 
        return true, all
    end


    function getHitBoxRadius(target)
        return GetDistance(target, target.minBBox)/2
    end
    local versionmessage = "<font color=\"#81BEF7\" >Thank for using FreEvade Pingouin, have a nice day!</font>"


_G.evade = false
moveBuffer = 25
smoothing = 75
dashrange = 0


champions = {}
champions2 = {
    ["Lux"] = {charName = "Lux", skillshots = {
        ["Light Binding"] =  {name = "LightBinding", spellName = "LuxLightBinding", spellDelay = 300, projectileName = "LuxLightBinding_mis.troy", projectileSpeed = 1200, range = 1300, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        ["Lux LightStrike Kugel"] = {name = "LuxLightStrikeKugel", spellName = "LuxLightStrikeKugel", spellDelay = 300, projectileName = "LuxLightstrike_mis.troy", projectileSpeed = 1300, range = 1100, radius = 300, type = "circle", cc = "false", collision = "false", shieldnow = "false"},
        ["Lux Malice Cannon"] =  {name = "LuxMaliceCannon", spellName = "LuxMaliceCannon", spellDelay = 500, projectileName = "LuxMaliceCannon_cas.troy", projectileSpeed = 50000, range = 3000, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        }},
    ["Nidalee"] = {charName = "Nidalee", skillshots = {
        ["Javelin Toss"] = {name = "JavelinToss", spellName = "JavelinToss", spellDelay = 300, projectileName = "nidalee_javelinToss_mis.troy", projectileSpeed = 1300, range = 1500, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"}
        }},
    ["Kennen"] = {charName = "Kennen", skillshots = {
        ["Thundering Shuriken"] = {name = "ThunderingShuriken", spellName = "KennenShurikenHurlMissile1", spellDelay = 300, projectileName = "kennen_ts_mis.troy", projectileSpeed = 1650, range = 1050, radius = 50, type = "line", cc = "false", collision = "true", shieldnow = "true"}
        }},
    ["Amumu"] = {charName = "Amumu", skillshots = {
        ["Bandage Toss"] = {name = "BandageToss", spellName = "BandageToss", spellDelay = 300, projectileName = "Bandage_beam.troy", projectileSpeed = 2000, range = 1100, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"}
        }},
    ["Lee Sin"] = {charName = "LeeSin", skillshots = {
        ["Sonic Wave"] = {name = "SonicWave", spellName = "BlindMonkQOne", spellDelay = 300, projectileName = "blindMonk_Q_mis_01.troy", projectileSpeed = 1800, range = 975, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"}
        }},
    ["Morgana"] = {charName = "Morgana", skillshots = {
        ["Dark Binding Missile"] = {name = "DarkBinding", spellName = "DarkBindingMissile", spellDelay = 300, projectileName = "DarkBinding_mis.troy", projectileSpeed = 1200, range = 1300, radius = 100, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Sejuani"] = {charName = "Sejuani", skillshots = {
        ["SejuaniR"] = {name = "SejuaniR", spellName = "SejuaniGlacialPrisonCast", spellDelay = 250, projectileName = "Sejuani_R_mis.troy", projectileSpeed = 1350, range = 1150, radius = 80, type="line", cc = "true", collision = "false", shieldnow = "true"},    
        }},
    ["Sona"] = {charName = "Sona", skillshots = {
        ["Crescendo"] = {name = "Crescendo", spellName = "SonaCrescendo", spellDelay = 240, projectileName = "SonaCrescendo_mis.troy", projectileSpeed = 2400, range = 1000, radius = 150, type = "line", cc = "true", collision = "false", shieldnow = "true"},        
        }},
    ["Gragas"] = {charName = "Gragas", skillshots = {
        ["Barrel Roll"] = {name = "BarrelRoll", spellName = "GragasBarrelRoll", spellDelay = 300, projectileName = "gragas_barrelroll_mis.troy", projectileSpeed = 1000, range = 1100, radius = 320, type = "circle", cc = "false", collision = "false", shieldnow = "false"},
        ["Barrel Roll Missile"] = {name = "BarrelRollMissile", spellName = "GragasBarrelRollMissile", spellDelay = 0, projectileName = "gragas_barrelroll_mis.troy", projectileSpeed = 1000, range = 850, radius = 180, type = "circle", cc = "false", collision = "false", shieldnow = "false"},
        }},
    ["Syndra"] = {charName = "Syndra", skillshots = {
        ["Q"] = {name = "Q", spellName = "SyndraQ", spellDelay = 250, projectileName = "Syndra_Q_fall.troy", projectileSpeed = 500, range = 800, radius = 175, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
        ["W"] = {name = "W", spellName = "syndrawcast", spellDelay = 250, projectileName = "Syndra_W_fall.troy", projectileSpeed = 500, range = 950, radius = 200, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Malphite"] = {charName = "Malphite", skillshots = {
        ["UFSlash"] = {name = "UFSlash", spellName = "UFSlash", spellDelay = 0, projectileName = "UnstoppableForce_cas.troy", projectileSpeed = 550, range = 1000, radius = 325, type="circular", cc = "true", collision = "false", shieldnow = "true"},    
        }},
    ["Ezreal"] = {charName = "Ezreal", skillshots = {
        ["Mystic Shot"]             = {name = "MysticShot",      spellName = "EzrealMysticShot",      spellDelay = 250, projectileName = "Ezreal_mysticshot_mis.troy",  projectileSpeed = 1975, range = 1200,  radius = 50,  type = "line", cc = "false", collision = "true", shieldnow = "true"},
        ["Essence Flux"]            = {name = "EssenceFlux",     spellName = "EzrealEssenceFlux",     spellDelay = 300, projectileName = "Ezreal_essenceflux_mis.troy", projectileSpeed = 1500, range = 900,  radius = 100,  type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["Mystic Shot (Pulsefire)"] = {name = "MysticShot",      spellName = "EzrealMysticShotPulse", spellDelay = 250, projectileName = "Ezreal_mysticshot_mis.troy",  projectileSpeed = 1975, range = 1200,  radius = 50,  type = "line", cc = "false", collision = "true", shieldnow = "true"},
        ["Trueshot Barrage"]        = {name = "TrueshotBarrage", spellName = "EzrealTrueshotBarrage", spellDelay = 1000, projectileName = "Ezreal_TrueShot_mis.troy",    projectileSpeed = 2000, range = 20000, radius = 150, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Ahri"] = {charName = "Ahri", skillshots = {
        ["Orb of Deception"] = {name = "OrbofDeception", spellName = "AhriOrbofDeception", spellDelay = 300, projectileName = "Ahri_Orb_mis.troy", projectileSpeed = 1700, range = 880, radius = 100, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["Orb of Deception Back"] = {name = "OrbofDeceptionBack", spellName = "AhriOrbofDeceptionherpityderp", spellDelay = 250+360, projectileName = "Ahri_Orb_mis_02.troy", projectileSpeed = 915, range = 880, radius = 100, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["Charm"] = {name = "Charm", spellName = "AhriSeduce", spellDelay = 250, projectileName = "Ahri_Charm_mis.troy", projectileSpeed = 1600, range = 975, radius = 60, type = "line", cc = "true", collision = "true", shieldnow = "true"}
        }},
    ["Olaf"] = {charName = "Olaf", skillshots = {
        ["Undertow"] = {name = "Undertow", spellName = "OlafAxeThrow", spellDelay = 300, projectileName = "olaf_axe_mis.troy", projectileSpeed = 1600, range = 1000, radius = 100, type = "line", cc = "true", collision = "false", shieldnow = "true"}
        }},
    ["Leona"] = {charName = "Leona", skillshots = {
        ["Zenith Blade"] = {name = "LeonaZenithBlade", spellName = "LeonaZenithBlade", spellDelay = 250, projectileName = "Leona_ZenithBlade_mis.troy", projectileSpeed = 2000, range = 875, radius = 110, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        ["Leona Solar Flare"] = {name = "LeonaSolarFlare", spellName = "LeonaSolarFlare", spellDelay = 250, projectileName = "Leona_SolarFlare_cas.troy", projectileSpeed = 1500, range = 1200, radius = 300, type = "circular", cc = "true", collision = "false", shieldnow = "true"}
        }},
    ["Karthus"] = {charName = "Karthus", skillshots = {
        ["Lay Waste"] = {name = "LayWaste", spellName = "LayWaste", spellDelay = 250, projectileName = "LayWaste_point.troy", projectileSpeed = 1750, range = 875, radius = 150, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
        }},
    ["Chogath"] = {charName = "Chogath", skillshots = {
        ["Rupture"] = {name = "Rupture", spellName = "Rupture", spellDelay = 0, projectileName = "rupture_cas_01_red_team.troy", projectileSpeed = 950, range = 950, radius = 275, type = "circular", cc = "true", collision = "false", shieldnow = "true"}
        }},
    ["Blitzcrank"] = {charName = "Blitzcrank", skillshots = {
        ["Rocket Grab"] = {name = "RocketGrab", spellName = "RocketGrabMissile", spellDelay = 300, projectileName = "FistGrab_mis.troy", projectileSpeed = 1700, range = 925, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Anivia"] = {charName = "Anivia", skillshots = {
        ["Flash Frost"] = {name = "FlashFrost", spellName = "FlashFrostSpell", spellDelay = 300, projectileName = "cryo_FlashFrost_mis.troy", projectileSpeed = 845, range = 1100, radius = 90, type = "line", cc = "true", collision = "false", shieldnow = "true"}
        }},
    ["Zyra"] = {charName = "Zyra", skillshots = {
        ["Grasping Roots"] = {name = "GraspingRoots", spellName = "ZyraGraspingRoots", spellDelay = 250, projectileName = "Zyra_E_sequence_impact.troy", projectileSpeed = 1150, range = 825, radius = 275,  type = "line", cc = "true", collision = "false", shieldnow = "true"},
        ["Zyra Passive Death"] = {name = "ZyraPassive", spellName = "zyrapassivedeathmanager", spellDelay = 500, projectileName = "zyra_passive_plant_mis.troy", projectileSpeed = 2000, range = 1474, radius = 60,  type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Nautilus"] = {charName = "Nautilus", skillshots = {
        ["Dredge Line"] = {name = "DredgeLine", spellName = "NautilusAnchorDrag", spellDelay = 250, projectileName = "Nautilus_Q_mis.troy", projectileSpeed = 2000, range = 950, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Caitlyn"] = {charName = "Caitlyn", skillshots = {
        ["Piltover Peacemaker"] = {name = "PiltoverPeacemaker", spellName = "CaitlynPiltoverPeacemaker", spellDelay = 625, projectileName = "caitlyn_Q_mis.troy", projectileSpeed = 2200, range = 1300, radius = 80, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["Caitlyn Entrapment"] = {name = "CaitlynEntrapment", spellName = "CaitlynEntrapment", spellDelay = 150, projectileName = "caitlyn_entrapment_mis.troy", projectileSpeed = 2000, range = 1000, radius = 0, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Mundo"] = {charName = "DrMundo", skillshots = {
        ["Infected Cleaver"] = {name = "InfectedCleaver", spellName = "InfectedCleaverMissile", spellDelay = 300, projectileName = "dr_mundo_infected_cleaver_mis.troy", projectileSpeed = 2000, range = 1000, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Brand"] = {charName = "Brand", skillshots = {
        ["BrandBlaze"] = {name = "BrandBlaze", spellName = "BrandBlaze", spellDelay = 250, projectileName = "BrandBlaze_mis.troy", projectileSpeed = 1550, range = 1050, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        ["Pillar of Flame"] = {name = "PillarofFlame", spellName = "BrandFissure", spellDelay = 250, projectileName = "BrandPOF_tar_green.troy", projectileSpeed = 900, range = 1150, radius = 240, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
        }},
    ["Corki"] = {charName = "Corki", skillshots = {
        ["Missile Barrage"] = {name = "MissileBarrage", spellName = "MissileBarrage", spellDelay = 250, projectileName = "corki_MissleBarrage_mis.troy", projectileSpeed = 1950, range = 1300, radius = 40, type = "line", cc = "false", collision = "true", shieldnow = "true"},
        ["Missile Barrage big"] = {name = "MissileBarragebig", spellName = "MissileBarrage!", spellDelay = 250, projectileName = "Corki_MissleBarrage_DD_mis.troy", projectileSpeed = 2000, range = 1300, radius = 40, type = "line", cc = "false", collision = "true", shieldnow = "true"}
        }},
    ["TwistedFate"] = {charName = "TwistedFate", skillshots = {
        ["Loaded Dice"] = {name = "LoadedDice", spellName = "WildCards", spellDelay = 250, projectileName = "Roulette_mis.troy", projectileSpeed = 1000, range = 1450, radius = 40, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Swain"] = {charName = "Swain", skillshots = {
        ["Nevermove"] = {name = "Nevermove", spellName = "SwainShadowGrasp", spellDelay = 250, projectileName = "swain_shadowGrasp_transform.troy", projectileSpeed = 1000, range = 900, radius = 180, type = "circular", cc = "true", collision = "false", shieldnow = "true"}
        }},
    ["Cassiopeia"] = {charName = "Cassiopeia", skillshots = {
        ["Noxious Blast"] = {name = "NoxiousBlast", spellName = "CassiopeiaNoxiousBlast", spellDelay = 250, projectileName = "CassNoxiousSnakePlane_green.troy", projectileSpeed = 500, range = 850, radius = 130, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Sivir"] = {charName = "Sivir", skillshots = {
        ["Boomerang Blade"] = {name = "BoomerangBlade", spellName = "SivirQ", spellDelay = 250, projectileName = "Sivir_Base_Q_mis.troy", projectileSpeed = 1350, range = 1250, radius = 101, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Ashe"] = {charName = "Ashe", skillshots = {
        ["Enchanted Arrow"] = {name = "EnchantedArrow", spellName = "EnchantedCrystalArrow", spellDelay = 250, projectileName = "Ashe_Base_R_mis.troy", projectileSpeed = 1600, range = 25000, radius = 120, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        }},
    ["KogMaw"] = {charName = "KogMaw", skillshots = {
        ["Living Artillery"] = {name = "LivingArtillery", spellName = "KogMawLivingArtillery", spellDelay = 250, projectileName = "KogMawLivingArtillery_mis.troy", projectileSpeed = 1050, range = 2200, radius = 225, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
        }},
    ["Khazix"] = {charName = "Khazix", skillshots = {
        ["KhazixW"] = {name = "KhazixW", spellName = "KhazixW", spellDelay = 250, projectileName = "Khazix_W_mis_enhanced.troy", projectileSpeed = 1650, range = 1000, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        ["khazixwlong"] = {name = "khazixwlong", spellName = "khazixwlong", spellDelay = 250, projectileName = "Khazix_W_mis_enhanced.troy", projectileSpeed = 1700, range = 1025, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Zed"] = {charName = "Zed", skillshots = {
        ["ZedShuriken"] = {name = "ZedShuriken", spellName = "ZedShuriken", spellDelay = 250, projectileName = "Zed_Q_Mis.troy", projectileSpeed = 1700, range = 900, radius = 50, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Leblanc"] = {charName = "Leblanc", skillshots = {
        ["Ethereal Chains"] = {name = "EtherealChains", spellName = "LeblancSoulShackle", spellDelay = 250, projectileName = "leBlanc_shackle_mis.troy", projectileSpeed = 1750, range = 960, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        ["Ethereal Chains R"] = {name = "EtherealChainsR", spellName = "LeblancSoulShackleM", spellDelay = 250, projectileName = "leBlanc_shackle_mis_ult.troy", projectileSpeed = 1750, range = 960, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Draven"] = {charName = "Draven", skillshots = {
        ["Stand Aside"] = {name = "StandAside", spellName = "DravenDoubleShot", spellDelay = 250, projectileName = "Draven_E_mis.troy", projectileSpeed = 1400, range = 1050, radius = 130, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        ["DravenR"] = {name = "DravenR", spellName = "DravenRCast", spellDelay = 500, projectileName = "Draven_R_mis!.troy", projectileSpeed = 2000, range = 25000, radius = 160, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Elise"] = {charName = "Elise", skillshots = {
        ["Cocoon"] = {name = "Cocoon", spellName = "EliseHumanE", spellDelay = 250, projectileName = "Elise_human_E_mis.troy", projectileSpeed = 1600, range = 1075, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"}
        }},
    ["Lulu"] = {charName = "Lulu", skillshots = {
        ["LuluQ"] = {name = "LuluQ", spellName = "LuluQ", spellDelay = 250, projectileName = "Lulu_Q_Mis.troy", projectileSpeed = 1500, range = 925, radius = 50, type = "line", cc = "true", collision = "false", shieldnow = "true"}
        }},
    ["Thresh"] = {charName = "Thresh", skillshots = {
        ["ThreshQ"] = {name = "ThreshQ", spellName = "ThreshQ", spellDelay = 500, projectileName = "Thresh_Q_whip_beam.troy", projectileSpeed = 1900, range = 1100, radius = 65, type = "line", cc = "true", collision = "true", shieldnow = "true"}
        }},
    ["Shen"] = {charName = "Shen", skillshots = {
        ["ShadowDash"] = {name = "ShadowDash", spellName = "ShenShadowDash", spellDelay = 0, projectileName = "shen_shadowDash_mis.troy", projectileSpeed = 3000, range = 600, radius = 50, type = "line", cc = "true", collision = "false", shieldnow = "true"}
        }},
    ["Quinn"] = {charName = "Quinn", skillshots = {
        ["QuinnQ"] = {name = "QuinnQ", spellName = "QuinnQ", spellDelay = 250, projectileName = "Quinn_Q_missile.troy", projectileSpeed = 1550, range = 1050, radius = 80, type = "line", cc = "false", collision = "true", shieldnow = "true"}
        }},
    ["Veigar"] = {charName = "Veigar", skillshots = {
        ["Dark Matter"] = {name = "VeigarDarkMatter", spellName = "VeigarDarkMatter", spellDelay = 250, projectileName = "!", projectileSpeed = 900, range = 900, radius = 225, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
        }},
    ["Jayce"] = {charName = "Jayce", skillshots = {
        ["JayceShockBlast"] = {name = "JayceShockBlast", spellName = "jayceshockblast", spellDelay = 250, projectileName = "JayceOrbLightning.troy", projectileSpeed = 1450, range = 1050, radius = 70, type = "line", cc = "false", collision = "true", shieldnow = "true"},
        ["JayceShockBlastCharged"] = {name = "JayceShockBlastCharged", spellName = "jayceshockblast", spellDelay = 250, projectileName = "JayceOrbLightningCharged.troy", projectileSpeed = 1890, range = 1470, radius = 70, type = "line", cc = "false", collision = "true", shieldnow = "true"},
        }},
    ["Nami"] = {charName = "Nami", skillshots = {
        ["NamiQ"] = {name = "NamiQ", spellName = "NamiQ", spellDelay = 250, projectileName = "Nami_Q_mis.troy", projectileSpeed = 1500, range = 875, radius = 225, type = "circle", cc = "true", collision = "false", shieldnow = "true"}
        }},
    ["Fizz"] = {charName = "Fizz", skillshots = {
        ["Fizz Ultimate"] = {name = "FizzULT", spellName = "FizzMarinerDoom", spellDelay = 250, projectileName = "Fizz_UltimateMissile.troy", projectileSpeed = 1300, range = 1275, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        }},
    ["Varus"] = {charName = "Varus", skillshots = {
        ["Varus Q Missile"] = {name = "VarusQMissile", spellName = "somerandomspellnamethatwillnevergetcalled", spellDelay = 0, projectileName = "VarusQ_mis.troy", projectileSpeed = 1900, range = 1600, radius = 70, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["VarusR"] = {name = "VarusR", spellName = "VarusR", spellDelay = 250, projectileName = "VarusRMissile.troy", projectileSpeed = 1850, range = 1625, radius = 100, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        }},
    ["Karma"] = {charName = "Karma", skillshots = {
        ["KarmaQ"] = {name = "KarmaQ", spellName = "KarmaQ", spellDelay = 250, projectileName = "TEMP_KarmaQMis.troy", projectileSpeed = 1700, range = 1075, radius = 90, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Aatrox"] = {charName = "Aatrox", skillshots = {
        ["Blade of Torment"] = {name = "BladeofTorment", spellName = "AatroxE", spellDelay = 250, projectileName = "AatroxBladeofTorment_mis.troy", projectileSpeed = 1200, range = 1000, radius = 75, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        ["AatroxQ"] = {name = "AatroxQ", spellName = "AatroxQ", spellDelay = 250, projectileName = "AatroxQ.troy", projectileSpeed = 450, range = 650, radius = 145, type = "circle", cc = "true", collision = "false", shieldnow = "true"},
        }},
    ["Xerath"] = {charName = "Xerath", skillshots = {
        ["Xerath Arcanopulse"] =  {name = "XerathArcanopulse", spellName = "XerathArcanopulse", spellDelay = 1375, projectileName = "Xerath_Beam_cas.troy", projectileSpeed = 25000, range = 750, radius = 100, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["Xerath Arcanopulse Extended"] =  {name = "XerathArcanopulseExtended", spellName = "xeratharcanopulseextended", spellDelay = 1400, projectileName = "Xerath_Beam_cas.troy", projectileSpeed = 25000, range = 1625, radius = 100, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["xeratharcanebarragewrapper"] = {name = "xeratharcanebarragewrapper", spellName = "xeratharcanebarragewrapper", spellDelay = 250, projectileName = "Xerath_E_cas.troy", projectileSpeed = 300, range = 1100, radius = 265, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
        ["xeratharcanebarragewrapperext"] = {name = "xeratharcanebarragewrapperext", spellName = "xeratharcanebarragewrapperext", spellDelay = 250, projectileName = "Xerath_E_cas.troy", projectileSpeed = 300, range = 1700, radius = 265, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Lucian"] = {charName = "Lucian", skillshots = {
        ["LucianQ"] =  {name = "LucianQ", spellName = "LucianQ", spellDelay = 350, projectileName = "Lucian_Q_laser.troy", projectileSpeed = 25000, range = 500*2, radius = 65, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["LucianW"] =  {name = "LucianW", spellName = "LucianW", spellDelay = 300, projectileName = "Lucian_W_mis.troy", projectileSpeed = 1600, range = 1000, radius = 80, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Viktor"] = {charName = "Viktor", skillshots = {
        ["ViktorDeathRay1"] =  {name = "ViktorDeathRay1", spellName = "ViktorDeathRay!", spellDelay = 500, projectileName = "Viktor_DeathRay_Fix_Mis.troy", projectileSpeed = 1350, range = 525, radius = 80, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["ViktorDeathRay2"] =  {name = "ViktorDeathRay2", spellName = "ViktorDeathRay!", spellDelay = 500, projectileName = "Viktor_DeathRay_Fix_Mis_Augmented.troy", projectileSpeed = 780, range = 700, radius = 80, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Rumble"] = {charName = "Rumble", skillshots = {
        ["RumbleGrenade"] =  {name = "RumbleGrenade", spellName = "RumbleGrenade", spellDelay = 250, projectileName = "rumble_taze_mis.troy", projectileSpeed = 2000, range = 950, radius = 90, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        }},
    ["Nocturne"] = {charName = "Nocturne", skillshots = {
        ["NocturneDuskbringer"] =  {name = "NocturneDuskbringer", spellName = "NocturneDuskbringer", spellDelay = 250, projectileName = "NocturneDuskbringer_mis.troy", projectileSpeed = 1400, range = 1200, radius = 60, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Yasuo"] = {charName = "Yasuo", skillshots = {
        ["yasuoq3"] =  {name = "yasuoq3", spellName = "yasuoq3w", spellDelay = 250, projectileName = "Yasuo_Q_wind_mis.troy", projectileSpeed = 1200, range = 1000, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        ["yasuoq1"] =  {name = "yasuoq1", spellName = "yasuoQW", spellDelay = 250, projectileName = "Yasuo_Q_WindStrike.troy", projectileSpeed = 25000, range = 475, radius = 40, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        ["yasuoq2"] =  {name = "yasuoq2", spellName = "yasuoq2w", spellDelay = 250, projectileName = "Yasuo_Q_windstrike_02.troy", projectileSpeed = 25000, range = 475, radius = 40, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},
    ["Orianna"] = {charName = "Orianna", skillshots = {
        ["OrianaIzunaCommand"] =  {name = "OrianaIzunaCommand", spellName = "OrianaIzunaCommand", spellDelay = 0, projectileName = "Oriana_Ghost_mis.troy", projectileSpeed = 1300, range = 800, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
        ["OrianaDetonateCommand"] =  {name = "OrianaDetonateCommand", spellName = "OrianaDetonateCommand", spellDelay = 100, projectileName = "Oriana_Shockwave_nova.troy", projectileSpeed = 400, range = 2000, radius = 400, type = "circular", cc = "true", collision = "false", shieldnow = "true"},   
        }},
    ["Ziggs"] = {charName = "Ziggs", skillshots = {
        ["ZiggsQ"] =  {name = "ZiggsQ", spellName = "ZiggsQ", spellDelay = 250, projectileName = "ZiggsQ.troy", projectileSpeed = 1700, range = 1400, radius = 155, type = "line", cc = "false", collision = "true", shieldnow = "true"},
        }},
    ["Annie"] = {charName = "Annie", skillshots = {
        ["AnnieR"] =  {name = "AnnieR", spellName = "InfernalGuardian", spellDelay = 100, projectileName = "nothing", projectileSpeed = 0, range = 600, radius = 300, type = "circular", cc = "true", collision = "false", shieldnow = "true"},
        }},
    ["Galio"] = {charName = "Galio", skillshots = {
        ["GalioResoluteSmite"] =  {name = "GalioResoluteSmite", spellName = "GalioResoluteSmite", spellDelay = 250, projectileName = "galio_concussiveBlast_mis.troy", projectileSpeed = 850, range = 2000, radius = 200, type = "circle", cc = "true", collision = "false", shieldnow = "true"},
        }},
    ["Jinx"] = {charName = "Jinx", skillshots = {
        ["W"] =  {name = "Zap", spellName = "JinxW", spellDelay = 600, projectileName = "Jinx_W_Beam.troy", projectileSpeed = 3300, range = 1500, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
        ["R"] =  {name = "SuperMegaDeathRocket", spellName = "JinxRWrapper", spellDelay = 600, projectileName = "Jinx_R_Mis.troy", projectileSpeed = 1700, range = 20000, radius = 120, type = "line", cc = "false", collision = "false", shieldnow = "true"},
        }},         
        }
wrotedisclaimer = false
enemyes = {}
nAllies = 0
allies = {}
nEnemies = 0
evading             = false
allowCustomMovement = true
captureMovements    = true
lastMovement        = {}
detectedSkillshots  = {}
nSkillshots = 0
CastingSpell = false
lastset = 0
trueWidth = {}
trueSpeed = {}
trueDelay = {}
haveflash = false
flashSlot = nil
flashready = false
lastspell = "Q"
useflash = false
shieldslot = _E
shieldtick = nil
alreadywritten = false
thatfile = SCRIPT_PATH.."movementblock.txt"
currentbuffer = 0
bufferset = false
lastnonattack = 0

function getTarget(targetId)
    if targetId ~= 0 and targetId ~= nil then
        return objManager:GetObjectByNetworkId(targetId)
    end
    return nil
end

function OnSendPacket(p)
if VIP_USER then
    local packet = Packet(p)
    if packet:get('name') == 'S_MOVE' then
        if packet:get('sourceNetworkId') == myHero.networkID then
            if captureMovements then
                if packet:get('targetNetworkId') == "0" then
                lastMovement.destination = Point2(packet:get('x'), packet:get('y'))
                lastMovement.type = packet:get('type')
                lastMovement.targetId = packet:get('targetNetworkId')
                lastnonattack = GetTickCount()
            elseif lastnonattack + 1000 < GetTickCount() then
                lastMovement.destination = Point2(packet:get('x'), packet:get('y'))
                lastMovement.type = packet:get('type')
                lastMovement.targetId = packet:get('targetNetworkId')
            end

                if evading then
                    for i, detectedSkillshot in pairs(detectedSkillshots) do
                        if detectedSkillshot and detectedSkillshot.evading and inDangerousArea(detectedSkillshot, Point2(myHero.x, myHero.z)) then
                            dodgeSkillshot(detectedSkillshot)
                            break
                        end
                    end
                end
            end
            if not allowCustomMovement then
                packet:block()
            end          
        end
    elseif packet:get('name') == 'S_CAST' then
        if captureMovements and lastnonattack + 1000 < GetTickCount() then
            lastMovement.spellId = packet:get('spellId')
            lastMovement.type = 7
            lastMovement.targetId = packet:get('targetNetworkId')
            lastMovement.destination = Point2(packet:get('toX'), packet:get('toY'))

            if evading then
                for i, detectedSkillshot in pairs(detectedSkillshots) do
                    if detectedSkillshot and detectedSkillshot.evading and inDangerousArea(detectedSkillshot, Point2(myHero.x, myHero.z)) then
                        dodgeSkillshot(detectedSkillshot)
                        break
                    end
                end
            end
        end

        if not allowCustomMovement then
            if packet:get('spellId') == 12 then
            else
                packet:block()
            end
        end
    end
end
end

function getLastMovementDestination()
    mousePosition = Point2(mousePos.x, mousePos.z)
    if VIP_USER then
        if lastMovement.type == 3 then
            heroPosition = Point2(myHero.x, myHero.z)
            mousePosition = Point2(mousePos.x, mousePos.z)

            target = getTarget(lastMovement.targetId)
            if _isValidTarget(target) then
                targetPosition = Point2(target.x, target.z)

                local attackRange = (myHero.range + GetDistance(myHero.minBBox, myHero.maxBBox) / 2 + GetDistance(target.minBBox, target.maxBBox) / 2)

                if attackRange <= heroPosition:distance(targetPosition) then
                    return targetPosition + (heroPosition - targetPosition):normalized() * attackRange
                else
                    return mousePosition
                end
            else
                return mousePosition
            end
        elseif lastMovement.type == 7 then
            heroPosition = Point2(myHero.x, myHero.z)
            mousePosition = Point2(mousePos.x, mousePos.z)
            target = getTarget(lastMovement.targetId)
            if _isValidTarget(target) then
                targetPosition = Point2(target.x, target.z)

                local castRange = myHero:GetSpellData(lastMovement.spellId).range

                if castRange <= heroPosition:distance(targetPosition) then
                    return targetPosition + (heroPosition - targetPosition):normalized() * castRange
                else
                    return mousePosition
                end
            else
                local castRange = myHero:GetSpellData(lastMovement.spellId).range

                if castRange <= heroPosition:distance(lastMovement.destination) then
                    return lastMovement.destination + (heroPosition - lastMovement.destination):normalized() * castRange
                else
                    return mousePosition
                end
            end
        else
            return lastMovement.destination
        end
        else return lastMovement.destination
    end
end
function CheckBall(obj)
    if obj == nil or obj.name == nil then return end  
    
    if (obj.name:find("Oriana_Ghost_mis") or obj.name:find("Oriana_Ghost_mis_protect") ) then
        ball = nil
        return
    end

    if obj.name:find("yomu_ring_red") then
        ball = obj
        return
    end

    if obj.name:find("Oriana_Ghost_bind") then
        for i, target in pairs(enemyes) do
            if GetDistance(target, obj) < 40 then
                ball = target
           end
        end
    end
end 

local AutoUpdate = false 


    function OnLoad()
        ball = nil
        GoodEvadeConfig = scriptConfig("Freaking Good Evade", "Freaking Good Evade")
        GoodEvadeConfig:addParam("evadeBuffer", "Increase Skillshot width by...", SCRIPT_PARAM_SLICE, 15, 0, 50, 0 )
        GoodEvadeConfig:addParam("lineallways", "Allways try to dodge line skillshots", SCRIPT_PARAM_ONOFF, true)
        GoodEvadeConfig:addParam("fowdelay", "Delay for skillshots in FOW", SCRIPT_PARAM_SLICE, 1, 1, 20, 0)
        GoodEvadeConfig:addParam("dodgeEnabled", "Dodge Skillshots", SCRIPT_PARAM_ONOFF, true)
        GoodEvadeConfig:addParam("drawEnabled", "Draw Skillshots", SCRIPT_PARAM_ONOFF, true)
        GoodEvadeConfig:addParam("dodgeCConly", "Dodge CC only spells", SCRIPT_PARAM_ONKEYDOWN, false, 32)
        GoodEvadeConfig:addParam("dodgeCConly2", "Dodge CC only spells toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, 77)
        GoodEvadeConfig:addParam("resetdodge", "Reset Dodge", SCRIPT_PARAM_ONKEYDOWN, false, 17)
        GoodEvadeConfig:addParam("usedashes", "Use Dash to dodge spells", SCRIPT_PARAM_ONOFF, true)
        GoodEvadeConfig:addParam("useflash", "Use Flash to dodge dangerous spells", SCRIPT_PARAM_ONOFF, true)
        GoodEvadeConfig:addParam("freemovementblock", "Free Users Movement Block", SCRIPT_PARAM_ONOFF, false)
        GoodEvadeConfig:permaShow("dodgeEnabled")
        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if hero.team ~= myHero.team then
                for i, skillShotChampion in pairs(champions2) do
                    if skillShotChampion.charName == hero.charName then
                        table.insert(champions, skillShotChampion)
                    end
                end
            end
        end
        GoodEvadeSkillshotConfig = scriptConfig("FGE skillshots", "FGE skillshots config")
        for i, skillShotChampion in pairs(champions) do
            for i, skillshot in pairs(skillShotChampion.skillshots) do
                name = tostring(skillshot.name)
                name2 = tostring(skillshot.name)
                if skillshot.cc == "true" then
                    GoodEvadeSkillshotConfig:addParam(name, "Dodge "..name2, SCRIPT_PARAM_SLICE, 2, 0, 2, 0)
                elseif skillshot.cc == "false" then GoodEvadeSkillshotConfig:addParam(name, "Dodge "..name2, SCRIPT_PARAM_SLICE, 1, 0, 2, 0)
                elseif skillshot.cc == "never" then GoodEvadeSkillshotConfig:addParam(name, "Dodge "..name2, SCRIPT_PARAM_SLICE, 0, 0, 2, 0)
                end
            end
        end

        stopEvade()
        isSivir = false
        if myHero.charName == "Sivir" then
            isSivir = true
        end
        isNocturne = false
        if myHero.charName == "Nocturne" then
            isNocturne = true
        end
        isVayne = false
        if myHero.charName == "Vayne" then 
            isVayne = true
        end
        isGraves = false
        if myHero.charName == "Graves" then 
            isGraves = true
        end
        isEzreal = false
        if myHero.charName == "Ezreal" then 
            isEzreal = true
        end
        if myHero.charName == "Caitlyn"
            then isCaitlyn  = true
        end
        isLeblanc = false
        if myHero.charName == "Leblanc" then 
            isLeblanc = true
        end
        isRiven = false
        if myHero.charName == "Riven" then 
            isRiven = true
        end
        isFizz = false
        if myHero.charName == "Fizz" then 
            isFizz = true
        end
        isShen = false
        if myHero.charName == "Shen" then 
            isShen = true
        end
        isShaco = false
        if myHero.charName == "Shaco" then 
            isShaco = true
        end
        isRenekton = false          
        if myHero.charName == "Renekton" then 
            isRenekton = true
        end
        isTristana = false
        if myHero.charName == "Tristana" then 
            isTristana = true
        end
        isTryndamere = false
        if myHero.charName == "Tryndamere" then 
            isTryndamere = true
        end
        isCorki = false
        if myHero.charName == "Corki" then 
            isCorki = true
        end
        isLucian = false
        if myHero.charName == "Lucian" then 
            isLucian = true
        end
        if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then 
            haveflash = true
            flashSlot = SUMMONER_1
        elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then 
            flashSlot = SUMMONER_2
            haveflash = true
        end

        lastMovement = {
            destination = Point2(myHero.x, myHero.z),
            moveCommand = Point2(myHero.x, myHero.z),
            type = 2,
            targetId = nil,
            spellId = nil,
            approachedPoint = nil
        }

        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if hero.team ~= myHero.team then
                table.insert(enemyes, hero)
            elseif hero.team == myHero.team and hero.nEnemies ~= myHero.networkID then
                table.insert(allies, hero)
            end
        end
        isOrianna = false
        for i, enemy in pairs(enemyes) do
            if enemy.charName == "Orianna" then
        isOrianna = true
        end
        end
        if #enemyes == 5 then
            for i, skillShotChampion in pairs(champions) do
                if skillShotChampion.charName ~= enemyes[1].charName and skillShotChampion.charName ~= enemyes[2].charName and skillShotChampion.charName ~= enemyes[3].charName
                    and skillShotChampion.charName ~= enemyes[4].charName and skillShotChampion.charName ~= enemyes[5].charName then
                    champions[i] = nil
                end
            end
        end

        player:RemoveCollision()
        player:SetVisionRadius(1700)

        GoodEvadeConfig.dodgeEnabled = true
        currentbuffer = GoodEvadeConfig.evadeBuffer
        PrintChat(versionmessage)
        if AutoUpdate then
            DelayAction(Update, 20)
        end
    end



    function getSideOfLine(linePoint1, linePoint2, point)
        if not point then return 0 end
        result = ((linePoint2.x - linePoint1.x) * (point.y - linePoint1.y) - (linePoint2.y - linePoint1.y) * (point.x - linePoint1.x))
        if result < 0 then
            return -1
        elseif result > 0 then
            return 1
        else
            return 0
        end
    end
colstartpos = nil
colendpos = nil
    function dodgeSkillshot(skillshot)
        if GoodEvadeConfig.dodgeEnabled and not myHero.dead and CastingSpell == false then
            if skillshot.skillshot.type == "line" then
                if skillshot.skillshot.collision == "true" and VIP_USER then
                    heropos = Point2(myHero.x, myHero.z)
                    endposition = skillshot.startPosition + (skillshot.endPosition - skillshot.startPosition):normalized() * (heropos:distance(skillshot.startPosition))
                    colstartpos = Vector(skillshot.startPosition.x, myHero.y, skillshot.startPosition.y)
                    colendpos = Vector(endposition.x, myHero.y, endposition.y)
                    collisionshit = CollisionPE(skillshot.skillshot.range, skillshot.skillshot.projectileSpeed, skillshot.skillshot.spellDelay, skillshot.skillshot.radius)
                    if collisionshit:GetMinionCollision(colstartpos, colendpos) then return end
                end
                dodgeLineShot(skillshot)
            else
                dodgeCircularShot(skillshot)
            end
        end
    end

function dodgeCircularShot(skillshot)
    skillshot.evading = true
    alreadydodged = false
    heroPosition = Point2(myHero.x, myHero.z)

    moveableDistance = myHero.ms * math.max(skillshot.endTick - GetTickCount() - GetLatency()/2, 0) / 1000
    evadeRadius = skillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer + moveBuffer

    safeTarget = skillshot.endPosition + (heroPosition - skillshot.endPosition):normalized() * evadeRadius

    if skillshot.skillshot.name == "UFSlash" or skillshot.skillshot.name == "AnnieR" then
        if AM1(skillshot) then
            alreadydodged = true
        elseif AM2(skillshot, heroPosition) then
            alreadydodged = true
        elseif AM3(skillshot, safeTarget) then
            alreadydodged = true
        end
    end
    if not alreadydodged then
        if mainCircularskillshot1(skillshot, heroPosition, moveableDistance, evadeRadius, safeTarget) then
            alreadydodged = true
        elseif mainCircularskillshot2(skillshot) then
            alreadydodged = true
        elseif mainCircularskillshot3(skillshot, heroPosition) then
            alreadydodged = true
        elseif mainCircularskillshot4(skillshot, heroPosition, moveableDistance, evadeRadius, safeTarget) then
            alreadydodged = true
        elseif mainCircularskillshot5(skillshot, safeTarget) then
            alreadydodged = true
        end
    end
end

function haveShield()
    if isSivir and myHero:CanUseSpell(_E) == READY then
        return true 
    end
    if isNocturne and myHero:CanUseSpell(_W) == READY then
        return true 
    end
    return false
end

function FlashTo(x, y)
    CastSpell(flashSlot, x, y)
end


function dodgeLineShot(skillshot)
    alreadydodged = false
    heroPosition = Point2(myHero.x, myHero.z)
    local evadeTo1
    local evadeTo2
    skillshot.evading = true
    skillshotLine = Line2(skillshot.startPosition, skillshot.endPosition)
    distanceFromSkillshotPath = skillshotLine:distance(heroPosition)
    evadeDistance = skillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer + moveBuffer
    normalVector = Point2(skillshot.directionVector.y, -skillshot.directionVector.x):normalized()
    nessecaryMoveWidth = evadeDistance - distanceFromSkillshotPath
    evadeTo1 = heroPosition + normalVector * nessecaryMoveWidth
    evadeTo2 = heroPosition - normalVector * nessecaryMoveWidth
    if skillshot.skillshot.name == "Crescendo" then
        if dodgeCrescendo1(skillshot) then 
        alreadydodged = true
        elseif dodgeCrescendo2(skillshot, evadeTo1, evadeTo2) then
        alreadydodged = true
        end
    end
    if not alreadydodged then
        if lineSkillshot1(skillshot, heroPosition, skillshotLine, distanceFromSkillshotPath, evadeDistance, normalVector, nessecaryMoveWidth, evadeTo1, evadeTo2)
        then alreadydodged = true
    elseif lineSkillshot2(skillshot)
        then alreadydodged = true
    elseif lineSkillshot3(skillshot, evadeTo1, evadeTo2)
        then alreadydodged = true
    elseif lineSkillshot4(skillshot, evadeTo1, evadeTo2)
        then alreadydodged = true
    end
    end
end

function _isDangerSkillshot(skillshot)
    if skillshot.skillshot.name == "LeonaZenithBlade" 
        or skillshot.skillshot.name == "EnchantedArrow" 
        or skillshot.skillshot.name == "LuxMaliceCannon"
        or skillshot.skillshot.name == "SejuaniR"
        or skillshot.skillshot.name == "Crescendo"
        or skillshot.skillshot.name == "TrueshotBarrage"
        or skillshot.skillshot.name == "RocketGrab"
        or skillshot.skillshot.name == "DredgeLine"
        or skillshot.skillshot.name == "ShadowDash"
        or skillshot.skillshot.name == "FizzULT"
        or skillshot.skillshot.name == "VarusR"
        or skillshot.skillshot.name == "SuperMegaDeathRocket"
        or skillshot.skillshot.name == "UFSlash"
        or skillshot.skillshot.name == "LeonaSolarFlare"
        or skillshot.skillshot.name == "AnnieR"
        or skillshot.skillshot.name == "OrianaDetonateCommand"
        then
        return true
    else
        return false
    end 
end

function isreallydangerous(skillshot)
    if skillshot.skillshot.name == "UFSlash"
        or skillshot.skillshot.name == "Crescendo"
        or skillshot.skillshot.name == "FizzULT"
        or skillshot.skillshot.name == "EnchantedArrow"
        or skillshot.skillshot.name == "AnnieR"
        or skillshot.skillshot.name == "OrianaDetonateCommand"
        then return true
    else
        return false
    end
end

function InsideTheWall(evadeTestPoint)
    local heroPosition = Point2(myHero.x, myHero.z)
    local dist = evadeTestPoint:distance(heroPosition)
    local interval = 50
    local nChecks = math.ceil((dist+50)/50)

    if evadeTestPoint.x == 0 or evadeTestPoint.y == 0 then
        return true
    end 
    for k=1, nChecks, 1 do
        local checksPos = evadeTestPoint + (evadeTestPoint - heroPosition):normalized()*(interval*k)
        if IsWall(D3DXVECTOR3(checksPos.x, myHero.y, checksPos.y)) then
            return true
        end
    end
    if IsWall(D3DXVECTOR3(evadeTestPoint.x + 20, myHero.y, evadeTestPoint.y + 20)) then return true end
    if IsWall(D3DXVECTOR3(evadeTestPoint.x + 20, myHero.y, evadeTestPoint.y - 20)) then return true end
    if IsWall(D3DXVECTOR3(evadeTestPoint.x - 20, myHero.y, evadeTestPoint.y - 20)) then return true end
    if IsWall(D3DXVECTOR3(evadeTestPoint.x - 20, myHero.y, evadeTestPoint.y + 20)) then return true end

    return false
end

function findBestDirection(skillshot, referencePoint, possiblePoints)
    if not skillshot then return closestPoint end
    closestPoint = nil
    closestDistance = nil
    side1 = getSideOfLine(skillshot.startPosition, skillshot.endPosition, Point2(myHero.x, myHero.z)) 
    for i, point in pairs(possiblePoints) do
        if point ~= nil and skillshot ~= nil then
            side2 = getSideOfLine(skillshot.startPosition, skillshot.endPosition, point)
            distToSkillshot = Line2(skillshot.startPosition, skillshot.endPosition):distance(point)
            mindistSkillshot = skillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer
            distance = point:distance(referencePoint)
            if (closestDistance == nil or distance <= closestDistance) and not InsideTheWall(point) 
                and distToSkillshot > mindistSkillshot and (side1 == side2 or side1 == 0) then
                closestDistance = distance
                closestPoint = point
            end
        end
    end

    return closestPoint
end

function calculateLongitudinalApproachLength(skillshot, d)
    v1 = skillshot.skillshot.projectileSpeed
    v2 = myHero.ms
    longitudinalDistance = math.max(skillshotPosition(skillshot, GetTickCount()):distance(getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, Point2(myHero.x, myHero.z))) - hitboxSize / 2 - skillshot.skillshot.radius, 0)  + v1 * math.max(skillshot.startTick - GetTickCount(), 0) / 1000

    preResult = -d^2 * v1^4 + d^2 * v2^2 * v1^2 + longitudinalDistance^2 * v2^2 * v1^2
    if preResult >= 0 then
        result = (math.sqrt(preResult) - longitudinalDistance * v2^2) / (v1^2 - v2^2)
        if result >= 0 then
            return result
        end
    end

    return -1
end

function calculateLongitudinalRetreatLength(skillshot, d)
    v1 = skillshot.skillshot.projectileSpeed
    v2 = myHero.ms
    longitudinalDistance = math.max(skillshotPosition(skillshot, GetTickCount()):distance(getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, Point2(myHero.x, myHero.z))) - hitboxSize / 2 - skillshot.skillshot.radius, 0) + v1 * math.max(skillshot.startTick - GetTickCount(), 0) / 1000

    preResult = -d^2 * v1^4 + d^2 * v2^2 * v1^2 + longitudinalDistance^2 * v2^2 * v1^2
    if preResult >= 0 then
        result = (math.sqrt(preResult) + longitudinalDistance * v2^2) / (v1^2 - v2^2)
        if result >= 0 then
            return result
        end
    end

    return -1
end

function inDangerousArea(skillshot, coordinate)
    if skillshot.skillshot.type == "line" then
        return inRange(skillshot, coordinate) 
        and not skillshotHasPassed(skillshot, coordinate) 
        and Line2(skillshot.startPosition, skillshot.endPosition):distance(coordinate) < (skillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer) 
        and coordinate:distance(skillshot.startPosition + skillshot.directionVector) <= coordinate:distance(skillshot.startPosition - skillshot.directionVector)
    else
        return coordinate:distance(skillshot.endPosition) <= skillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer
    end
end

function inRange(skillshot, coordinate)
    return getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, coordinate):distance(skillshot.startPosition) <= skillshot.skillshot.range
end

function OnCreateObj(object)
    if object ~= nil and object.type == "obj_GeneralParticleEmmiter" then
        for i, skillShotChampion in pairs(champions) do
            for i, skillshot in pairs(skillShotChampion.skillshots) do
                if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 then
                    if skillshot.projectileName == object.name then
                        for i, detectedSkillshot in pairs(detectedSkillshots) do
                            if detectedSkillshot.skillshot.projectileName == skillshot.projectileName then
                                return
                            end
                        end
                        for i = 1, heroManager.iCount, 1 do
                            currentHero = heroManager:GetHero(i)
                            if currentHero.team == myHero.team and skillShotChampion.charName == currentHero.charName then
                                return
                            end
                        end

                        if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 or (GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 1 and nEnemies <= 2 and not (GoodEvadeConfig.dodgeCConly or GoodEvadeConfig.dodgeCConly2)) then
                    if skillshot.type == "line" then
                        skillshotToAdd = {object = object, startPosition = nil, endPosition = nil, directionVector = nil, startTick = GetTickCount(), endTick = GetTickCount() + skillshot.range/skillshot.projectileSpeed*1000, skillshot = skillshot, evading = false, drawit = true, alreadydashed = false}
                            elseif skillshot.type == "circular" then
                                endPosition = Point2(object.x, object.z)
                                startPosition = Point2(object.x, object.z)
                                table.insert(detectedSkillshots, {startPosition = startPosition, endPosition = endPosition, 
                                    directionVector = (endPosition - startPosition):normalized(), startTick = GetTickCount() + skillshot.spellDelay, 
                                    endTick = GetTickCount() + skillshot.spellDelay + skillshot.projectileSpeed, skillshot = skillshot, evading = false, drawit = false, alreadydashed = false})
                            end
                        end
                        return
                    end
                end
            end
        end
    end
end
function OnAnimation(unit, animationName)
if CastingSpell == true then
    if unit.isMe and (animationName == "Idle1" or animationName == "Run") then CastingSpell = false end
end
end

function OnProcessSpell(unit, spell)
    if unit.isMe and myHero.charName == "MasterYi" and spell.name == myHero:GetSpellData(_W).name then
        CastingSpell = true
    elseif unit.isMe and myHero.charName == "Nunu" and spell.name == myHero:GetSpellData(_R).name then
        CastingSpell = true
    elseif unit.isMe and myHero.charName == "MissFortune" and spell.name == myHero:GetSpellData(_R).name then
        CastingSpell = true
    elseif unit.isMe and myHero.charName == "Malzahar" and spell.name == myHero:GetSpellData(_R).name then
        CastingSpell = true
    elseif unit.isMe and myHero.charName == "Katarina" and spell.name == myHero:GetSpellData(_R).name then
        CastingSpell = true
    elseif unit.isMe and myHero.charName == "Janna" and spell.name == myHero:GetSpellData(_R).name then
        CastingSpell = true
    elseif unit.isMe and myHero.charName == "Galio" and spell.name == myHero:GetSpellData(_R).name then
        CastingSpell = true
    elseif unit.isMe and myHero.charName == "FiddleSticks" and spell.name == myHero:GetSpellData(_W).name then
        CastingSpell = true
    elseif unit.isMe and myHero.charName == "FiddleSticks" and spell.name == myHero:GetSpellData(_R).name then
        CastingSpell = true
    end
    if unit.isMe and isLeblanc then
        if spell.name == myHero:GetSpellData(_Q).name then lastspell = "Q"
        elseif spell.name == myHero:GetSpellData(_W).name then lastspell = "W"
        elseif spell.name == myHero:GetSpellData(_E).name then lastspell = "E"
        end
    end
    if not myHero.dead and unit.team ~= myHero.team then
        for i, skillShotChampion in pairs(champions) do
            if skillShotChampion.charName == unit.charName then
                for i, skillshot in pairs(skillShotChampion.skillshots) do
                    if skillshot.spellName == spell.name then
                        startPosition = Point2(spell.startPos.x, spell.startPos.z)
                        endPosition = Point2(spell.endPos.x, spell.endPos.z)
                            if isOrianna and unit.charName == "Orianna" then
                                ball = nil
                                for i = 1, objManager.maxObjects, 1 do
                                local obj = objManager:GetObject(i)
                                CheckBall(obj)
                                end
                                if ball ~= nil then 
                                    startPosition = Point2(ball.x, ball.z)
                                    if skillshot.spellName == "OrianaDetonateCommand" then
                                        endPosition = Point2(ball.x, ball.z)
                                    end
                                end
                            end
                        directionVector = (endPosition - startPosition):normalized()
                        if isOrianna and unit.charName == "Orianna" then
                        if skillshot.spellName == "OrianaIzunaCommand" then skillshot.range = startPosition:distance(endPosition) end
                    end
                        if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 or (GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 1 and nEnemies <= 2 and not (GoodEvadeConfig.dodgeCConly or GoodEvadeConfig.dodgeCConly2)) then
                            if skillshot.type == "line" then
                                table.insert(detectedSkillshots, {startPosition = startPosition, endPosition = startPosition + directionVector * skillshot.range,
                                    directionVector = directionVector, startTick = GetTickCount() + skillshot.spellDelay, 
                                    endTick = GetTickCount() + skillshot.spellDelay + skillshot.range/skillshot.projectileSpeed*1000, skillshot = skillshot, evading = false, drawit = true, alreadydashed = false})
                            elseif skillshot.type == "circular" then
                                table.insert(detectedSkillshots, {startPosition = startPosition, endPosition = endPosition, 
                                    directionVector = directionVector, startTick = GetTickCount() + skillshot.spellDelay, 
                                    endTick = GetTickCount() + skillshot.spellDelay + skillshot.projectileSpeed, skillshot = skillshot, evading = false, drawit = true, alreadydashed = false})
                            else
                                local ssrange = endPosition:distance(startPosition)
                                table.insert(detectedSkillshots, {startPosition = startPosition, endPosition = endPosition, 
                                    directionVector = directionVector, startTick = GetTickCount() + skillshot.spellDelay, 
                                    endTick = GetTickCount() + skillshot.spellDelay + (skillshot.projectileSpeed * (ssrange/skillshot.range)), skillshot = skillshot, evading = false, drawit = true, alreadydashed = false})
                            end
                        end
                        return
                    end
                end
            end
        end
    end
end

function skillshotPosition(skillshot, tickCount)
    if skillshot.skillshot.type == "line" then
        return skillshot.startPosition + skillshot.directionVector * math.max(tickCount - skillshot.startTick, 0) * skillshot.skillshot.projectileSpeed / 1000
    else
        return skillshot.endPosition
    end
end

function skillshotHasPassed(skillshot, coordinate)
    footOfPerpendicular = getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, coordinate)
    currentSkillshotPosition = skillshotPosition(skillshot, GetTickCount() - 2 * GetLatency())
    side1 = getSideOfLine(coordinate, footOfPerpendicular, currentSkillshotPosition)
    side2 =  getSideOfLine(coordinate, footOfPerpendicular, skillshot.startPosition)
    return side1 ~= side2 and currentSkillshotPosition:distance(footOfPerpendicular) >= (skillshot.skillshot.radius + hitboxSize / 2)
end

function getPerpendicularFootpoint(linePoint1, linePoint2, point)
distanceFromLine = Line2(linePoint1, linePoint2):distance(point)
directionVector = (linePoint2 - linePoint1):normalized()

footOfPerpendicular = point + Point2(-directionVector.y, directionVector.x) * distanceFromLine
if Line2(linePoint1, linePoint2):distance(footOfPerpendicular) > distanceFromLine then
footOfPerpendicular = point - Point2(-directionVector.y, directionVector.x) * distanceFromLine
end

return footOfPerpendicular
end

function OnTick()
    if GoodEvadeConfig.freemovementblock then
        if evading and not alreadywritten then
            local file = io.open(thatfile, "w")
            file:write("1")
            file:close()
            alreadywritten = true
        elseif not evading and alreadywritten then
            local file = io.open(thatfile, "w")
            file:write("0")
            file:close()
            alreadywritten = false
        end
        if not wrotedisclaimer then
            PrintChat("<font color=\"#FF0000\" >You just enabled free user movement block, this function will only work if you followed tutorial in main thread of the script before allowing it.</font>")
        wrotedisclaimer = true
        end
    end
        if skillshotToAdd ~= nil and skillshotToAdd.object ~= nil and skillshotToAdd.object.valid and (GetTickCount() - skillshotToAdd.startTick) >= GoodEvadeConfig.fowdelay and skillshotToAdd.startPosition == nil then
            skillshotToAdd.startPosition = Point2(skillshotToAdd.object.x, skillshotToAdd.object.z)
        elseif skillshotToAdd ~= nil and skillshotToAdd.object ~= nil and skillshotToAdd.object.valid and (GetTickCount() - skillshotToAdd.startTick) >= (GoodEvadeConfig.fowdelay+1) then
        skillshotToAdd.directionVector = (Point2(skillshotToAdd.object.x, skillshotToAdd.object.z) - skillshotToAdd.startPosition):normalized()
        skillshotToAdd.endPosition = skillshotToAdd.startPosition + skillshotToAdd.directionVector * skillshotToAdd.skillshot.range        
        table.insert(detectedSkillshots, skillshotToAdd)
        skillshotToAdd = nil
        end
    if shieldtick ~= nil then
        if GetTickCount() >= shieldtick then
            if haveShield() then
                if isSivir then
                    CastSpell(_E)
                elseif isNocturne then
                    CastSpell(_W)
                end
                else shieldtick = nil
                end
            end
        end
            if evading then
                for i, detectedSkillshot in pairs(detectedSkillshots) do
                    if detectedSkillshot and detectedSkillshot.evading and inDangerousArea(detectedSkillshot, Point2(myHero.x, myHero.z)) then
                        dodgeSkillshot(detectedSkillshot)
                    end
                end
            end
        if haveflash then 
            if myHero:CanUseSpell(flashSlot) == READY then 
                flashready = true 
                else flashready = false 
                end
            end
            if GoodEvadeConfig.resetdodge then
                stopEvade()
                detectedSkillshots = {}
            end
            if AutoCarry ~= nil then
                if AutoCarry.MainMenu ~= nil then 
                    if AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.LastHit or AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear
                        then
                        if not bufferset then
                            currentbuffer = GoodEvadeConfig.evadeBuffer
                            bufferset = true
                        end
                        if not VIP_USER then
                            if lastset < GetTickCount()
                                then lastMovement.destination = Point2(mousePos.x, mousePos.z)
                                lastset = GetTickCount() + 100
                            end
                        end
                    end
                elseif AutoCarry.Keys ~= nil then
                    if AutoCarry.Keys.AutoCarry or AutoCarry.Keys.MixedMode or AutoCarry.Keys.LastHit or AutoCarry.Keys.LaneClear then
                        if not bufferset then
                            currentbuffer = GoodEvadeConfig.evadeBuffer
                            bufferset = true
                        end
                        if not VIP_USER then
                            if lastset < GetTickCount()
                                then lastMovement.destination = Point2(mousePos.x, mousePos.z)
                                lastset = GetTickCount() + 100
                            end
                        end
                    end
                end
            elseif MMA_Loaded ~= nil then
                if _G.MMA_Orbwalker or _G.MMA_HybridMode or _G.MMA_LaneClear or _G.MMA_LastHit then
                    if not bufferset then
                        currentbuffer = GoodEvadeConfig.evadeBuffer
                        bufferset = true
                    end
                    if not VIP_USER then
                        if lastset < GetTickCount()
                            then lastMovement.destination = Point2(mousePos.x, mousePos.z)
                            lastset = GetTickCount() + 100
                        end
                    end
                end
            end
            nSkillshots = 0
            for _, detectedSkillshot in pairs(detectedSkillshots) do
                if detectedSkillshot then nSkillshots = nSkillshots + 1 end
            end

            if not allowCustomMovement and nSkillshots == 0 then
                stopEvade()
            end

            hitboxSize = GetDistance(myHero.minBBox, myHero.maxBBox)

            nEnemies = CountEnemyHeroInRange(1500)
            table.sort(enemyes, function(x,y) return GetDistance(x) < GetDistance(y) end)


            heroPosition = Point2(myHero.x, myHero.z)
            for i, detectedSkillshot in ipairs(detectedSkillshots) do
                if detectedSkillshot.endTick <= GetTickCount() then
                table.remove(detectedSkillshots, i)
                i = i-1
                if detectedSkillshot.evading then
                    continueMovement(detectedSkillshot)
                end
            else
                if evading then
                    if detectedSkillshot.evading and not inDangerousArea(detectedSkillshot, heroPosition) then
                        if detectedSkillshot.skillshot.type == "line" then

                            side1 = getSideOfLine(detectedSkillshot.startPosition, detectedSkillshot.endPosition, heroPosition) 
                            side2 = getSideOfLine(detectedSkillshot.startPosition, detectedSkillshot.endPosition, getLastMovementDestination())
                            if skillshotHasPassed(detectedSkillshot, heroPosition) then
                                continueMovement(detectedSkillshot)

                            elseif not inDangerousArea(detectedSkillshot, getLastMovementDestination()) and (side1 == side2) and (side1 ~= 0) then
                                continueMovement(detectedSkillshot)

                            elseif not inRange(detectedSkillshot, heroPosition) and not inRange(detectedSkillshot, getLastMovementDestination()) then
                                continueMovement(detectedSkillshot)

                            elseif lastMovement.approachedPoint ~= getLastMovementDestination() then
                                footpoint = getPerpendicularFootpoint(detectedSkillshot.startPosition, detectedSkillshot.endPosition, getLastMovementDestination())
                                closestSafePoint = footpoint + Point2(-detectedSkillshot.directionVector.y, detectedSkillshot.directionVector.x) * (detectedSkillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer + moveBuffer)
                                if (getSideOfLine(detectedSkillshot.startPosition, detectedSkillshot.endPosition, heroPosition) ~= getSideOfLine(detectedSkillshot.startPosition, detectedSkillshot.endPosition, closestSafePoint)) then
                                closestSafePoint = footpoint - Point2(-detectedSkillshot.directionVector.y, detectedSkillshot.directionVector.x) * (detectedSkillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer + moveBuffer)
                            end

                            captureMovements = false
                            allowCustomMovement = true
                            if skillshot ~= nil then if skillshot.spellName ~= nil then if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 and (nSkillshots > 1) and NeedDash(skillshot, true) then DashTo(closestSafePoint.x, closestSafePoint.y) end end
                            myHero:MoveTo(closestSafePoint.x, closestSafePoint.y)
                            lastMovement.moveCommand = Point2(closestSafePoint.x, closestSafePoint.y)
                            allowCustomMovement = false
                            captureMovements = true

                            lastMovement.approachedPoint = getLastMovementDestination()
                        end
                    end
                else
                    evadeRadius = detectedSkillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer + moveBuffer
                    directionVector = (heroPosition - detectedSkillshot.endPosition):normalized()
                    tangentDirectionVector = Point2(-directionVector.y, directionVector.x)
                    movementTargetSideOfLine = getSideOfLine(heroPosition, heroPosition + tangentDirectionVector, getLastMovementDestination())
                    skillshotSideOfLine = getSideOfLine(heroPosition, heroPosition + tangentDirectionVector, detectedSkillshot.endPosition)

                    if movementTargetSideOfLine == 0 or movementTargetSideOfLine ~= skillshotSideOfLine then
                        continueMovement(detectedSkillshot)
                    else
                        if getLastMovementDestination():distance(detectedSkillshot.endPosition) <= evadeRadius then
                        closestTarget = detectedSkillshot.endPosition + (getLastMovementDestination() - detectedSkillshot.endPosition):normalized() * evadeRadius
                    else
                        closestTarget = nil
                    end

                    dx = detectedSkillshot.endPosition.x - heroPosition.x
                    dy = detectedSkillshot.endPosition.y - heroPosition.y
                    D_squared = dx * dx + dy * dy
                    if D_squared < evadeRadius * evadeRadius then
                        safePoint1 = heroPosition - tangentDirectionVector * (evadeRadius / 2 + smoothing)
                        safePoint2 = heroPosition + tangentDirectionVector * (evadeRadius / 2 + smoothing)
                    else
                        intersectionPoints = Circle2(detectedSkillshot.endPosition, evadeRadius):intersectionPoints(Circle2(heroPosition, math.sqrt(D_squared - evadeRadius * evadeRadius)))
                        if #intersectionPoints == 2 then
                            safePoint1 = heroPosition - (heroPosition - intersectionPoints[1]):normalized() * (evadeRadius / 2 + smoothing)
                            safePoint2 = heroPosition - (heroPosition - intersectionPoints[2]):normalized() * (evadeRadius / 2 + smoothing)
                        else
                            safePoint1 = heroPosition - tangentDirectionVector * (evadeRadius / 2 + smoothing)
                            safePoint2 = heroPosition + tangentDirectionVector * (evadeRadius / 2 + smoothing)
                        end
                    end

                    local theta = ((-detectedSkillshot.endPosition + safePoint2):polar() - (-detectedSkillshot.endPosition + safePoint1):polar()) % 360
                    if closestTarge and (
                        (
                            theta < 180 and (
                                getSideOfLine(detectedSkillshot.endPosition, safePoint2, closestTarget) == getSideOfLine(detectedSkillshot.endPosition, safePoint2, heroPosition) and
                                getSideOfLine(detectedSkillshot.endPosition, safePoint1, closestTarget) == getSideOfLine(detectedSkillshot.endPosition, safePoint1, heroPosition)
                                )
                            ) or (
                            theta > 180 and (
                                getSideOfLine(detectedSkillshot.endPosition, safePoint2, closestTarget) == getSideOfLine(detectedSkillshot.endPosition, safePoint2, heroPosition) or
                                getSideOfLine(detectedSkillshot.endPosition, safePoint1, closestTarget) == getSideOfLine(detectedSkillshot.endPosition, safePoint1, heroPosition)
                                )
                            )
                            ) then
                    possibleMovementTargets = {closestTarget, safePoint1, safePoint2}
                else
                    possibleMovementTargets = {safePoint1, safePoint2}
                end

                closestPoint = findBestDirection(skillshot,getLastMovementDestination(), possibleMovementTargets)
                if closestPoint ~= nil then
                    captureMovements = false
                    allowCustomMovement = true
                    if skillshot ~= nil then if skillshot.spellName ~= nil then if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 and (nSkillshots > 1) and NeedDash(skillshot, true) then DashTo(closestPoint.x, closestPoint.y) end
                    myHero:MoveTo(closestPoint.x, closestPoint.y)
                    lastMovement.moveCommand = Point2(closestPoint.x, closestPoint.y)
                    allowCustomMovement = false
                    captureMovements = true
                end
            end
        end
    end
end
end
elseif inDangerousArea(detectedSkillshot, heroPosition) then
    dodgeSkillshot(detectedSkillshot)
end
end
end
end

function DashTo(x, y)
    if GoodEvadeConfig.usedashes then
        if isVayne and  myHero:CanUseSpell(_Q) == READY then
            CastSpell(_Q, x, y)
        elseif isRiven and  myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, x, y)
        elseif isGraves and myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, x, y)
        elseif isEzreal and myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, x, y)
        elseif isKassadin and myHero:CanUseSpell(_R) == READY then
            CastSpell(_R, x, y)
        elseif isLeblanc and myHero:CanUseSpell(_W) == READY then
            CastSpell(_W, x, y)
        elseif isLeblanc and myHero:CanUseSpell(_R) == READY and lastspell == "W" then
            CastSpell(_R, x, y)
        elseif isFizz and myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, x, y)
        elseif isShaco and myHero:CanUseSpell(_Q) == READY then
            CastSpell(_Q, x, y)
        elseif isCorki and myHero:CanUseSpell(_W) == READY then
            CastSpell(_W, x, y)
        elseif isRenekton and myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, x, y)
        elseif isLucian and myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, x, y)
        elseif haveflash and flashready and useflash and GoodEvadeConfig.useflash then
            CastSpell(flashSlot, x, y)
            useflash = false
        elseif isCaitlyn and myHero:CanUseSpell(_E) == READY then
            myPos = Point2(myHero.x, myHero.z)
            castpos = myPos + (myPos - (Point2(x, y)))
            CastSpell(_E, castpos.x, castpos.y)
        elseif isTristana and myHero:CanUseSpell(_W) == READY then
            CastSpell(_W, x, y)
        elseif isShen and myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, x, y) 
        elseif isTryndamere and myHero:CanUseSpell(_E) == READY then
            CastSpell(_E, x, y)
        end   
    end                          
end
function NeedDash(skillshot, forceDash)
    if GoodEvadeConfig.usedashes then
        useflash = false
        local hp = myHero.health / myHero.maxHealth
    if isVayne and myHero:CanUseSpell(_Q) == READY and skillshot.skillshot.cc == "true" then
        if forceDash or hp < 0.4 then 
        dashrange = 300
        return true end
        if nSkillshots > 1 or _isDangerSkillshot(skillshot) then 
        dashrange = 300
        return true end
    elseif isRiven and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
        if forceDash or hp < 0.4 then 
        dashrange = 325 
        return true end
        if nSkillshots > 1 or _isDangerSkillshot(skillshot) then 
        dashrange = 325
    return true end
    elseif isGraves and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
    if forceDash or hp < 0.4 then
    dashrange = 425
    return true end
    if _isDangerSkillshot(skillshot) then
    dashrange = 425
    return true end
    if _isDangerSkillshot(skillshot) then
    dashrange = 660
    return true end
    elseif isShaco and myHero:CanUseSpell(_Q) == READY and skillshot.skillshot.cc == "true" then
    if skillshot or hp < 0.4 then
    dashrange = 400
    return true end
    if _isDangerSkillshot(skillshot) then
        dashrange = 400
        return true end
    elseif isEzreal and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
    if forceDash or hp < 0.4 then
        dashrange = 450
        return true end
    if _isDangerSkillshot(skillshot) then
        dashrange = 450
        return true end
    elseif isFizz and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
    if skillshot or hp < 0.4 then
        dashrange = 400
        return true end
    if _isDangerSkillshot(skillshot) then
        dashrange = 400
        return true end
    elseif isKassadin and myHero:CanUseSpell(_R) == READY and skillshot.skillshot.cc == "true" then
    if forceDash or hp < 0.4 then
        dashrange = 700
        return true end
    if _isDangerSkillshot(skillshot) then
        dashrange = 700
        return true end
    elseif isLeblanc and myHero:CanUseSpell(_W) == READY and skillshot.skillshot.cc == "true" then
    if forceDash or hp < 0.4 then
        dashrange = 600
        return true end
    if _isDangerSkillshot(skillshot) then
        dashrange = 600
        return true end
    elseif isLeblanc and myHero:CanUseSpell(_R) == READY and skillshot.skillshot.cc == "true" and lastspell == "W" then
    if forceDash or hp < 0.4 then
        dashrange = 600
        return true end
    if _isDangerSkillshot(skillshot) then
    dashrange = 600
    return true end
    elseif isRenekton and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
        if forceDash or hp < 0.4 then
        dashrange = 450
    return true end
    if _isDangerSkillshot(skillshot) then
        dashrange = 450
        return true end
    elseif isCorki and myHero:CanUseSpell(_W) == READY and skillshot.skillshot.cc == "true" then
    if _isDangerSkillshot(skillshot) then
        dashrange = 800
        return true end
    elseif isLucian and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
    if forceDash or hp < 0.4 then
        dashrange = 425
        return true end
    if _isDangerSkillshot(skillshot) then
        dashrange = 425
        return true end
    elseif haveflash and flashready and GoodEvadeConfig.useflash and isreallydangerous(skillshot) then
        dashrange = 400
        useflash = true
        return true
    elseif isTryndamere and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
    if forceDash or hp < 0.4 then
        dashrange = 660
        return true end
    elseif isCaitlyn and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
    if forceDash or hp < 0.4 then
        dashrange = 400
        return true end
    elseif isTristana and myHero:CanUseSpell(_W) == READY and skillshot.skillshot.cc == "true" then
    if _isDangerSkillshot(skillshot) then
        dashrange = 900
        return true end
    elseif isShen and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
    if forceDash or hp < 0.4 then
        dashrange = 600
    return true end
    if _isDangerSkillshot(skillshot) then
        dashrange = 600
    return true end
        end                              
        return false
    end
end

function evadeTo(x, y, forceDash)
startEvade()
evadePoint = Point2(x, y)
allowCustomMovement = true
captureMovements = false
if forceDash then
    local evadePos = Point2(x, y)
    local myPos = Point2(myHero.x, myHero.z)
    local ourdistance = evadePos:distance(myPos)
local dashPos = myPos - (myPos - evadePos):normalized() * dashrange
    DashTo(dashPos.x, dashPos.y) 
end    
myHero:MoveTo(x, y)
lastMovement.moveCommand = Point2(x, y)
captureMovements = true
allowCustomMovement = false
evading = true
evadingTick = GetTickCount()
end

function continueMovement(skillshot)
if VIP_USER then
if evading then
skillshot.evading = false
lastMovement.approachedPoint = nil

stopEvade()

if lastMovement.type == 2 then
captureMovements = false
myHero:MoveTo(getLastMovementDestination().x, getLastMovementDestination().y)
captureMovements = true
elseif lastMovement.type == 3 then
target = getTarget(lastMovement.targetId)

if _isValidTarget(target) then
captureMovements = false
myHero:Attack(target)
captureMovements = true
else
captureMovements = false
myHero:MoveTo(myHero.x, myHero.z)
captureMovements = true
end
elseif lastMovement.type == 10 then
myHero:HoldPosition()
elseif lastMovement.type == 7 then
                lastMovement.type = 3
            end
        end
    elseif evading then
        skillshot.evading = false
        lastMovement.approachedPoint = nil
        stopEvade()    
        if continuetarget == nil then
            captureMovements = false
            myHero:MoveTo(getLastMovementDestination().x, getLastMovementDestination().y)
            captureMovements = true
        elseif continuetarget ~= nil then
            target = continuetarget
            if _isValidTarget(target) then
                captureMovements = false
                myHero:Attack(target)
                captureMovements = true
            else
                captureMovements = false
                myHero:MoveTo(myHero.x, myHero.z)
                captureMovements = true
            end
        end
    end
end

function drawLineshit(point1, point2, color, width)
    x1, y1, onScreen1 = get2DFrom3D(point1.x, myHero.y, point1.y)
    x2, y2, onScreen2 = get2DFrom3D(point2.x, myHero.y, point2.y)

    DrawLine(x1, y1, x2, y2, width, color)
end   
function OnDraw()
    if GoodEvadeConfig.drawEnabled then
        for i, detectedSkillshot in pairs(detectedSkillshots) do
            skillshotPos = skillshotPosition(detectedSkillshot, GetTickCount())
            if detectedSkillshot.drawit == true then
                if detectedSkillshot.skillshot.type == "line" then
                    drawLineshit(detectedSkillshot.startPosition, detectedSkillshot.endPosition, 0xFFFF0000, 3)
                DrawCircle(skillshotPos.x, myHero.y, skillshotPos.y, detectedSkillshot.skillshot.radius, 0xFFFFFF)
            else
                DrawCircle(skillshotPos.x, myHero.y, skillshotPos.y, detectedSkillshot.skillshot.radius, 0x00FF00)
            end
        end
    end
end
end

function _isValidTarget(target)
    return target ~= nil and target.valid and target.dead == false and target.bTargetable and target.bMagicImunebMagicImune ~= true and target.bInvulnerable ~= true and target.visible
end

function startEvade()
    allowCustomMovement = false
    if AutoCarry 
        then if AutoCarry.MainMenu ~= nil then
        if AutoCarry.CanAttack ~= nil then
     _G.AutoCarry.CanAttack = false
     _G.AutoCarry.CanMove = false
 end
 elseif AutoCarry.Keys ~= nil then
    if AutoCarry.MyHero ~= nil then
    _G.AutoCarry.MyHero:MovementEnabled(false)
    _G.AutoCarry.MyHero:AttacksEnabled(false)
end
end
elseif MMA_Loaded then
    _G.MMA_AttackAvailable = false
    _G.MMA_AbleToMove = false
end
_G.evade = true
evading = true
end

function stopEvade()
    allowCustomMovement = true
        if AutoCarry then if AutoCarry.MainMenu ~= nil then
        if AutoCarry.CanAttack ~= nil then
     _G.AutoCarry.CanAttack = true
     _G.AutoCarry.CanMove = true
 end
 elseif AutoCarry.Keys ~= nil then
    if AutoCarry.MyHero ~= nil then
    _G.AutoCarry.MyHero:MovementEnabled(true)
    _G.AutoCarry.MyHero:AttacksEnabled(true)
end
end
elseif MMA_Loaded then
    _G.MMA_AttackAvailable = true
    _G.MMA_AbleToMove = true
end
_G.evade = false
evading = false
end

function OnWndMsg(msg, key)
    if not VIP_USER then
        if msg == WM_RBUTTONDOWN then
          if evading then
            for i, detectedSkillshot in pairs(detectedSkillshots) do
                if detectedSkillshot and detectedSkillshot.evading and inDangerousArea(detectedSkillshot, Point2(myHero.x, myHero.z)) then
                    dodgeSkillshot(detectedSkillshot)
                end
            end
        end
        lastMovement.destination = Point2(mousePos.x, mousePos.z)
    end 
end
end
-- beggining of circular skillshot dodging functions --
function mainCircularskillshot5(skillshot, safeTarget)
    if NeedDash(skillshot, true) and not skillshot.alreadydashed then 
        evadeTo(safeTarget.x, safeTarget.y, true)
        skillshot.alreadydashed = true
        return true
        else return false
    end
    return false
end

    function mainCircularskillshot4(skillshot, heroPosition, moveableDistance, evadeRadius, safeTarget)
        if NeedDash(skillshot, true) and not skillshot.alreadydashed then
            moveableDistance = (myHero.ms * math.max(skillshot.endTick - GetTickCount() - GetLatency()/2, 0) / 1000) + dashrange
            evadeRadius = skillshot.skillshot.radius + hitboxSize / 2 + GoodEvadeConfig.evadeBuffer + moveBuffer

            safeTarget = skillshot.endPosition + (heroPosition - skillshot.endPosition):normalized() * evadeRadius 
if getLastMovementDestination():distance(skillshot.endPosition) <= evadeRadius then
            closestTarget = skillshot.endPosition + (getLastMovementDestination() - skillshot.endPosition):normalized() * evadeRadius
        else
            closestTarget = nil
        end

        lineDistance = Line2(heroPosition, getLastMovementDestination()):distance(skillshot.endPosition)
        directionTarget = heroPosition + (getLastMovementDestination() - heroPosition):normalized() * (math.sqrt(heroPosition:distance(skillshot.endPosition)^2 - lineDistance^2) + math.sqrt(evadeRadius^2 - lineDistance^2))
        if directionTarget:distance(skillshot.endPosition) >= evadeRadius + 1 then
        directionTarget = heroPosition + (getLastMovementDestination() - heroPosition):normalized() * (math.sqrt(evadeRadius^2 - lineDistance^2) - math.sqrt(heroPosition:distance(skillshot.endPosition)^2 - lineDistance^2))
    end

    possibleMovementTargets = {}
    intersectionPoints = Circle2(skillshot.endPosition, evadeRadius):intersectionPoints(Circle2(heroPosition, moveableDistance))
    if #intersectionPoints == 2 then
        leftTarget = intersectionPoints[1]
        rightTarget = intersectionPoints[2]

        local theta = ((-skillshot.endPosition + leftTarget):polar() - (-skillshot.endPosition + rightTarget):polar()) % 360
        if ((theta >= 180 and getSideOfLine(skillshot.endPosition, leftTarget, directionTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) and getSideOfLine(skillshot.endPosition, rightTarget, directionTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)) or (theta <= 180 and (getSideOfLine(skillshot.endPosition, leftTarget, directionTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) or getSideOfLine(skillshot.endPosition, rightTarget, directionTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)))) then
            table.insert(possibleMovementTargets, directionTarget)
        end
 
        if closestTarget ~= nil and ((theta >= 180 and getSideOfLine(skillshot.endPosition, leftTarget, closestTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) and getSideOfLine(skillshot.endPosition, rightTarget, closestTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)) or (theta <= 180 and (getSideOfLine(skillshot.endPosition, leftTarget, closestTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) or getSideOfLine(skillshot.endPosition, rightTarget, closestTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)))) then
            table.insert(possibleMovementTargets, closestTarget)
        end


    table.insert(possibleMovementTargets, safeTarget)
    table.insert(possibleMovementTargets, leftTarget)
    table.insert(possibleMovementTargets, rightTarget)
else
    if skillshot.skillshot.radius <= moveableDistance then
        table.insert(possibleMovementTargets, closestTarget)
        table.insert(possibleMovementTargets, directionTarget)
        table.insert(possibleMovementTargets, safeTarget)
    end
end

closestPoint = findBestDirection(skillshot, getLastMovementDestination(), possibleMovementTargets)
if closestPoint ~= nil then
    closestPoint = closestPoint + (closestPoint - heroPosition):normalized() * smoothing
    evadeTo(closestPoint.x, closestPoint.y, true)
    skillshot.alreadydashed = true
    return true
    else return false
    end
    else return false
    end
    return false
end

function mainCircularskillshot3(skillshot, heroPosition)
    if getLastMovementDestination():distance(heroPosition) > 20 and NeedDash(skillshot, true) and not skillshot.alreadydashed then
        dashpos = getLastMovementDestination() + (getLastMovementDestination() - heroPosition):normalized() * dashrange
        if dashpos:distance(skillshot.endPosition) > skillshot.skillshot.radius and not InsideTheWall(dashpos) then
        evadeTo(dashpos.x, dashpos.y, true)
        skillshot.alreadydashed = true
        return true
        else return false
        end
        else return false
        end
        return false
end

function mainCircularskillshot2(skillshot)
        if haveShield() then 
            for i, detectedSkillshot in ipairs(detectedSkillshots) do
                if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
                    table.remove(detectedSkillshots, i)
                    i = i-1
                    if detectedSkillshot.evading then
                        continueMovement(detectedSkillshot)
                    end
                end
            end
            if skillshot.skillshot.shieldnow == "true" then 
                if isSivir then
                    CastSpell(_E)
                elseif isNocturne then
                    CastSpell(_W)
                end
                return true
            elseif skillshot.skillshot.shieldnow == "false" then
                shieldtick = skillshot.endTick - 50 - GetLatency()
                return true
            end
            else return false
            end
            return false
        end

function mainCircularskillshot1(skillshot, heroPosition, moveableDistance, evadeRadius, safeTarget)
               if getLastMovementDestination():distance(skillshot.endPosition) <= evadeRadius then
            closestTarget = skillshot.endPosition + (getLastMovementDestination() - skillshot.endPosition):normalized() * evadeRadius
        else
            closestTarget = nil
        end

        lineDistance = Line2(heroPosition, getLastMovementDestination()):distance(skillshot.endPosition)
        directionTarget = heroPosition + (getLastMovementDestination() - heroPosition):normalized() * (math.sqrt(heroPosition:distance(skillshot.endPosition)^2 - lineDistance^2) + math.sqrt(evadeRadius^2 - lineDistance^2))
        if directionTarget:distance(skillshot.endPosition) >= evadeRadius + 1 then
        directionTarget = heroPosition + (getLastMovementDestination() - heroPosition):normalized() * (math.sqrt(evadeRadius^2 - lineDistance^2) - math.sqrt(heroPosition:distance(skillshot.endPosition)^2 - lineDistance^2))
    end

    possibleMovementTargets = {}
    intersectionPoints = Circle2(skillshot.endPosition, evadeRadius):intersectionPoints(Circle2(heroPosition, moveableDistance))
    if #intersectionPoints == 2 then
        leftTarget = intersectionPoints[1]
        rightTarget = intersectionPoints[2]

        local theta = ((-skillshot.endPosition + leftTarget):polar() - (-skillshot.endPosition + rightTarget):polar()) % 360
        if ((theta >= 180 and getSideOfLine(skillshot.endPosition, leftTarget, directionTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) and getSideOfLine(skillshot.endPosition, rightTarget, directionTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)) or (theta <= 180 and (getSideOfLine(skillshot.endPosition, leftTarget, directionTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) or getSideOfLine(skillshot.endPosition, rightTarget, directionTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)))) then
            table.insert(possibleMovementTargets, directionTarget)
        end
 
        if closestTarget ~= nil and ((theta >= 180 and getSideOfLine(skillshot.endPosition, leftTarget, closestTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) and getSideOfLine(skillshot.endPosition, rightTarget, closestTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)) or (theta <= 180 and (getSideOfLine(skillshot.endPosition, leftTarget, closestTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) or getSideOfLine(skillshot.endPosition, rightTarget, closestTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)))) then
            table.insert(possibleMovementTargets, closestTarget)
        end


    table.insert(possibleMovementTargets, safeTarget)
    table.insert(possibleMovementTargets, leftTarget)
    table.insert(possibleMovementTargets, rightTarget)
else
    if skillshot.skillshot.radius <= moveableDistance then
        table.insert(possibleMovementTargets, closestTarget)
        table.insert(possibleMovementTargets, directionTarget)
        table.insert(possibleMovementTargets, safeTarget)
    end
end

closestPoint = findBestDirection(skillshot, getLastMovementDestination(), possibleMovementTargets)
if closestPoint ~= nil then
    closestPoint = closestPoint + (closestPoint - heroPosition):normalized() * smoothing
    evadeTo(closestPoint.x, closestPoint.y)
    return true
    else return false
end
return false
end

function AM1(skillshot)         
    if haveShield() then
        for i, detectedSkillshot in ipairs(detectedSkillshots) do
            if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
                table.remove(detectedSkillshots, i)
                i = i-1
                if detectedSkillshot.evading then
                    continueMovement(detectedSkillshot)
                end
            end
        end
        if isSivir then
            CastSpell(_E)
        elseif isNocturne then
            CastSpell(_W)
        end
        return true
        else return false
        end
        return false
    end

function AM2(skillshot, heroPosition)
    if flashready and getLastMovementDestination():distance(heroPosition) > 20 and not skillshot.alreadydashed then
        dashpos = getLastMovementDestination() + (getLastMovementDestination() - heroPosition):normalized() * 400
        if dashpos:distance(skillshot.endPosition) > skillshot.skillshot.radius and not InsideTheWall(dashpos) then
        FlashTo(dashpos.x, dashpos.y)
        skillshot.alreadydashed = true
        for i, detectedSkillshot in ipairs(detectedSkillshots) do
            if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
                table.remove(detectedSkillshots, i)
                i = i-1
                if detectedSkillshot.evading then
                    continueMovement(detectedSkillshot)
                end
            end
        end
        return true
        else return false
        end
        else return false
        end
        return false
end

function AM3(skillshot, safeTarget)
    if flashready and not skillshot.alreadydashed then
        FlashTo(safeTarget.x, safeTarget.y)
        skillshot.alreadydashed = true
        for i, detectedSkillshot in ipairs(detectedSkillshots) do
            if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
                table.remove(detectedSkillshots, i)
                i = i-1
                if detectedSkillshot.evading then
                    continueMovement(detectedSkillshot)
                end
            end
        end
        return true
        else return false
        end
        return false
end
 -- end of circular skillshot dodging functions --
 -- beggining of line skillshot dodging functions --
function lineSkillshot1(skillshot, heroPosition, skillshotLine, distanceFromSkillshotPath, evadeDistance, normalVector, nessecaryMoveWidth, evadeTo1, evadeTo2)
    if skillshotLine:distance(evadeTo1) >= skillshotLine:distance(evadeTo2) then
        longitudinalApproachLength = calculateLongitudinalApproachLength(skillshot, nessecaryMoveWidth)
        if longitudinalApproachLength >= 0 then
            evadeToTarget1 = evadeTo1 - skillshot.directionVector * longitudinalApproachLength
        end

        longitudinalApproachLength = calculateLongitudinalApproachLength(skillshot, evadeDistance + distanceFromSkillshotPath)
        if longitudinalApproachLength >= 0 then
            evadeToTarget2 = heroPosition - normalVector * (evadeDistance + distanceFromSkillshotPath) - skillshot.directionVector * longitudinalApproachLength
        end

        longitudinalRetreatLength = calculateLongitudinalRetreatLength(skillshot, nessecaryMoveWidth)
        if longitudinalRetreatLength >= 0 then
            evadeToTarget3 = evadeTo1 + skillshot.directionVector * longitudinalRetreatLength
        end

        longitudinalRetreatLength = calculateLongitudinalRetreatLength(skillshot, evadeDistance + distanceFromSkillshotPath)
        if longitudinalRetreatLength >= 0 then
            evadeToTarget4 = heroPosition - normalVector * (evadeDistance + distanceFromSkillshotPath) + skillshot.directionVector * longitudinalRetreatLength
        end

        safeTarget = evadeTo1

        closestPoint = getLastMovementDestination() + normalVector * (evadeDistance - skillshotLine:distance(getLastMovementDestination()))
        closestPoint2 = getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) + normalVector * evadeDistance
    else
        longitudinalApproachLength = calculateLongitudinalApproachLength(skillshot, nessecaryMoveWidth)
        if longitudinalApproachLength >= 0 then
            evadeToTarget1 = evadeTo2 - skillshot.directionVector * longitudinalApproachLength
        end

        longitudinalApproachLength = calculateLongitudinalApproachLength(skillshot, evadeDistance + distanceFromSkillshotPath)
        if longitudinalApproachLength >= 0 then
            evadeToTarget2 = heroPosition + normalVector * (evadeDistance + distanceFromSkillshotPath) - skillshot.directionVector * longitudinalApproachLength
        end

        longitudinalRetreatLength = calculateLongitudinalRetreatLength(skillshot, nessecaryMoveWidth)
        if longitudinalRetreatLength >= 0 then
            evadeToTarget3 = evadeTo2 + skillshot.directionVector * longitudinalRetreatLength
        end

        longitudinalRetreatLength = calculateLongitudinalRetreatLength(skillshot, evadeDistance + distanceFromSkillshotPath)
        if longitudinalRetreatLength >= 0 then
            evadeToTarget4 = heroPosition + normalVector * (evadeDistance + distanceFromSkillshotPath) + skillshot.directionVector * longitudinalRetreatLength
        end

        safeTarget = evadeTo2

        closestPoint = getLastMovementDestination() - normalVector * (evadeDistance - skillshotLine:distance(getLastMovementDestination()))
        closestPoint2 = getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) - normalVector * evadeDistance
    end

    if skillshotLine:distance(getLastMovementDestination()) <= evadeDistance then
        directionTarget = findBestDirection(skillshot,getLastMovementDestination(), {closestPoint, closestPoint2, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) - normalVector * evadeDistance, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) + normalVector * evadeDistance})
    else
        if getSideOfLine(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) == getSideOfLine(skillshot.startPosition, skillshot.endPosition, heroPosition) then
        if skillshotLine:distance(heroPosition) <= skillshotLine:distance(getLastMovementDestination()) then
            directionTarget = heroPosition + (getLastMovementDestination()-heroPosition):normalized() * ((evadeDistance - distanceFromSkillshotPath) * heroPosition:distance(getLastMovementDestination())) / (skillshotLine:distance(getLastMovementDestination()) - distanceFromSkillshotPath)
        else
            directionTarget = heroPosition + (getLastMovementDestination()-heroPosition):normalized() * ((evadeDistance + distanceFromSkillshotPath) * heroPosition:distance(getLastMovementDestination())) / (distanceFromSkillshotPath - skillshotLine:distance(getLastMovementDestination()))
        end
    else
        directionTarget = heroPosition + (getLastMovementDestination() - heroPosition):normalized() * (evadeDistance + distanceFromSkillshotPath) * heroPosition:distance(getLastMovementDestination()) / (skillshotLine:distance(getLastMovementDestination()) + distanceFromSkillshotPath)
    end
end

evadeTarget = nil
if (evadeToTarget1 ~= nil and evadeToTarget3 ~= nil and Line2(evadeToTarget1, evadeToTarget3):distance(directionTarget) <= 1 and getSideOfLine(evadeToTarget1, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget1), directionTarget) ~= getSideOfLine(evadeToTarget3, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget3), directionTarget)) or (evadeToTarget2 ~= nil and evadeToTarget4 ~= nil and Line2(evadeToTarget2, evadeToTarget4):distance(directionTarget) <= 1 and getSideOfLine(evadeToTarget2, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget2), directionTarget) ~= getSideOfLine(evadeToTarget4, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget4), directionTarget)) or (evadeToTarget1 ~= nil and evadeToTarget3 == nil and getSideOfLine(heroPosition, evadeToTarget1, skillshot.startPosition) ~= getSideOfLine(heroPosition, evadeToTarget1, directionTarget)) or (evadeToTarget2 ~= nil and evadeToTarget4 == nil and getSideOfLine(heroPosition, evadeToTarget2, skillshot.startPosition) ~= getSideOfLine(heroPosition, evadeToTarget2, directionTarget)) then
evadeTarget = directionTarget
else
    possibleMovementTargets = {}

    if (evadeToTarget1 ~= nil and evadeToTarget3 ~= nil and Line2(evadeToTarget1, evadeToTarget3):distance(closestPoint2) <= 1 and getSideOfLine(evadeToTarget1, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget1), closestPoint2) ~= getSideOfLine(evadeToTarget3, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget3), closestPoint2)) or (evadeToTarget2 ~= nil and evadeToTarget4 ~= nil and Line2(evadeToTarget2, evadeToTarget4):distance(closestPoint2) <= 1 and getSideOfLine(evadeToTarget2, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget2), closestPoint2) ~= getSideOfLine(evadeToTarget4, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget4), closestPoint2)) or (evadeToTarget1 ~= nil and evadeToTarget3 == nil and getSideOfLine(heroPosition, evadeToTarget1, skillshot.startPosition) ~= getSideOfLine(heroPosition, evadeToTarget1, closestPoint2)) or (evadeToTarget2 ~= nil and evadeToTarget4 == nil and getSideOfLine(heroPosition, evadeToTarget2, skillshot.startPosition) ~= getSideOfLine(heroPosition, evadeToTarget2, closestPoint2)) then
    table.insert(possibleMovementTargets, closestPoint2)
end

if evadeToTarget1 ~= nil then
    table.insert(possibleMovementTargets, evadeToTarget1)
end

if evadeToTarget2 ~= nil then
    table.insert(possibleMovementTargets, evadeToTarget2)
end

if evadeToTarget3 ~= nil then
    table.insert(possibleMovementTargets, evadeToTarget3)
end

if evadeToTarget4 ~= nil then
    table.insert(possibleMovementTargets, evadeToTarget4)
end

evadeTarget = findBestDirection(skillshot,getLastMovementDestination(), possibleMovementTargets)
end

if evadeTarget then
    if getSideOfLine(skillshot.startPosition, skillshot.endPosition, evadeTarget) == getSideOfLine(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) and skillshotLine:distance(getLastMovementDestination()) > evadeDistance then
    pathDirectionVector = (evadeTarget - heroPosition)
    if getSideOfLine(skillshot.startPosition, skillshot.endPosition, heroPosition) == getSideOfLine(skillshot.startPosition, skillshot.endPosition, evadeTarget) then
    evadeTarget = evadeTarget + pathDirectionVector:normalized() * (pathDirectionVector:len() + smoothing / (evadeDistance - distanceFromSkillshotPath) * pathDirectionVector:len())
else
    evadeTarget = evadeTarget + pathDirectionVector:normalized() * (pathDirectionVector:len() + smoothing / (evadeDistance + distanceFromSkillshotPath) * pathDirectionVector:len())
end
end
evadeTo(evadeTarget.x, evadeTarget.y)
return true
else return false
end
return false
end

function lineSkillshot2(skillshot)
    if haveShield() then 
        for i, detectedSkillshot in ipairs(detectedSkillshots) do
            if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
                table.remove(detectedSkillshots, i)
                i = i-1
                if detectedSkillshot.evading then
                    continueMovement(detectedSkillshot)
                end
            end
        end
        if isSivir then
            CastSpell(_E)
        elseif isNocturne then
            CastSpell(_W)
        end
        return true
        else return false
    end
    return false
end

function lineSkillshot3(skillshot, evadeTo1, evadeTo2)
    if not skillshot.alreadydashed then
    local safeTarget = nil
    if NeedDash(skillshot, true)
        then if (evadeTo1:distance(lastMovement.destination) > evadeTo2:distance(lastMovement.destination)) and not InsideTheWall(evadeTo2) then
            safeTarget = evadeTo2
        elseif (evadeTo2:distance(lastMovement.destination) > evadeTo1:distance(lastMovement.destination)) and not InsideTheWall(evadeTo1) then
            safeTarget = evadeTo1
        elseif InsideTheWall(evadeTo2) then
            safeTarget = evadeTo1
        elseif InsideTheWall(evadeTo1) then
            safeTarget = evadeTo2
        end
        if safeTarget ~= nil then
            evadeTo(safeTarget.x, safeTarget.y, true)
            skillshot.alreadydashed = true
            return true
            else return false
        end
        else return false
    end
else return false
end
return false
end

function lineSkillshot4(skillshot, evadeTo1, evadeTo2)
    if GoodEvadeConfig.lineallways then
        if skillshotLine:distance(evadeTo1) >= skillshotLine:distance(evadeTo2) then
            if not InsideTheWall(evadeTo1) then
                safeTarget = evadeTo1
            elseif not InsideTheWall(evadeTo2) then
                safeTarget = evadeTo2
            else
                safeTarget = getLastMovementDestination()
            end

        else
            if not InsideTheWall(evadeTo2) then
                safeTarget = evadeTo2
            elseif not InsideTheWall(evadeTo1) then
                safeTarget = evadeTo1
            else
                safeTarget = getLastMovementDestination()
            end
        end

        if safeTarget ~= nil then
            evadeTo(safeTarget.x, safeTarget.y)
            return true
            else return false
            end
            else return false
            end
            return false
end

function dodgeCrescendo1(skillshot)
if haveShield() then 
        for i, detectedSkillshot in ipairs(detectedSkillshots) do
            if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
                table.remove(detectedSkillshots, i)
                i = i-1
                if detectedSkillshot.evading then
                    continueMovement(detectedSkillshot)
                end
            end
        end
        if isSivir then
            CastSpell(_E)
        elseif isNocturne then
            CastSpell(_W)
        end
        return true
        else return false
    end
    return false
end

function dodgeCrescendo2(skillshot, evadeTo1, evadeTo2)
local safeTarget = nil
    if haveflash and useflash and not skillshot.alreadydashed
        then if (evadeTo1:distance(lastMovement.destination) > evadeTo2:distance(lastMovement.destination)) and not InsideTheWall(evadeTo2) then
            safeTarget = evadeTo2
        elseif (evadeTo2:distance(lastMovement.destination) > evadeTo1:distance(lastMovement.destination)) and not InsideTheWall(evadeTo1) then
            safeTarget = evadeTo1
        elseif InsideTheWall(evadeTo2) then
            safeTarget = evadeTo1
        elseif InsideTheWall(evadeTo1) then
            safeTarget = evadeTo2
        end
        if safeTarget ~= nil then
            FlashTo(safeTarget.x, safeTarget.y)
            skillshot.alreadydashed = true
            return true
            else return false
        end
        else return false
    end
return false
end
-- end of line skillshot dodging functions --
