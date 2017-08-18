function game_load(suspended)

	
	
	

	arcadestartblink = 0
	if arcade then
		love.mouse.setVisible(false)
		arcadeplaying = {false, false, false, false}
		arcadeexittimer = {arcadeexittime, arcadeexittime, arcadeexittime, arcadeexittime}
		players = 4
		
		for i = 1, 4 do
			controls[i] = {}
			controls[i]["right"] = {}
			controls[i]["left"] = {}
			controls[i]["down"] = {}
			controls[i]["up"] = {}
			controls[i]["run"] = {}
			controls[i]["jump"] = {}
			controls[i]["aimx"] = {}
			controls[i]["aimy"] = {}
			controls[i]["portal1"] = {}
			controls[i]["portal2"] = {}
			controls[i]["reload"] = {}
			controls[i]["use"] = {}
		end
		
		portaltriggervalues = {}
		ttentrybuttonvalue = 0
		ttentrybuttonvalueh = "c"
		arcadetimeouttimers = {}
		
		for i = 1, 4 do
			--get joystick
			local joystick
			for j = 1, 4 do
				if arcadejoystickmaps[j] == i then
					joystick = j
					break
				end
			end
			
			if joystick then
				portaltriggervalues[i] = love.joystick.getAxis(joystick, 3)
				arcadetimeouttimers[i] = 0
			end
		end
	end
	
	scenecanvas = love.graphics.newCanvas( )
	
	checkpointx = {}
	checkpointy = {}
	checkpointsub = false
	
	scrollfactor = 0
	fscrollfactor = 0
	backgroundcolor = {}
	backgroundcolor[1] = {92, 148, 252}
	backgroundcolor[2] = {0, 0, 0}
	backgroundcolor[3] = {32, 56, 236}
	love.graphics.setBackgroundColor(backgroundcolor[1])

	scrollingstart = width/2 --when the scrolling begins to set in (Both of these take the player who is the farthest on the left)
	scrollingcomplete = width/2-width/10 --when the scrolling will be as fast as mario can run
	scrollingleftstart = width/3 --See above, but for scrolling left, and it takes the player on the right-estest.
	scrollingleftcomplete = width/3-width/10
	upscrollborder = 4
	downscrollborder = 4
	superscroll = 100
	portaldotstimer = 0
	
	--LINK STUFF
	
	mariocoincount = 0
	marioscore = 0
	
	--get mariolives
	mariolivecount = 3
	if love.filesystem.exists("mappacks/" .. mappack .. "/settings.txt") then
		local s = love.filesystem.read( "mappacks/" .. mappack .. "/settings.txt" )
		local s1 = s:split("\n")
		for j = 1, #s1 do
			local s2 = s1[j]:split("=")
			if s2[1] == "lives" then
				mariolivecount = tonumber(s2[2])
			end
		end
	end
	
	if mariolivecount == 0 then
		mariolivecount = false
	end
	
	mariolives = {}
	for i = 1, players do
		mariolives[i] = mariolivecount
	end
	
	mariosizes = {}
	for i = 1, players do
		mariosizes[i] = 1
	end
	
	autoscroll = true
	
	outputs = { "box", "button", "laserdetector", "pushbutton", "walltimer", "squarewave", "notgate", "orgate", "andgate", "regiontrigger", "actionblock"}
	outputsi = {20, 40, 56, 57, 58, 59, 68, 69, 74, 82, 84, 19, 86, 87, 39}
	
	jumpitems = { "mushroom", "oneup" }
	
	marioworld = 1
	mariolevel = 1	
	mariosublevel = 0
	respawnsublevel = 0
	
	objects = nil
	if suspended == true then
		continuegame()
	elseif suspended then
		marioworld = suspended
	end
	
	--remove custom sprites
	for i = smbtilecount+portaltilecount+1, #tilequads do
		tilequads[i] = nil
	end
	
	for i = smbtilecount+portaltilecount+1, #rgblist do
		rgblist[i] = nil
	end
	
	--add custom tiles
	if love.filesystem.exists("mappacks/" .. mappack .. "/tiles.png") then
		customtiles = true
		customtilesimg = love.graphics.newImage("mappacks/" .. mappack .. "/tiles.png")
		local imgwidth, imgheight = customtilesimg:getWidth(), customtilesimg:getHeight()
		local width = math.floor(imgwidth/17)
		local height = math.floor(imgheight/17)
		local imgdata = love.image.newImageData("mappacks/" .. mappack .. "/tiles.png")
		
		for y = 1, height do
			for x = 1, width do
				table.insert(tilequads, quad:new(customtilesimg, imgdata, x, y, imgwidth, imgheight))
				local r, g, b = getaveragecolor(imgdata, x, y)
				table.insert(rgblist, {r, g, b})
			end
		end
		customtilecount = width*height
	else
		customtiles = false
		customtilecount = 0
	end
	
	smbspritebatch = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
	smbspritebatchfront = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
	portalspritebatch = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
	portalspritebatchfront = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
	if customtiles then
		customspritebatch = love.graphics.newSpriteBatch( customtilesimg, 10000 )
		customspritebatchfront = love.graphics.newSpriteBatch( customtilesimg, 10000 )
	end
	spritebatchX = {}
	spritebatchY = {}
	
	musicname = nil
	--[[if love.filesystem.exists("mappacks/" .. mappack .. "/music.ogg") then
		custommusic = "mappacks/" .. mappack .. "/music.ogg"
		music:load(custommusic)
	elseif love.filesystem.exists("mappacks/" .. mappack .. "/music.mp3") then
		custommusic = "mappacks/" .. mappack .. "/music.mp3"
		music:load(custommusic)
	end--]]
	
	
	--FINALLY LOAD THE DAMN LEVEL
	levelscreen_load("initial")
end

function game_update(dt)
	dt = dt * speed
	gdt = dt
	
	if ttstate == "playing" then
		ttidletimer = ttidletimer + dt
	
		for i = 1, 4 do
			if love.joystick.isDown(1, i) then
				ttidletimer = 0
			end
			
			if love.joystick.getAxis(1, 1) ~= 0 or love.joystick.getAxis(1, 2) ~= 0 then
				ttidletimer = 0
			end
			
			if love.joystick.getHat(1, 1) ~= "c" then
				ttidletimer = 0
			end
			
			if love.keyboard.isDown("d") then
				ttidletimer = 0
			end
		end
		
		if ttidletimer >= 15 then
			game_load()
		end
	else
		ttidletimer = 0
	end

	--------
	--GAME--
	--------
	
	if love.joystick.isDown(1, 3) then
		firstplacetimer = firstplacetimer + dt
		if firstplacetimer > 2 then
			firstplacetimer = 0
			firstreplayblue = not firstreplayblue
		end
	else
		firstplacetimer = 0
	end
	
	if ttstate == "entry" and ttrestarttimer and ttrestarttimer > 0 then
		ttrestarttimer = ttrestarttimer - dt
		if ttrestarttimer <= 0 then
			ttrestarttimer = 0
			nextlevel()
		end
	end
	
	if ttstate == "entry" then
		--hat
		if ttentrybuttonvalueh == "c" then
			if love.joystick.getHat(1, 1) == "ru" or love.joystick.getHat(1, 1) == "u"  or love.joystick.getHat(1, 1) == "lu" then
				ttentryup()
			elseif love.joystick.getHat(1, 1) == "rd" or love.joystick.getHat(1, 1) == "d"  or love.joystick.getHat(1, 1) == "ld" then
				ttentrydown()
			end
		end
		ttentrybuttonvalueh = love.joystick.getHat(1, 1)

		if math.abs(love.joystick.getAxis(1, 2)) > 0.5 and math.abs(ttentrybuttonvalue) <= 0.5 then
			if love.joystick.getAxis(1, 2) > 0 then
				ttentrydown()
			else
				ttentryup()
			end
		end
		
		ttentrybuttonvalue = love.joystick.getAxis(1, 2)
	end
	
	if arcade then
		for i = 1, 4 do
			--get joystick
			local joystick
			for j = 1, 4 do
				if arcadejoystickmaps[j] == i then
					joystick = j
					break
				end
			end
			
			if joystick then
				if not love.joystick.isDown(joystick, 7) then
					arcadeexittimer[i] = arcadeexittime
				elseif arcadeexittimer[i] < arcadeexittime then
					arcadeexittimer[i] = arcadeexittimer[i] + dt
					if arcadeexittimer[i] > arcadeexittime then
						arcadeleave(i)
						arcadeexittimer[i] = arcadeexittime
					end
				end
				
				--trigger portals
				if arcadeplaying[i] then
					if math.abs(love.joystick.getAxis(joystick, 3)) > 0.5 and math.abs(portaltriggervalues[i]) <= 0.5 then
						if love.joystick.getAxis(joystick, 3) > 0 then
							shootportal(i, 1, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
						else
							shootportal(i, 2, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
						end
					end
					portaltriggervalues[i] = love.joystick.getAxis(joystick, 3)
					
					for j, v in pairs({love.joystick.getAxes(joystick)}) do
						if math.abs(v) > 0.2 then
							arcadetimeouttimers[i] = 0
						end
					end
					
					for j = 1, love.joystick.getNumHats(joystick) do
						local v = love.joystick.getHat(joystick, j)
						if v ~= "c" then
							arcadetimeouttimers[i] = 0
						end					
					end
					
					for j = 1, love.joystick.getNumButtons(joystick) do
						if love.joystick.isDown( joystick, j ) then
							arcadetimeouttimers[i] = 0
						end
					end
					
					if objects["player"][i].controlsenabled and not levelfinished then
						arcadetimeouttimers[i] = arcadetimeouttimers[i] + dt
						if arcadetimeouttimers[i] > arcadetimeout then
							arcadeleave(i)
							arcadetimeouttimers[i] = 0
						end
					end
				end
			end
		end
		
	end
		arcadestartblink = math.mod(arcadestartblink + dt, arcadeblinkrate)
	
	--ANIMATIONS
	animationsystem_update(dt)
	
	
	--earthquake reset
	if earthquake > 0 then
		earthquake = math.max(0, earthquake-dt*earthquake*2-0.001)
		sunrot = sunrot + dt
	end
	
	--Animate animated tiles because I say so
	for i = 1, #animatedtiles do
		animatedtiles[i]:update(dt)
	end
	
	--pausemenu
	if pausemenuopen then
		return
	end
	
	--coinanimation
	coinanimation = coinanimation + dt*6.75
	while coinanimation >= 6 do
		coinanimation = coinanimation - 5
	end	
	
	coinframe = math.floor(coinanimation)
	
	--SCROLLING SCORES
	local delete = {}
	
	for i, v in pairs(scrollingscores) do
		if scrollingscores[i]:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(scrollingscores, v) --remove
	end
	
	
	--SCROLLING TEXTS
	local delete = {}
	
	for i, v in pairs(scrollingtexts) do
		if scrollingtexts[i]:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(scrollingtexts, v) --remove
	end
	
	if ttstate == "countdown" then
		ttcountdown = ttcountdown - dt
		
		for i = 1, 3 do
			if ttcountdown + dt >= i and ttcountdown < i then
				playsound("stomp")
			end
		end
		
		if ttcountdown <= 0 then
			timetrialstarted = true
			ttstate = "playing"
			playmusic()
			objects["player"][1].controlsenabled = true

			for _, v in ipairs(replays) do
				v:reset()
			end
		end
	end
	
	if ttstate == "playing" then
		if objects.player[1].replayFrames >= 9600 then
			mariolives[1] = 0
			mariolivecount = 1
			love.audio.stop()
			levelscreen_load("death")
		end
	end

	if ttstate == "demo" or ttstate == "playing" or ttstate == "endanimation" or ttstate == "entry" then
		for _, v in ipairs(replays) do
			v:tick()
		end
	end
	
	if timetrials and not timetrialstarted then
		objects["player"][1].animationstate = "idle"
		objects["player"][1]:setquad()
		if ttstate ~= "demo" then
			return
		end
	end
	
	if replaysystem then
		replayi = replayi + 1
	end


	
	if ttstate == "demo" and #replaydata >= 1 then
		if replayi == replaydata[1].frames+600 then
			game_load()
			return
		end
	end
	
	--If everyone's dead, just update the players and coinblock timer.
	if everyonedead then
		for i, v in pairs(objects["player"]) do
			v:update(dt)
		end
		
		return
	end
	
	--timer	
	if editormode == false then
		--get if any player has their controls disabled
		local notime = false
		for i = 1, players do
			if (objects["player"][i].controlsenabled == false and objects["player"][i].dead == false) then
				notime = true
			end
		end
		
		if notime == false and infinitetime == false and mariotime ~= 0 and not arcade then
			mariotime = mariotime - 2.5*dt
			
			if mariotime > 0 and mariotime + 2.5*dt >= 99 and mariotime < 99 then
				love.audio.stop()
				playsound("lowtime")
			end
			
			if mariotime > 0 and mariotime + 2.5*dt >= 99-8 and mariotime < 99-8 then
				local star = false
				for i = 1, players do
					if objects["player"][i].starred then
						star = true
					end
				end
				
				if not star then
					playmusic()
				else
					music:play("starmusic.ogg")
				end
			end
			
			if mariotime <= 0 then
				mariotime = 0
				for i, v in pairs(objects["player"]) do
					v:die("time")
				end
			end
		end
	end
	
	--remove userects
	local delete = {}
	for i, v in pairs(userects) do
		if v.delete then
			table.insert(delete, i)
		end
	end
			
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(userects, v)
	end
	
	--Portaldots
	portaldotstimer = portaldotstimer + dt
	while portaldotstimer > portaldotstime do
		portaldotstimer = portaldotstimer - portaldotstime
	end
	
	--portalgundelay
	for i = 1, players do
		if portaldelay[i] > 0 then
			portaldelay[i] = math.max(0, portaldelay[i] - dt/speed)
		end
	end
	
	--check if updates are blocked for whatever reason
	if noupdate then
		for i, v in pairs(objects["player"]) do --But update players anyway.
			v:update(dt)
		end
		return
	end
	
	--blockbounce
	local delete = {}
	
	for i, v in pairs(blockbouncetimer) do
		if blockbouncetimer[i] < blockbouncetime then
			blockbouncetimer[i] = blockbouncetimer[i] + dt
			if blockbouncetimer[i] > blockbouncetime then
				blockbouncetimer[i] = blockbouncetime
				if blockbouncecontent then
					item(blockbouncecontent[i], blockbouncex[i], blockbouncey[i], blockbouncecontent2[i])
				end
				table.insert(delete, i)
			end
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(blockbouncetimer, v)
		table.remove(blockbouncex, v)
		table.remove(blockbouncey, v)
		table.remove(blockbouncecontent, v)
		table.remove(blockbouncecontent2, v)
	end
	
	if #delete >= 1 then
		generatespritebatch()
	end
	
	--coinblocktimer things
	for i, v in pairs(coinblocktimers) do
		if v[3] > 0 then
			v[3] = v[3] - dt
		end
	end
	
	--gelcannon
	if objects["player"][mouseowner] and playertype == "gelcannon" and objects["player"][mouseowner].controlsenabled then
		if gelcannontimer > 0 then
			gelcannontimer = gelcannontimer - dt
			if gelcannontimer < 0 then
				gelcannontimer = 0
			end
		else
			if love.mouse.isDown("l") then
				gelcannontimer = gelcannondelay
				objects["player"][mouseowner]:shootgel(1)
			elseif love.mouse.isDown("r") then
				gelcannontimer = gelcannondelay
				objects["player"][mouseowner]:shootgel(2)
			end
		end
	end
	
	
	--UPDATE STUFFFFF
	
	local updatetable = {	pedestals, emancipationfizzles, emancipateanimations, dialogboxes, rocketlaunchers, emancipationgrills, fireworks, miniblocks, bubbles, platformspawners, seesaws, blockdebristable,
							userects, rainbooms, coinblockanimations, itemanimations}
							
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" and i ~= "screenboundary" then
			table.insert(updatetable, v)
		end
	end
	
	for i, v in pairs(updatetable) do
		delete = {}
		
		for j, w in pairs(v) do
			if w.update and w:update(dt) then
				table.insert(delete, j)
			elseif w.autodelete then
				if w.y > mapheight+1 or w.x > mapwidth+1 or w.x < -1 then
					if w.autodeleted then
						w:autodeleted()
					end
					table.insert(delete,j)
				end
			end
		end
		
		if #delete > 0 then
			table.sort(delete, function(a,b) return a>b end)
			
			for j, w in pairs(delete) do
				table.remove(v, w)
			end
		end
	end
	
	
	--PHYSICS
	physicsupdate(dt)
	
	
	--SCROLLING
	--HORIZONTAL
	local oldxscroll = xscroll
	local oldyscroll = yscroll
	
	if autoscroll and minimapdragging == false then
		--scrolling
		local i = 1
		while i <= players and (objects["player"][i].dead or objects["player"][i].remote or (arcade and not arcadeplaying[i])) do
			i = i + 1
		end
		
		local fastestplayer = objects["player"][i]
		
		if fastestplayer then
			for i = 1, players do
				if not objects["player"][i].dead and not objects["player"][i].remote and objects["player"][i].x > fastestplayer.x and (not arcade or arcadeplaying[i]) then
					fastestplayer = objects["player"][i]
				end
			end
			local speedx = converttostandard(fastestplayer, fastestplayer.speedx, fastestplayer.speedy)
			
			if fastestplayer.dead then -- scrolling fix for online multiplayer if all local players suck. I mean, are dead.
				for i = 1, players do
					if not objects["player"][i].dead and objects["player"][i].x > fastestplayer.x then
						fastestplayer = objects["player"][i]
					end
				end
			end
			
			--LEFT
			if fastestplayer.x < xscroll + scrollingleftstart and xscroll > 0 then
				
				if fastestplayer.x < xscroll + scrollingleftstart and speedx < 0 then
					if speedx < -scrollrate then
						xscroll = xscroll - scrollrate*dt
					else
						xscroll = xscroll + speedx*dt
					end
				end
				
				if fastestplayer.x < xscroll + scrollingleftcomplete then
					if fastestplayer.x > xscroll + scrollingleftcomplete - 1/16 then
						xscroll = xscroll - scrollrate*dt
					else
						xscroll = xscroll - superscrollrate*dt
					end
				end
				
				if xscroll < 0 then
					xscroll = 0
				end
			end
			
			--RIGHT
			
			if fastestplayer.x > xscroll + width - scrollingstart and xscroll < mapwidth - width then
				if fastestplayer.x > xscroll + width - scrollingstart and speedx > 0.3 then
					if speedx > scrollrate then
						xscroll = xscroll + scrollrate*dt
					else
						xscroll = xscroll + speedx*dt
					end
				end
				
				if fastestplayer.x > xscroll + width - scrollingcomplete then
					if fastestplayer.x > xscroll + width - scrollingcomplete then
						xscroll = xscroll + scrollrate*dt
						if xscroll > fastestplayer.x - (width - scrollingcomplete) then
							xscroll = fastestplayer.x - (width - scrollingcomplete)
						end
					else
						xscroll = fastestplayer.x - (width - scrollingcomplete)
					end
				end
			end
			
			--just force that shit
			if not levelfinished then
				if fastestplayer.x > xscroll + width - scrollingcomplete then
					xscroll = xscroll + superscroll*dt
					if fastestplayer.x < xscroll + width - scrollingcomplete then
						xscroll = fastestplayer.x - width + scrollingcomplete
					end
					--xscroll = fastestplayer.x + width - scrollingcomplete - width
				end
			end
				
			if xscroll > mapwidth-width then
				xscroll = math.max(0, mapwidth-width)
				hitrightside()
			end
				
			if (axex and xscroll > axex-width and axex >= width) then
				xscroll = axex-width
				hitrightside()
			end
		end
	
		--VERTICAL SCROLLING
		for i = 1, players do
			local v = objects["player"][i]
			local old = ylookmodifier
			if downkey(i) then
				if v.looktimer < userscrolltime then
					v.looktimer = v.looktimer + dt
				else
					if ylookmodifier < math.min(userscrollrange, mapheight-(height+yscroll)) then
						ylookmodifier = ylookmodifier + dt*userscrollspeed
						if ylookmodifier > math.min(userscrollrange, mapheight-(height+yscroll)) then
							ylookmodifier = math.min(userscrollrange, mapheight-(height+yscroll))
						end
					end
				end
			elseif upkey(i) then
				if v.looktimer < userscrolltime then
					v.looktimer = v.looktimer + dt
				else
					if ylookmodifier > -math.min(userscrollrange, yscroll) then
						ylookmodifier = ylookmodifier - dt*userscrollspeed
						if ylookmodifier < -math.min(userscrollrange, yscroll) then
							ylookmodifier = -math.min(userscrollrange, yscroll)
						end
					end
				end
			else
				v.looktimer = 0
				if ylookmodifier > 0 then
					ylookmodifier = math.max(0, ylookmodifier - userscrollspeed*dt)
				elseif ylookmodifier < 0 then
					ylookmodifier = math.min(0, ylookmodifier + userscrollspeed*dt)
				end
			end
			
			yscroll = yscroll + (ylookmodifier-old)
		end
		
		local i = 1
		while i <= players and (objects["player"][i].dead or objects["player"][i].remote or (arcade and not arcadeplaying[i])) do
			i = i + 1
		end
		local fastestplayer = objects["player"][i]
		if fastestplayer then
			for i = 1, players do
				if not objects["player"][i].dead and not objects["player"][i].remote and objects["player"][i].y > fastestplayer.y and (not arcade or arcadeplaying[i]) then
					fastestplayer = objects["player"][i]
				end
			end
			local dummy, speedy = converttostandard(fastestplayer, fastestplayer.speedx, fastestplayer.speedy)
			if fastestplayer.y-yscroll < upscrollborder then
				local minspeed = (fastestplayer.y-yscroll-upscrollborder)*yscrollingrate
				yscroll = yscroll+math.min(speedy, minspeed)*dt
			elseif fastestplayer.y-yscroll > height-downscrollborder then
				local minspeed = (fastestplayer.y-yscroll - (height-downscrollborder))*yscrollingrate
				yscroll = yscroll+math.max(speedy, minspeed)*dt
			end
		end
			
		if yscroll > mapheight-height-1 then
			yscroll = math.max(0, mapheight-height-1)
		end
		
		if yscroll < 0 then
			yscroll = 0
		end
	end
	
	if firstpersonview then
		xscroll = objects["player"][1].x-width/2+objects["player"][1].width/2
		yscroll = objects["player"][1].y-height/2+objects["player"][1].height/2-.5
	end
	
	if ttstate == "demo" then
		for i = 1, #replaydata do
			if replays[1].x then
				xscroll = math.max(xscroll, replays[1].x/16-16)
			end
		end
	end
	
	xscroll = math.min(xscroll, mapwidth-width)
	
	
	--[[
	for i = 1, 10 do
		mazesolved[i] = true
	end
	xscroll = xscroll + dt*100
	if xscroll >= mapwidth-width then
		while true do
			mariosublevel = mariosublevel + 1
			if mariosublevel > 5 then
				mariosublevel = 0
				mariolevel = mariolevel + 1
				if mariolevel > 4 then
					mariolevel = 1
					marioworld = marioworld + 1
				end
			end
			love.timer.sleep(0.1)
			if mariosublevel == 0 then
				print(marioworld .. "-" .. mariolevel .. ".txt")
				if love.filesystem.exists("mappacks/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. ".txt") then
					startlevel(marioworld .. "-" .. mariolevel)
					break
				end
			else
				print(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt")
				if love.filesystem.exists("mappacks/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt") then
					startlevel(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel)
					break
				end
			end
		end
	end
	--]]
	
	
	--camera pan x
	if xpan then
		xpantimer = xpantimer + dt
		if xpantimer >= xpantime then
			xpan = false
			xpantimer = xpantime
		end
		
		local i = xpantimer/xpantime
		
		xscroll = xpanstart + xpandiff*i
	end
	
	--camera pan y
	if ypan then
		ypantimer = ypantimer + dt
		if ypantimer >= ypantime then
			ypan = false
			ypantimer = ypantime
		end
		
		local i = ypantimer/ypantime
		
		yscroll = ypanstart + ypandiff*i
	end
	
	--enemy spawning
	if round(xscroll) ~= round(oldxscroll) then
		local xstart, xend
		if xscroll > oldxscroll then
			xstart, xend = round(oldxscroll)+1+math.ceil(width), round(xscroll)+math.ceil(width)
		else
			xstart, xend = round(xscroll), round(oldxscroll)-1
		end
		
		for x = xstart, xend do
			for y = round(yscroll)-1, round(yscroll)+height+1 do
				spawnenemy(x, y)
			end
		end
	end
	
	if round(yscroll) ~= round(oldyscroll) then
		--friendship
	end
	
	--SPRITEBATCH UPDATE and CASTLEREPEATS
	if math.floor(xscroll) ~= spritebatchX[1] then
		if not editormode then
			for currentx = lastrepeat+1+width, math.floor(xscroll)+1+width do
				reachedx(currentx)
			end
		end
		
		generatespritebatch()
		spritebatchX[1] = math.floor(xscroll)
	elseif math.floor(yscroll) ~= spritebatchY[1] then
		generatespritebatch()
		spritebatchY[1] = math.floor(yscroll)
	end
	
	--portal animation
	portalanimationtimer = portalanimationtimer + dt
	while portalanimationtimer > portalanimationdelay do
		portalanimationtimer = 0
		portalanimation = portalanimation + 1
		if portalanimation > portalanimationcount then
			portalanimation = 1
		end
	end
	
	--portal particles
	portalparticletimer = portalparticletimer + dt
	while portalparticletimer > portalparticletime do
		portalparticletimer = portalparticletimer - portalparticletime
		
		for i, v in pairs(portals) do
			if v.facing1 and v.x1 and v.y1 then
				local x1, y1
				
				if v.facing1 == "up" then
					x1 = v.x1 + math.random(1, 30)/16 -1
					y1 = v.y1-1
				elseif v.facing1 == "down" then
					x1 = v.x1 + math.random(1, 30)/16-2
					y1 = v.y1
				elseif v.facing1 == "left" then
					x1 = v.x1-1
					y1 = v.y1 + math.random(1, 30)/16-2
				elseif v.facing1 == "right" then
					x1 = v.x1
					y1 = v.y1 + math.random(1, 30)/16-1
				end
				
				local color
				if players == 1 then
					color = {157, 222, 254}
				else
					color = v.portal1color
				end
				
				table.insert(portalparticles, portalparticle:new(x1, y1, color, v.facing1))
			end
			
			if v.facing2 ~= nil and v.x2 and v.y2 then
				local x2, y2
				
				if v.facing2 == "up" then
					x2 = v.x2 + math.random(1, 30)/16 -1
					y2 = v.y2-1
				elseif v.facing2 == "down" then
					x2 = v.x2 + math.random(1, 30)/16-2
					y2 = v.y2
				elseif v.facing1 == "left" then
					x2 = v.x2-1
					y2 = v.y2 + math.random(1, 30)/16-2
				elseif v.facing2 == "right" then
					x2 = v.x2
					y2 = v.y2 + math.random(1, 30)/16-1
				end
				
				local color
				if players == 1 then
					color = {255, 122, 66}
				else
					color = v.portal2color
				end
				
				table.insert(portalparticles, portalparticle:new(x2, y2, color, v.facing2))
			end
		end
	end
	
	delete = {}
	
	for i, v in pairs(portalparticles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalparticles, v) --remove
	end
	
	--PORTAL PROJECTILES
	delete = {}
	
	for i, v in pairs(portalprojectiles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalprojectiles, v) --remove
	end
	
	--FIRE SPAWNING
	if not levelfinished and firestarted and (not objects["bowser"][1] or (objects["bowser"][1].backwards == false and objects["bowser"][1].shot == false and objects["bowser"][1].fall == false)) then
		firetimer = firetimer + dt
		while firetimer > firedelay do
			firetimer = firetimer - firedelay
			firedelay = math.random(4)
			local temp = enemy:new(xscroll + width, math.random(3)+7, "fire")
			table.insert(objects["enemy"], temp)
			
			
			if objects["bowser"][1] then --make bowser fire this
				temp.y = objects["bowser"][1].y+0.25
				temp.x = objects["bowser"][1].x-0.750
				
				--get goal Y
				temp.movement = "targety"
				temp.targetyspeed = 2
				temp.targety = objects["bowser"][1].starty-math.random(3)+2/16
			end
		end
	end
	
	--FLYING FISH
	if not levelfinished and flyingfishstarted then
		flyingfishtimer = flyingfishtimer + dt
		while flyingfishtimer > flyingfishdelay do
			flyingfishtimer = flyingfishtimer - flyingfishdelay
			flyingfishdelay = math.random(6, 20)/10
			
			local x, y = math.random(math.floor(xscroll), math.floor(xscroll)+width), mapheight
			local temp = enemy:new(x, y, "flyingfish")
			table.insert(objects["enemy"], temp)
			
			temp.speedx = objects["player"][1].speedx + math.random(10)-5
			
			if temp.speedx == 0 then
				temp.speedx = 1
			end
			
			if temp.speedx > 0 then
				temp.animationdirection = "left"
			else
				temp.animationdirection = "right"
			end
		end
	end
	
	--BULLET BILL
	if not levelfinished and bulletbillstarted then
		bulletbilltimer = bulletbilltimer + dt
		while bulletbilltimer > bulletbilldelay do
			bulletbilltimer = bulletbilltimer - bulletbilldelay
			bulletbilldelay = math.random(5, 40)/10
			table.insert(objects["enemy"], enemy:new(xscroll+width+2, math.random(4, 12), "bulletbill"))
		end
	end
	
	--minecraft stuff
	if breakingblockX then
		breakingblockprogress = breakingblockprogress + dt
		if breakingblockprogress > minecraftbreaktime then
			breakblock(breakingblockX, breakingblockY)
			breakingblockX = nil
		end
	end
	
	--Editor
	if editormode then
		editor_update(dt)
	end
end

function game_draw()
	if firstpersonview and firstpersonrotate then
		local xtranslate = width/2*16*scale
		local ytranslate = height/2*16*scale
		love.graphics.translate(xtranslate, ytranslate)
		love.graphics.rotate(-objects["player"][1].rotation/2)
		love.graphics.translate(-xtranslate, -ytranslate)
	end
	
	currentscissor = {0, 0,love.graphics.getWidth(), love.graphics.getHeight()}
	--This is just silly
	if earthquake > 0 and #rainbooms > 0 then
		local colortable = {{242, 111, 51}, {251, 244, 174}, {95, 186, 76}, {29, 151, 212}, {101, 45, 135}, {238, 64, 68}}
		for i = 1, backgroundstripes do
			local r, g, b = unpack(colortable[math.mod(i-1, 6)+1])
			local a = earthquake/rainboomearthquake*255
			
			love.graphics.setColor(r, g, b, a)
			
			local alpha = math.rad((i/backgroundstripes + math.mod(sunrot/5, 1)) * 360)
			local point1 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
			
			local alpha = math.rad(((i+1)/backgroundstripes + math.mod(sunrot/5, 1)) * 360)
			local point2 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
			
			love.graphics.polygon("fill", width*8*scale, 112*scale, point1[1], point1[2], point2[1], point2[2])
		end
	end
	
	love.graphics.setColor(255, 255, 255, 255)
	--tremoooor!
	if earthquake > 0 then
		tremorx = (math.random()-.5)*2*earthquake
		tremory = (math.random()-.5)*2*earthquake
		
		love.graphics.translate(round(tremorx), round(tremory))
	end
	
	love.graphics.setColor(255, 255, 255, 255)
	
	--THIS IS WHERE MAP DRAWING AND SHIT BEGINS
	
	function scenedraw()
		love.graphics.setColor(love.graphics.getBackgroundColor())
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
		love.graphics.setColor(255, 255, 255, 255)
		local xtodraw
		if mapwidth < width+1 then
			xtodraw = math.ceil(mapwidth)
		else
			if mapwidth > width and xscroll < mapwidth-width then
				xtodraw = math.ceil(width+1)
			else
				xtodraw = math.ceil(width)
			end
		end
		
		local ytodraw
		if mapheight < height+1 then
			ytodraw = math.ceil(mapheight)
		else
			if mapheight > height and yscroll < mapheight-height then
				ytodraw = height+1
			else
				ytodraw = height
			end
		end
		
		--custom background
		if custombackground then
			if custombackground == true then
				local xscroll = xscroll / (scrollfactor + 1)
				if reversescrollfactor() == 1 then
					xscroll = 0
				end
				for y = 1, math.ceil(height/14)+1 do
					for x = 1, math.ceil(width)+1 do
						love.graphics.draw(portalbackgroundimg, math.floor((x-1)*16*scale) - math.floor(math.mod(xscroll, 1)*16*scale), math.floor(((y-1)*14)*16*scale) - math.floor(math.mod(yscroll, 14)*16*scale), 0, scale, scale)
					end
				end
			else
				if custombackgroundimg[custombackground] then
					for i = #custombackgroundimg[custombackground], 1, -1  do
						local xscroll = xscroll / (i * scrollfactor + 1)
						if reversescrollfactor() == 1 then
							xscroll = 0
						end
						for y = 1, math.ceil(height/custombackgroundheight[custombackground][i])+1 do
							for x = 1, math.ceil(width/custombackgroundwidth[custombackground][i])+1 do
								love.graphics.draw(custombackgroundimg[custombackground][i], math.floor(((x-1)*custombackgroundwidth[custombackground][i])*16*scale) - math.floor(math.mod(xscroll, custombackgroundwidth[custombackground][i])*16*scale), math.floor(((y-1)*custombackgroundheight[custombackground][i])*16*scale) - math.floor(math.mod(yscroll, custombackgroundheight[custombackground][i])*16*scale), 0, scale, scale)
							end
						end
					end
				end
			end
		end
		
		
	
	if ttstate == "demo" then
		love.graphics.draw(tttitle, 125*scale, 60*scale, 0, scale, scale)
	end
		
		--castleflag
		if levelfinished and levelfinishtype == "flag" and not custombackground then
			love.graphics.draw(castleflagimg, math.floor((flagx+6-xscroll)*16*scale), (flagy-7+10/16)*16*scale+(castleflagy-yscroll)*16*scale, 0, scale, scale)
		end
		
		--itemanimations
		for j, w in pairs(itemanimations) do
			w:draw()
		end
		
		--TILES
		love.graphics.draw(smbspritebatch, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		love.graphics.draw(portalspritebatch, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		if customtiles then
			love.graphics.draw(customspritebatch, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		end
		
		local lmap = map
		
		local flooredxscroll
		if xscroll >= 0 then
			flooredxscroll = math.floor(xscroll)
		else
			flooredxscroll = math.ceil(xscroll)
		end
		
		local flooredyscroll
		if yscroll >= 0 then
			flooredyscroll = math.floor(yscroll)
		else
			flooredyscroll = math.ceil(yscroll)
		end
		
		for y = 1, ytodraw do
			for x = 1, xtodraw do
			
				if inmap(flooredxscroll+x, flooredyscroll+y) then
					local bounceyoffset = 0
					for i, v in pairs(blockbouncex) do
						if blockbouncex[i] == flooredxscroll+x and blockbouncey[i] == flooredyscroll+y then
							if blockbouncetimer[i] < blockbouncetime/2 then
								bounceyoffset = blockbouncetimer[i] / (blockbouncetime/2) * blockbounceheight
							else
								bounceyoffset = (2 - blockbouncetimer[i] / (blockbouncetime/2)) * blockbounceheight
							end
						end	
					end
					
					local t = lmap[flooredxscroll+x][flooredyscroll+y]
					
					local tilenumber = t[1]
					if tilequads[tilenumber].coinblock and tilequads[tilenumber].invisible == false then --coinblock
						love.graphics.drawq(coinblockimg, coinblockquads[spriteset][coinframe], math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1)-bounceyoffset)*16-8)*scale, 0, scale, scale)
					elseif coinmap[x][y] then --coin
						love.graphics.drawq(coinimg, coinquads[spriteset][coinframe], math.floor((x-1-xscroll)*16*scale), ((y-1-yscroll-bounceyoffset)*16-8)*scale, 0, scale, scale)
					elseif bounceyoffset ~= 0 or tilenumber > 10000 then
						if not tilequads[tilenumber].invisible then
							love.graphics.drawq(tilequads[tilenumber].image, tilequads[tilenumber].quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1)-bounceyoffset)*16-8)*scale, 0, scale, scale)
						end
					end
					
					--Gel overlays!
					if t["gels"] then
						for i = 1, 4 do
							local dir = "top"
							local r = 0
							if i == 2 then
								dir = "right"
								r = math.pi/2
							elseif i == 3 then
								dir = "bottom"
								r = math.pi
							elseif i == 4 then
								dir = "left"
								r = math.pi*1.5
							end
							
							for i = 1, 4 do
								if t["gels"][dir] == i then
									local img
									if i == 1 then
										img = gel1groundimg
									elseif i == 2 then
										img = gel2groundimg
									elseif i == 3 then
										img = gel3groundimg
									elseif i == 4 then
										img = gel4groundimg
									end
										
									love.graphics.draw(img, math.floor((x-.5-math.mod(xscroll, 1))*16*scale), math.floor((y-1-math.mod(yscroll, 1)-bounceyoffset)*16*scale), r, scale, scale, 8, 8)
								end
							end
						end
					end
					
					if editormode then
						if tilequads[t[1]].invisible and t[1] ~= 1 then
							love.graphics.drawq(tilequads[t[1]].image, tilequads[t[1]].quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1))*16-8)*scale, 0, scale, scale)
						end
						
						if #t > 1 and t[2] ~= "link" then
							tilenumber = t[2]
							love.graphics.setColor(255, 255, 255, 150)
							if tablecontains(enemies, tilenumber) then --ENEMY PREVIEW THING
								local v = enemiesdata[tilenumber]
								local xoff, yoff = (((v.spawnoffsetx or 0)+v.width/2-.5)*16 - v.offsetX + v.quadcenterX)*scale, (((v.spawnoffsety or 0)-v.height+1)*16-v.offsetY - v.quadcenterY)*scale
								
								local mx, my = getMouseTile(mouse.getX(), mouse.getY()+8*scale)
								local alpha = 150
								if x == mx and y == my then
									alpha = 255
								end
								
								love.graphics.setColor(255, 0, 0, alpha)
								love.graphics.rectangle("fill", math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1))*16-8)*scale), 16*scale, 16*scale)
								love.graphics.setColor(255, 255, 255, alpha)
								love.graphics.drawq(v.graphic, v.quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale+xoff), math.floor(((y-1-math.mod(yscroll, 1))*16)*scale+yoff), 0, scale, scale)
							else
								love.graphics.drawq(entityquads[tilenumber].image, entityquads[tilenumber].quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1))*16-8)*scale), 0, scale, scale)
							end
							love.graphics.setColor(255, 255, 255, 255)
						end
						
						if entitylist[map[x][y][2]] == "platform" then
							local dir, dist
							if rightclickm and rightclickm.tx == x and rightclickm.ty == y then
								dir = rightclickm.variables[2].value
								dist = tonumber(rightclickm.t[6].value)
							else
								dir = map[x][y][3]
								dist = tonumber(map[x][y][5])
							end
							
							
							love.graphics.setColor(252, 152, 56, 150)
							if dir == "down" then
								love.graphics.line((x-xscroll-.5)*16*scale, (y-yscroll-1.2)*16*scale, (x-xscroll-.5)*16*scale, (y-yscroll-1.2+dist)*16*scale)
							elseif dir == "left" then
								love.graphics.line((x-xscroll-.5)*16*scale, (y-yscroll-1.2)*16*scale, (x-xscroll-.5-dist)*16*scale, (y-yscroll-1.2)*16*scale)
							end
							love.graphics.setColor(255, 255, 255, 255)
						end
					end
				end
			end
		end
	
		---UI
		love.graphics.setColor(255, 255, 255)
		love.graphics.translate(0, -yoffset*scale)
		if yoffset < 0 then
			love.graphics.translate(0, yoffset*scale)
		end
		
		properprint(objects["player"][1].char.name, uispace*.5 - 24*scale, 8*scale)
		properprint(addzeros(marioscore, 6), uispace*0.5-24*scale, 16*scale)
		
		properprint("*", uispace*1.5-8*scale, 16*scale)
		
		love.graphics.drawq(coinanimationimg, coinanimationquads[spriteset][coinframe], uispace*1.5-16*scale, 16*scale, 0, scale, scale)
		properprint(addzeros(mariocoincount, 2), uispace*1.5-0*scale, 16*scale)
		
		properprint("world", uispace*2.5 - 20*scale, 8*scale)
		properprint(marioworld .. "-" .. mariolevel, uispace*2.5 - 12*scale, 16*scale)
		
		properprint("time", uispace*3.5 - 16*scale, 8*scale)
		if editormode then
			if linktool then
				properprint("link", uispace*3.5 - 16*scale, 16*scale)
			else
				properprint("edit", uispace*3.5 - 16*scale, 16*scale)
			end
		else
			properprint(addzeros(math.ceil(mariotime), 3), uispace*3.5-8*scale, 16*scale)
		end
		
		if arcade then
			local drawtitle = true
			for i = 1, players do
				if arcadeplaying[i] then
					drawtitle = false
					break
				end
			end
			
			if not drawtitle then
				for i = 1, players do
					love.graphics.setColor(255, 255, 255, 255)
					local x = (width*16)/players/2 + (width*16)/players*(i-1)
					if not arcadeplaying[i] then
						local s = "push start"
						properprint(s, (x-string.len(s)*4)*scale, 25*scale)
					else
						properprint("player " .. i, (x-string.len("player " .. i)*4+4)*scale, 25*scale)
						love.graphics.setColor(mariocolors[i][1])
						love.graphics.rectangle("fill", (x-string.len("player " .. i)*4-3)*scale, 25*scale, 7*scale, 7*scale)
					end
				end
			end
		else
			if players > 1 then
				for i = 1, players do
					local x = (width*16)/players/2 + (width*16)/players*(i-1)
					if mariolivecount ~= false then
						properprint("p" .. i .. " * " .. mariolives[i], (x-string.len("p" .. i .. " * " .. mariolives[i])*4+4)*scale, 25*scale)
						love.graphics.setColor(mariocolors[i][1] or {255, 255, 255})
						love.graphics.rectangle("fill", (x-string.len("p" .. i .. " * " .. mariolives[i])*4-3)*scale, 25*scale, 7*scale, 7*scale)
						love.graphics.setColor(255, 255, 255, 255)
					end
				end
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--textentities
		for j, w in pairs(textentities) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--vines
		for j, w in pairs(objects["vine"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--warpzonetext
		if displaywarpzonetext then
			properprint("welcome to warp zone!", (mapwidth-14-1/16-xscroll)*16*scale, (5.5-yscroll)*16*scale)
			for i, v in pairs(warpzonenumbers) do
				properprint(v[3], math.floor((v[1]-xscroll-1-9/16)*16*scale), (v[2]-3-yscroll)*16*scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--platforms
		for j, w in pairs(objects["platform"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--scaffolds
		for j, w in pairs(objects["scaffold"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--seesawplatforms
		for j, w in pairs(objects["seesawplatform"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--seesaws
		for j, w in pairs(seesaws) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--springs
		for j, w in pairs(objects["spring"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--flag
		if flagx then
			love.graphics.draw(flagimg, math.floor((flagimgx-1-xscroll)*16*scale), ((flagimgy-yscroll)*16-8)*scale, 0, scale, scale)
			if levelfinishtype == "flag" then
				properprint2(flagscore, math.floor((flagimgx+4/16-xscroll)*16*scale), ((14-flagimgy-yscroll+(flagy-13)*2)*16-8)*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--axe
		if axex then
			love.graphics.drawq(axeimg, axequads[coinframe], math.floor((axex-1-xscroll)*16*scale), (axey-1.5-yscroll)*16*scale, 0, scale, scale)
			
			if marioworld ~= 8 then
				love.graphics.draw(toadimg, math.floor((mapwidth-7-xscroll)*16*scale), (axey+2.0625-yscroll)*16*scale, 0, scale, scale)
			else
				love.graphics.draw(peachimg, math.floor((mapwidth-7-xscroll)*16*scale), (axey+2.0625-yscroll)*16*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--levelfinish text and toad
		if levelfinished and levelfinishtype == "castle" then
			if timetrials then
				if levelfinishedmisc >= 1 then
					properprint("thank you mario!", math.floor(((mapwidth-12-xscroll)*16-1)*scale), (axey-4.5-yscroll)*16*scale)
				end
				if levelfinishedmisc == 2 then
					properprint("time:", math.floor(((mapwidth-12.5-xscroll)*16-1)*scale), (axey-2.5-yscroll)*16*scale) --say what
					
					local finaltime = objects.player[1].replayFrames*targetdt

					local t = ""
					local m = math.floor(finaltime/60)
					local s = math.floor(math.mod(finaltime, 60))
					local hundredths = string.sub(round(math.mod(finaltime, 1), 2), 3)
					
					t = t .. addzeros(m, 2) .. "\'" .. addzeros(s, 2) .. "\"" .. addzeros(hundredths, 2)
					
					properprint(t, math.floor(((mapwidth-12.5-xscroll)*16-1)*scale), (axey-1.5-yscroll)*16*scale) --bummer.

					
					
					properprint("rank:", math.floor(((mapwidth-7.5-xscroll)*16-1)*scale), (axey-2.5-yscroll)*16*scale) --say what
					properprint("#" .. ttrank .. " of " .. amountofreplays+1, math.floor(((mapwidth-7.5-xscroll)*16-1)*scale), (axey-1.5-yscroll)*16*scale) --bummer.

					
				end
			else
				if levelfinishedmisc2 == 1 then
					if levelfinishedmisc >= 1 then
						properprint("thank you mario!", math.floor(((mapwidth-12-xscroll)*16-1)*scale), (axey-4.5-yscroll)*16*scale)
					end
					if levelfinishedmisc == 2 then
						properprint("but our princess is in", math.floor(((mapwidth-13.5-xscroll)*16-1)*scale), (axey-2.5-yscroll)*16*scale) --say what
						properprint("another castle!", math.floor(((mapwidth-13.5-xscroll)*16-1)*scale), (axey-1.5-yscroll)*16*scale) --bummer.
					end
				else
					if levelfinishedmisc >= 1 then	
						properprint("thank you mario!", math.floor(((mapwidth-12-xscroll)*16-1)*scale), (axey-4.5-yscroll)*16*scale)
					end
					if levelfinishedmisc >= 2 then
						properprint("your quest is over.", math.floor(((mapwidth-12.5-xscroll)*16-1)*scale), (axey-3-yscroll)*16*scale)
					end
					if arcade then
						if levelfinishedmisc >= 3 then
							properprint("we hope you enjoyed", math.floor(((mapwidth-12.5-xscroll)*16-1)*scale), (axey-2-yscroll)*16*scale)
						end
						if levelfinishedmisc >= 4 then
							properprint("the gamescom demo", math.floor(((mapwidth-12-xscroll)*16-1)*scale), (axey-.5-yscroll)*16*scale)
						end
						if levelfinishedmisc == 5 then
							properprint("of mari0! -stabyourself.net", math.floor(((mapwidth-15-xscroll)*16-1)*scale), (axey+.5-yscroll)*16*scale)
						end
					else
						if levelfinishedmisc >= 3 then
							properprint("we present you a new quest.", math.floor(((mapwidth-14.5-xscroll)*16-1)*scale), (axey-2-yscroll)*16*scale)
						end
						if levelfinishedmisc >= 4 then
							properprint("push button b", math.floor(((mapwidth-11-xscroll)*16-1)*scale), (axey-.5-yscroll)*16*scale)
						end
						if levelfinishedmisc == 5 then
							properprint("to play as steve", math.floor(((mapwidth-12-xscroll)*16-1)*scale), (axey+.5-yscroll)*16*scale)
						end
					end
				end
			end
			
			if marioworld ~= 8 then
				love.graphics.draw(toadimg, math.floor((mapwidth-7-xscroll)*16*scale), (axey+2.0625-yscroll)*16*scale, 0, scale, scale)
			else
				love.graphics.draw(peachimg, math.floor((mapwidth-7-xscroll)*16*scale), (axey+2.0625-yscroll)*16*scale, 0, scale, scale)
			end
		end
		love.graphics.setColor(255, 255, 255)
		--Panels
		for j, w in pairs(objects["panel"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Fireworks
		for j, w in pairs(fireworks) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Buttons
		for j, w in pairs(objects["button"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Pushbuttons
		for j, w in pairs(objects["pushbutton"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		
		--hardlight bridges
		for j, w in pairs(objects["lightbridgebody"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		
		--lightbridge
		for j, w in pairs(objects["lightbridge"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--laser
		for j, w in pairs(objects["laser"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--laserdetector
		for j, w in pairs(objects["laserdetector"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Groundlights
		for j, w in pairs(objects["groundlight"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Faithplates
		for j, w in pairs(objects["faithplate"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Bubbles
		for j, w in pairs(bubbles) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--miniblocks
		for i, v in pairs(miniblocks) do
			v:draw()
		end
		
		--emancipateanimations
		for i, v in pairs(emancipateanimations) do
			v:draw()
		end
		
		--emancipationfizzles
		for i, v in pairs(emancipationfizzles) do
			v:draw()
		end
		
		--pedestals
		for i, v in pairs(pedestals) do
			v:draw()
		end
		
		--replays
		love.graphics.setColor(255, 255, 255)
		if replaysystem and drawreplays and (timetrialstarted or ttstate == "demo") then
			for _, v in ipairs(replays) do
				v:draw()
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		
		if ttstate == "playing" or ttstate == "endanimation" then
			local seconds = objects.player[1].replayFrames*targetdt
			local t = ""
			local m = math.floor(seconds/60)
			local s = math.floor(math.mod(seconds, 60))
			local micro = string.sub(round(math.mod(seconds, 1), 2), 3)
			
			t = t .. addzeros(m, 2) .. "\'" .. addzeros(s, 2) .. "\"" .. addzeros(micro, 2)
		
			properprintbackground(t, 135*scale, 200*scale, true, {255, 255, 255}, scale*2)
		end
		
		--OBJECTS
		for j, w in pairs(objects) do	
			if j ~= "tile" then
				for i, v in pairs(w) do
					if v.drawable and v.graphic and v.quad then
						love.graphics.setScissor()
						love.graphics.setColor(255, 255, 255)
						local dirscale
						
						if j == "player" then
							if (v.portalsavailable[1] or v.portalsavailable[2]) then
								if (v.pointingangle+math.pi*2 > -v.rotation+math.pi*2 and (not (v.pointingangle > -v.rotation+math.pi))) or v.pointingangle < -v.rotation-math.pi then
									dirscale = -scale
								else
									dirscale = scale
								end
							else
								if v.animationdirection == "right" then
									dirscale = scale
								else
									dirscale = -scale
								end
							end
							
							if bigmario then
								dirscale = dirscale * scalefactor
							end
						else
							if v.animationdirection == "left" then
								dirscale = -scale
							else
								dirscale = scale
							end
						end
						
						if v.mirror then
							dirscale = -dirscale
						end
						
						local horscale = scale
						if v.shot or v.upsidedown then
							horscale = -scale
						end
						
						if j == "player" and bigmario then
							horscale = horscale * scalefactor
						end
						
						if v.customscale then
							horscale = horscale * v.customscale
							dirscale = dirscale * v.customscale
						end
						
						local portal, portaly = insideportal(v.x, v.y, v.width, v.height)
						local entryX, entryY, entryfacing, exitX, exitY, exitfacing
						
						--SCISSOR FOR ENTRY
						if v.customscissor and v.portalable ~= false then
							local t = "setStencil"
							if v.invertedscissor then
								t = "setInvertedStencil"
							end
							love.graphics[t](function() love.graphics.rectangle("fill", math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale) end)
						end
							
						if v.static == false and v.portalable ~= false then
							if not v.customscissor and portal ~= false and (v.active or v.portaloverride) then
								if portaly == 1 then
									entryX, entryY, entryfacing = portal.x1, portal.y1, portal.facing1
									exitX, exitY, exitfacing = portal.x2, portal.y2, portal.facing2
								else
									entryX, entryY, entryfacing = portal.x2, portal.y2, portal.facing2
									exitX, exitY, exitfacing = portal.x1, portal.y1, portal.facing1
								end
								
								if entryfacing == "right" then
									love.graphics.setScissor(math.floor((entryX-xscroll)*16*scale), math.floor(((entryY-3.5-yscroll)*16)*scale), 64*scale, 96*scale)
								elseif entryfacing == "left" then
									love.graphics.setScissor(math.floor((entryX-xscroll-5)*16*scale), math.floor(((entryY-4.5-yscroll)*16)*scale), 64*scale, 96*scale)
								elseif entryfacing == "up" then
									love.graphics.setScissor(math.floor((entryX-xscroll-3)*16*scale), math.floor(((entryY-5.5-yscroll)*16)*scale), 96*scale, 64*scale)
								elseif entryfacing == "down" then
									love.graphics.setScissor(math.floor((entryX-xscroll-4)*16*scale), math.floor(((entryY-0.5-yscroll)*16)*scale), 96*scale, 64*scale)
								end
							end
						end
						
						if type(v.graphic) == "table" then
							for k = 1, #v.graphic do
								if v.colors[k] then
									love.graphics.setColor(v.colors[k])
								else
									love.graphics.setColor(255, 255, 255)
								end
								love.graphics.drawq(v.graphic[k], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
						else
							if v.graphic and v.quad then
								love.graphics.drawq(v.graphic, v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
						end
						
						--HATS
						if v.drawhat then
							local offsets = gethatoffset(v.char, v.graphic, v.animationstate, v.runframe, v.jumpframe, v.climbframe, v.swimframe, v.underwater, v.infunnel, v.fireanimationtimer, v.ducking)
							
							if offsets and #v.hats > 0 then
								local yadd = 0
								for i = 1, #v.hats do
									if v.hats[i] == 1 then
										love.graphics.setColor(v.colors[1])
									else
										love.graphics.setColor(255, 255, 255)
									end
									if v.graphic == v.biggraphic or v.animationstate == "grow" then
										love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
										yadd = yadd + bighat[v.hats[i]].height
									else
										love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
										yadd = yadd + hat[v.hats[i]].height
									end
								end
							end
							love.graphics.setColor(255, 255, 255)
						end
						
						if type(v.graphic) == "table" then
							if v.graphic[0] then
								love.graphics.setColor(255, 255, 255)
								love.graphics.drawq(v.graphic[0], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
							if v.graphic.dot then
								love.graphics.setColor(unpack(v["portal" .. v.lastportal .. "color"]))
								love.graphics.drawq(v.graphic["dot"], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end	
						end
						
						--portal duplication
						if v.customscissor and v.portalable ~= false then
							local t = "setStencil"
							if v.invertedscissor then
								t = "setInvertedStencil"
							end
							love.graphics[t](function() love.graphics.rectangle("fill", math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale) end)
						end
						
						if v.static == false and (v.active or v.portaloverride) and v.portalable ~= false then
							if not v.customscissor and portal ~= false then
								love.graphics.setScissor(unpack(currentscissor))
								local px, py, pw, ph, pr, pad = v.x, v.y, v.width, v.height, v.rotation, v.animationdirection
								px, py, d, d, pr, pad = portalcoords(px, py, 0, 0, pw, ph, pr, pad, entryX, entryY, entryfacing, exitX, exitY, exitfacing)
								
								if pad ~= v.animationdirection then
									dirscale = -dirscale
								end
								
								horscale = scale
								if v.shot or v.upsidedown then
									horscale = -scale
								end
								
								if exitfacing == "right" then
									love.graphics.setScissor(math.floor((exitX-xscroll)*16*scale), math.floor(((exitY-yscroll-3.5)*16)*scale), 64*scale, 96*scale)
								elseif exitfacing == "left" then
									love.graphics.setScissor(math.floor((exitX-xscroll-5)*16*scale), math.floor(((exitY-yscroll-4.5)*16)*scale), 64*scale, 96*scale)
								elseif exitfacing == "up" then
									love.graphics.setScissor(math.floor((exitX-xscroll-3)*16*scale), math.floor(((exitY-yscroll-5.5)*16)*scale), 96*scale, 64*scale)
								elseif exitfacing == "down" then
									love.graphics.setScissor(math.floor((exitX-xscroll-4)*16*scale), math.floor(((exitY-yscroll-0.5)*16)*scale), 96*scale, 64*scale)
								end
								
								if type(v.graphic) == "table" then
									for k = 1, #v.graphic do
										if v.colors[k] then
											love.graphics.setColor(v.colors[k])
										else
											love.graphics.setColor(255, 255, 255)
										end
										love.graphics.drawq(v.graphic[k], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
									end
								else
									love.graphics.drawq(v.graphic, v.quad, math.ceil(((px-xscroll)*16+v.offsetX)*scale), math.ceil(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
								end
								
								--HAAAATS
								if v.drawhat then
									local offsets = gethatoffset(v.char, v.graphic, v.animationstate, v.runframe, v.jumpframe, v.climbframe, v.swimframe, v.underwater, v.infunnel, v.fireanimationtimer, v.ducking)
							
									if offsets and #v.hats > 0 then
										local yadd = 0
										for i = 1, #v.hats do
											if v.hats[i] == 1 then
												love.graphics.setColor(v.colors[1])
											else
												love.graphics.setColor(255, 255, 255)
											end
											if v.graphic == v.biggraphic or v.animationstate == "grow" then
												love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
												yadd = yadd + bighat[v.hats[i]].height
											else
												love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
												yadd = yadd + hat[v.hats[i]].height
											end
										end
									end
								end
								
								if type(v.graphic) == "table" then
									if v.graphic[0] then
										love.graphics.setColor(255, 255, 255)
										love.graphics.drawq(v.graphic[0], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
									end
									if v.graphic.dot then
										love.graphics.setColor(unpack(v["portal" .. v.lastportal .. "color"]))
										love.graphics.drawq(v.graphic["dot"], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
									end
								end
							end
						end
						love.graphics.setScissor(unpack(currentscissor))
						love.graphics.setStencil()
					end
				end
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		
		--bowser
		for j, w in pairs(objects["bowser"]) do
			w:draw()
		end
		
		--Geldispensers
		for j, w in pairs(objects["geldispenser"]) do
			w:draw()
		end
		
		--Cubedispensers
		for j, w in pairs(objects["cubedispenser"]) do
			w:draw()
		end
		
		--Funnels
		for j, w in pairs(objects["funnel"]) do
			w:draw()
		end
		
		--Emancipationgrills
		for j, w in pairs(emancipationgrills) do
			w:draw()
		end
		
		--Doors
		for j, w in pairs(objects["door"]) do
			w:draw()
		end
		
		--Wallindicators
		for j, w in pairs(objects["wallindicator"]) do
			w:draw()
		end
		
		--Walltimers
		for j, w in pairs(objects["walltimer"]) do
			w:draw()
		end
		
		--Notgates
		for j, w in pairs(objects["notgate"]) do
			w:draw()
		end
		
		--Orgates
		for j, w in pairs(objects["orgate"]) do
			w:draw()
		end
		
		--Andgates
		for j, w in pairs(objects["andgate"]) do
			w:draw()
		end
		
		--Musicentities
		for j, w in pairs(objects["musicentity"]) do
			w:draw()
		end
		
		--Squarewaves
		for j, w in pairs(objects["squarewave"]) do
			w:draw()
		end
		
		--Squarewaves
		for j, w in pairs(objects["actionblock"]) do
			w:draw()
		end
		
		--particles
		for j, w in pairs(portalparticles) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		
		--portals
		for i, v in pairs(portals) do
			if v.x1 ~= false then
				local rotation = 0
				local offsetx, offsety = 8, -3
				if v.facing1 == "right" then
					rotation = math.pi/2
					offsetx, offsety = 11, 0
				elseif v.facing1 == "down" then
					rotation = math.pi
					offsety = 3
				elseif v.facing1 == "left" then
					rotation = math.pi*1.5
					offsetx, offsety = 5, 0
				end
				
				local portalframe = portalanimation
				local glowalpha = 100
				if v.x2 == false then
				
				else
					--portal glow
					love.graphics.setColor(255, 255, 255, 80 - math.abs(portalframe-3)*10)
					love.graphics.draw(portalglowimg, math.floor(((v.x1-1-xscroll)*16+offsetx)*scale), math.floor(((v.y1-yscroll-1)*16+offsety)*scale), rotation, scale, scale, 8, 20)
					love.graphics.setColor(255, 255, 255, 255)
				end
				
				love.graphics.setColor(unpack(v.portal1color))
				--Portal graphic
				love.graphics.drawq(portalimg, portalquad[portalframe], math.floor(((v.x1-1-xscroll)*16+offsetx)*scale), math.floor(((v.y1-yscroll-1)*16+offsety)*scale), rotation, scale, scale, 8, 8)
			end
			
			if v.x2 ~= false then
				rotation = 0
				offsetx, offsety = 8, -3
				if v.facing2 == "right" then
					rotation = math.pi/2
					offsetx, offsety = 11, 0
				elseif v.facing2 == "down" then
					rotation = math.pi
					offsety = 3
				elseif v.facing2 == "left" then
					rotation = math.pi*1.5
					offsetx, offsety = 5, 0
				end
				
				local portalframe = portalanimation
				if v.x1 == false then
					
				else
					love.graphics.setColor(255, 255, 255, 80 - math.abs(portalframe-3)*10)
					love.graphics.draw(portalglowimg, math.floor(((v.x2-1-xscroll)*16+offsetx)*scale), math.floor(((v.y2-yscroll-1)*16+offsety)*scale), rotation, scale, scale, 8, 20)
					love.graphics.setColor(255, 255, 255, 255)
				end
				
				love.graphics.setColor(unpack(v.portal2color))
				love.graphics.drawq(portalimg, portalquad[portalframe], 
				math.floor(((v.x2-1-xscroll)*16+offsetx)*scale), math.floor(((v.y2-yscroll-1)*16+offsety)*scale), rotation, scale, scale, 8, 8)
			end
		end		
		
		love.graphics.setColor(255, 255, 255)
		
		--COINBLOCKANIMATION
		for i, v in pairs(coinblockanimations) do
			love.graphics.drawq(coinblockanimationimg, coinblockanimationquads[coinblockanimations[i].frame], math.floor((coinblockanimations[i].x - xscroll)*16*scale), math.floor(((coinblockanimations[i].y-yscroll)*16-8)*scale), 0, scale, scale, 4, 54)
		end
		
		--SCROLLING SCORE
		for i, v in pairs(scrollingscores) do
			if type(scrollingscores[i].i) == "number" then
				properprint2(scrollingscores[i].i, math.floor((scrollingscores[i].x-0.4)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale))
			elseif scrollingscores[i].i == "1up" then
				love.graphics.draw(oneuptextimage, math.floor((scrollingscores[i].x)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
			end
		end
		
		--SCROLLING TEXT
		for i, v in pairs(scrollingtexts) do
			v:draw()
		end
		
		--BLOCK DEBRIS
		for i, v in pairs(blockdebristable) do
			v:draw()
		end
	
		local minex, miney, minecox, minecoy
		
		--PORTAL UI STUFF
		if levelfinished == false and drawplayers then
			for pl = 1, players do
				if objects["player"][pl].controlsenabled and objects["player"][pl].t == "portal" and objects["player"][pl].vine == false and (objects["player"][pl].portalsavailable[1] or objects["player"][pl].portalsavailable[2]) then
					local sourcex, sourcey = objects["player"][pl].x+6/16, objects["player"][pl].y+6/16
					local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, objects["player"][pl].pointingangle)
					
					local portalpossible = true
					if cox == false or getportalposition(1, cox, coy, side, tend) == false then
						portalpossible = false
					end
					
					love.graphics.setColor(255, 255, 255, 255)
					
					local dist = math.sqrt(((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)^2 + ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)^2)/16/scale
					
					for i = 1, dist/portaldotsdistance+1 do
						if((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance)) < 1 then
							local xplus = ((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)*((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance))
							local yplus = ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)*((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance))
						
							local dotx = (sourcex-xscroll)*16*scale + xplus
							local doty = (sourcey-.5-yscroll)*16*scale + yplus
						
							local radius = math.sqrt(xplus^2 + yplus^2)/scale
							
							local alpha = 255
							if radius < portaldotsouter then
								alpha = (radius-portaldotsinner) * (255/(portaldotsouter-portaldotsinner))
								if alpha < 0 then
									alpha = 0
								end
							end
							
							
							if portalpossible == false then
								love.graphics.setColor(255, 0, 0, alpha)
							else
								love.graphics.setColor(0, 255, 0, alpha)
							end
						
							love.graphics.draw(portaldotimg, math.floor(dotx-0.25*scale), math.floor(doty-0.25*scale), 0, scale, scale)
						end
					end
				
					love.graphics.setColor(255, 255, 255, 255)
					
					if cox ~= false then
						if portalpossible == false then
							love.graphics.setColor(255, 0, 0)
						else
							love.graphics.setColor(0, 255, 0)
						end
						
						local rotation = 0
						if side == "right" then
							rotation = math.pi/2
						elseif side == "down" then
							rotation = math.pi
						elseif side == "left" then
							rotation = math.pi/2*3
						end
						love.graphics.draw(portalcrosshairimg, math.floor((x-xscroll)*16*scale), math.floor((y-.5-yscroll)*16*scale), rotation, scale, scale, 4, 8)
					end
				end
			end
		end
		
		--Portal projectile
		for i, v in pairs(portalprojectiles) do
			v:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		
		--nothing to see here
		for i, v in pairs(rainbooms) do
			v:draw()
		end
				
		--TILES FOREGROUND
		love.graphics.draw(smbspritebatchfront, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		love.graphics.draw(portalspritebatchfront, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		if customtiles then
			love.graphics.draw(customspritebatchfront, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		end
		
		--custom foreground
		if customforeground then
			if customforeground == true then
				--None
			else
				if custombackgroundimg[customforeground] then
					for i = 1, #custombackgroundimg[customforeground]  do
						local xscroll = xscroll * (i * fscrollfactor + 1)
						if reversescrollfactor() == 1 then
							xscroll = 0
						end
						for y = 1, math.ceil(height/custombackgroundheight[customforeground][i])+1 do
							for x = 1, math.ceil(width/custombackgroundwidth[customforeground][i])+1 do
								love.graphics.draw(custombackgroundimg[customforeground][i], math.floor(((x-1)*custombackgroundwidth[customforeground][i])*16*scale) - math.floor(math.mod(xscroll, custombackgroundwidth[customforeground][i])*16*scale), math.floor(((y-1)*custombackgroundheight[customforeground][i])*16*scale) - math.floor(math.mod(yscroll, custombackgroundheight[customforeground][i])*16*scale), 0, scale, scale)
							end
						end
					end
				end
			end
		end
	end --SCENE DRAW FUNCTION END
	
	if players == 1 and love.graphics.isSupported("canvas") and seethroughportals then
		local pl = objects["player"][1]
		scenecanvas:clear()
		love.graphics.setCanvas(scenecanvas)
		scenedraw()
		love.graphics.setCanvas(completecanvas)
		love.graphics.draw(scenecanvas, 0, 0)
		
		if firstpersonview and firstpersonrotate then
			local xtranslate = width/2*16*scale
			local ytranslate = height/2*16*scale
			love.graphics.translate(xtranslate, ytranslate)
			love.graphics.rotate(-objects["player"][1].rotation/2)
			love.graphics.translate(-xtranslate, -ytranslate)
		end
		
		currentscissor = {0, 0,width*16*scale, height*16*scale}
		
		for k, v in pairs(portals) do
			if v.x1 and v.x2 then
				for i = 1, 2 do
					local otheri = 1
					if i == 1 then
						otheri = 2
					end
				
					local x, y, facing = v["x" .. i], v["y" .. i], v["facing" .. i]
					local x2, y2, facing2 = v["x" .. otheri], v["y" .. otheri], v["facing" .. otheri]
					local pass = false
					
					if facing == "up" then
						pass = pl.y+pl.height/2 < y-1
					elseif facing == "right" then
						pass = pl.x+pl.width/2 > x
					elseif facing == "down" then
						pass = pl.y+pl.height/2 > y
					elseif facing == "left" then
						pass = pl.x+pl.width/2 < x-1
					end
					
					if pass then
						local p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y
						if facing == "right" then
							p1x, p1y = (x-xscroll), (y-yscroll-1.5)
							p2x, p2y = p1x, p1y+2
						elseif facing == "down" then
							p1x, p1y = (x-xscroll-2), (y-yscroll-.5)
							p2x, p2y = p1x+2, p1y
						elseif facing == "left" then
							p1x, p1y = (x-xscroll-1), (y-yscroll-2.5)
							p2x, p2y = p1x, p1y+2
						elseif facing == "up" then
							p1x, p1y = (x-xscroll-1), (y-yscroll-1.5)
							p2x, p2y = p1x+2, p1y
						end
						
						local r1 = math.atan2((pl.x+pl.width/2-xscroll)-p1x, (pl.y+pl.height/2-yscroll-.5)-p1y)
						local r2 = math.atan2((pl.x+pl.width/2-xscroll)-p2x, (pl.y+pl.height/2-yscroll-.5)-p2y)
						
						local limit = (width+height)*100
						
						p3x = -math.sin(r1)*limit+p1x
						p3y = -math.cos(r1)*limit+p1y
						
						p4x = -math.sin(r2)*limit+p2x
						p4y = -math.cos(r2)*limit+p2y
						
						
						--Calculate the middle of the portals
						local tx, ty
						local r1
						if facing == "right" then
							tx, ty = (x-xscroll), (y-yscroll-.5)
							r1 = math.pi/2
						elseif facing == "down" then
							tx, ty = (x-xscroll-1), (y-yscroll-.5)
							r1 = math.pi
						elseif facing == "left" then
							tx, ty = (x-xscroll-1), (y-yscroll-1.5)
							r1 = math.pi*1.5
						elseif facing == "up" then
							tx, ty = (x-xscroll), (y-yscroll-1.5)
							r1 = 0
						end
						
						local ox, oy
						if facing2 == "right" then
							ox, oy = (x2-xscroll), (y2-yscroll-.5)
							r2 = math.pi/2
						elseif facing2 == "down" then
							ox, oy = (x2-xscroll-1), (y2-yscroll-.5)
							r2 = math.pi
						elseif facing2 == "left" then
							ox, oy = (x2-xscroll-1), (y2-yscroll-1.5)
							r2 = math.pi*1.5
						elseif facing2 == "up" then
							ox, oy = (x2-xscroll), (y2-yscroll-1.5)
							r2 = 0
						end
						
						local offx, offy = tx-ox, ty-oy
						
						local a = r2-r1
						
						local xscale, yscale = 1, 1
						
						if facing == facing2 then
							if facing == "left" or facing == "right" then
								xscale = -xscale
							else
								yscale = -yscale
							end
						end
						
						if (facing == "left" and facing2 == "right") or (facing == "right" and facing2 == "left") or (facing == "up" and facing2 == "down") or (facing == "down" and facing2 == "up") then
							a = a - math.pi
						end
						
						love.graphics.setStencil(function()
							love.graphics.polygon("fill", p1x*16*scale, p1y*16*scale, p2x*16*scale, p2y*16*scale, p4x*16*scale, p4y*16*scale, p3x*16*scale, p3y*16*scale)
						end) --feels like javascript
						
						love.graphics.setColor(unpack(background))
						love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
						
						
						love.graphics.setColor(255, 255, 255)
						love.graphics.draw(scenecanvas, (offx+ox)*16*scale, (offy+oy)*16*scale, a, xscale, yscale, ox*16*scale, oy*16*scale)
						
						local r, g, b = unpack(v["portal" .. i .. "color"])
						--love.graphics.setColor(r, g, b, 150)
						--love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
						
						love.graphics.setStencil()
						love.graphics.setColor(r, g, b)
						love.graphics.line(p1x*16*scale, p1y*16*scale, p3x*16*scale, p3y*16*scale)
						love.graphics.line(p2x*16*scale, p2y*16*scale, p4x*16*scale, p4y*16*scale)
					end
				end
			end
		end
	else
		scenedraw()
	end
	
	love.graphics.setColor(255, 255, 255, 255)
	if ttstate == "idle" then
		love.graphics.draw(instrimg, 840-instrimg:getWidth()/2, 50)
	elseif ttstate == "countdown" then
		properprintbackground(math.ceil(ttcountdown), 140*scale, 60*scale, true, {255, 255, 255}, scale*13)
	
	end
	
	if ttstate == "idle" or ttstate == "demo" then
		if arcadestartblink < arcadeblinkrate*0.8 then
			properprintbackground("press start", 170*scale, 190*scale, 2*scale)
		end
	end
	
	if ttstate == "entry" then
	
		love.graphics.setColor(255, 0, 0)
		properprint("highscore! enter name:", math.floor(((mapwidth-13-xscroll)*16-1)*scale), (axey-0.5-yscroll)*16*scale) --bummer.

		love.graphics.setColor(255, 255, 255)
		local s = ttname
		
		if #s < 3 then
			if arcadestartblink < arcadeblinkrate*0.5 then			
				s = s .. string.sub(ttalphabet, ttcurrentletter, ttcurrentletter)
			else
				s = s .. " "
			end
			
			for i = 1, 3-#s do
				s = s .. "_"
			end
		end
		
		properprint(s, math.floor(((mapwidth-10.5-xscroll)*16-1)*scale), (axey+0.5-yscroll)*16*scale, scale*3)
	end
	
	--Minecraft
	--black border
	if objects["player"][mouseowner] and playertype == "minecraft" and not levelfinished then
		local v = objects["player"][mouseowner]
		local sourcex, sourcey = v.x+6/16, v.y+6/16
		local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, v.pointingangle)
		
		if cox then
			local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
			if dist <= minecraftrange then
				love.graphics.setColor(0, 0, 0, 170)
				love.graphics.rectangle("line", math.floor((cox-1-xscroll)*16*scale)-.5, (coy-yscroll-1-.5)*16*scale-.5, 16*scale, 16*scale)
			
				if breakingblockX and (cox ~= breakingblockX or coy ~= breakingblockY) then
					breakingblockX = cox
					breakingblockY = coy
					breakingblockprogress = 0
				elseif not breakingblockX and love.mouse.isDown("l") then
					breakingblockX = cox
					breakingblockY = coy
					breakingblockprogress = 0
				end
			elseif love.mouse.isDown("l") then
				breakingblockX = cox
				breakingblockY = coy
				breakingblockprogress = 0
			end
		else
			breakingblockX = nil
		end
		--break animation
		if breakingblockX then
			love.graphics.setColor(255, 255, 255, 255)
			local frame = math.ceil((breakingblockprogress/minecraftbreaktime)*10)
			if frame ~= 0 then
				love.graphics.drawq(minecraftbreakimg, minecraftbreakquad[frame], (breakingblockX-1-xscroll)*16*scale, (breakingblockY-yscroll-1.5)*16*scale, 0, scale, scale)
			end
		end
		love.graphics.setColor(255, 255, 255, 255)
		
		--gui
		love.graphics.draw(minecraftgui, (width*8-91)*scale, 202*scale, 0, scale, scale)
		
		love.graphics.setColor(255, 255, 255, 200)
		for i = 1, 9 do
			local t = inventory[i].t
			
			if t ~= nil then
				local img = customtilesimg
				if t <= smbtilecount then
					img = smbtilesimg
				elseif t <= smbtilecount+portaltilecount then
					img = portaltilesimg
				end
				love.graphics.drawq(img, tilequads[t].quad, (width*8-88+(i-1)*20)*scale, 205*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(minecraftselected, (width*8-92+(mccurrentblock-1)*20)*scale, 201*scale, 0, scale, scale)
		
		for i = 1, 9 do
			if inventory[i].t ~= nil then
				local count = inventory[i].count
				properprint(count, (width*8-72+(i-1)*20-string.len(count)*8)*scale, 205*scale)
			end
		end
	end
	
	--Player markers
	for i = 1, players do
		local v = objects["player"][i]
		if false and not v.dead and v.drawable and v.y < mapheight-.5 then
			--get if player offscreen
			local right, left, up, down = false, false, false, false
			if v.x > xscroll+width then
				right = true
			end
			
			if v.x+v.width < xscroll then
				left = true
			end
			
			if v.y > yscroll + .5 + height then
				down = true
			end
			
			if v.y+v.height < yscroll +.5 then
				up = true
			end
			
			if up or left or down or right then
				local x, y
				local angx, angy = 0, 0
				
				if right then
					x = width
					angx = 1
				elseif left then
					x = 0
					angx = -1
				end
				
				if up then
					y = 0
					angy = -1
				elseif down then
					y = height
					angy = 1
				end
				
				if not x then
					x = v.x-xscroll+v.width/2
				end
				
				if not y then
					y = v.y-yscroll-3/16
				end
				
				local r = -math.atan2(angx, angy)-math.pi/2
				
				--limit x or y if right angle
				if math.mod(r, math.pi/2) == 0 then
					if up or down then
						x = math.max(x, 15/16)
						x = math.min(x, width-15/16)
					else
						y = math.max(y, 15/16)
						y = math.min(y, height-15/16)
					end
				end
				
				love.graphics.setColor(background)
				love.graphics.draw(markbaseimg, math.floor(x*16*scale), math.floor(y*16*scale), r, scale, scale, 0, 15)
				
				local dist = 21.5
				
				local xadd = math.cos(r)*dist
				local yadd = math.sin(r)*dist
				
				love.graphics.setColor(255, 255, 255)
				love.graphics.setStencil(function() love.graphics.circle("fill", math.floor((x*16+xadd)*scale), math.floor((y*16+yadd-.5)*scale), 13.5*scale) end)
				
				local playerx, playery = x*16+xadd, y*16+yadd+3
				
				--draw map
				for x = math.floor(v.x), math.floor(v.x)+3 do
					for y = math.floor(v.y), math.floor(v.y)+3 do
						if inmap(x, y) then
							tilenumber = map[x][y][1]
							
							if tilenumber ~= 0 and tilequads[tilenumber].invisible == false then
								local img
								
								if tilenumber <= smbtilecount then
									img = smbtilesimg
								elseif tilenumber <= smbtilecount+portaltilecount then
									img = portaltilesimg
								elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
									img = customtilesimg
								end
								
								love.graphics.drawq(img, tilequads[tilenumber].quad, math.floor((x-1-v.x-6/16)*16*scale+playerx*scale), math.floor((y-1.5-v.y)*16*scale+playery*scale), 0, scale, scale)
							end
						end
					end
				end
				
				drawplayer(i, playerx, playery)
				
				love.graphics.setStencil()
				
				love.graphics.setColor(v.colors[1] or {255, 255, 255})
				love.graphics.draw(markoverlayimg, math.floor(x*16*scale), math.floor(y*16*scale), r, scale, scale, 0, 15)
			end
		end
	love.graphics.setScissor()
	end
	
	--Physics debug
	if physicsdebug then
		local lw = love.graphics.getLineWidth()
		love.graphics.setLineWidth(1)
		for i, v in pairs(objects) do
			for j, k in pairs(v) do
				if k.width then
					if xscroll >= k.x-width and k.x+k.width > xscroll then
						if k.active then
							love.graphics.setColor(255, 255, 255)
						else
							love.graphics.setColor(255, 0, 0)
						end
						
						love.graphics.rectangle("line", (k.x-xscroll)*16*scale, (k.y-yscroll-.5)*16*scale, k.width*16*scale, k.height*16*scale)
					end
				end
			end
		end
		love.graphics.setLineWidth(lw)
	end
	
	--Use region debug
	if userectdebug then
		love.graphics.setColor(255, 255, 255, 100)
		for i, k in pairs(userects) do
			love.graphics.rectangle("fill", (k.x-xscroll)*16*scale, (k.y-yscroll-.5)*16*scale, k.width*16*scale, k.height*16*scale)
		end
		love.graphics.setColor(255, 255, 255, 255)
	end
	
	
	--portalwalldebug
	if portalwalldebug then
		for j, v in pairs(portals) do
			for k = 1, 2 do
				for i = 1, 6 do
					if objects["portalwall"][v.number .. "-" .. k .. "-" .. i] then
						objects["portalwall"][v.number .. "-" .. k .. "-" .. i]:draw()
					end
				end
			end
		end
	end
	
	for i, v in pairs(dialogboxes) do
		v:draw()
	end
	
	if earthquake > 0 then
		love.graphics.translate(-round(tremorx), -round(tremory))
	end
	
	if editormode then
		editor_draw()
	end
	
	--speed gradient
	if bullettime and speed < 1 then
		love.graphics.setColor(255, 255, 255, 255-255*speed)
		love.graphics.draw(gradientimg, 0, 0, 0, scale, scale)
	end
	
	if yoffset < 0 then
		love.graphics.translate(0, -yoffset*scale)
	end
	love.graphics.translate(0, yoffset*scale)
	
	if testlevel then
		love.graphics.setColor(255, 0, 0)
		properprint("testing level - press esc to return to editor", 0, 0)
	end
	
	--pause menu
	if pausemenuopen then
		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", (width*8*scale)-50*scale, (112*scale)-75*scale, 100*scale, 150*scale)
		love.graphics.setColor(255, 255, 255)
		drawrectangle(width*8-49, 112-74, 98, 148)
		
		for i = 1, #pausemenuoptions do
			love.graphics.setColor(100, 100, 100, 255)
			if pausemenuselected == i and not menuprompt and not desktopprompt then
				love.graphics.setColor(255, 255, 255, 255)
				properprint(">", (width*8*scale)-45*scale, (112*scale)-60*scale+(i-1)*25*scale)
			end
			properprint(pausemenuoptions[i], (width*8*scale)-35*scale, (112*scale)-60*scale+(i-1)*25*scale)
			properprint(pausemenuoptions2[i], (width*8*scale)-35*scale, (112*scale)-50*scale+(i-1)*25*scale)
			
			if pausemenuoptions[i] == "volume" then
				drawrectangle((width*8)-34, 68+(i-1)*25, 74, 1)
				drawrectangle((width*8)-34, 65+(i-1)*25, 1, 7)
				drawrectangle((width*8)+40, 65+(i-1)*25, 1, 7)
				love.graphics.draw(volumesliderimg, math.floor(((width*8)-35+74*volume)*scale), (112*scale)-47*scale+(i-1)*25*scale, 0, scale, scale)
			end
		end
		
		if menuprompt then
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(255, 255, 255, 255)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprint("quit to menu?", (width*8*scale)-string.len("quit to menu?")*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale) 
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
		
		if desktopprompt then
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(255, 255, 255, 255)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprint("quit to desktop?", (width*8*scale)-string.len("quit to desktop?")*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
		
		if suspendprompt then
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(255, 255, 255, 255)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprint("suspend game? this can", (width*8*scale)-string.len("suspend game? this can")*4*scale, (112*scale)-20*scale)
			properprint("only be loaded once!", (width*8*scale)-string.len("only be loaded once!")*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
	end
	
	if arcade and not pausemenuopen then
		
		local drawtitle = true
		for i = 1, players do
			if arcadeplaying[i] then
				drawtitle = false
			end
		end
		if drawtitle then
			love.graphics.setColor(0, 0, 0, 100)
			love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
			love.graphics.setColor(255, 255, 255)
			love.graphics.draw(mari0img, 0, height*8*scale, 0, scale/5, scale/5, 0, mari0img:getHeight()/2)
			
			if arcadestartblink < arcadeblinkrate*0.8 then
				properprint("press", 10*scale, 160*scale, 3*scale)
				properprint("start", 144*scale, 160*scale, 3*scale)
			end
		end
	end

	if ttqrimg then
		love.graphics.draw(ttqrimg, 0, 0, 0, scale*2, scale*2)
	end
end

function drawplayer(i, x, y, cscale,     offsetX, offsetY, rotation, quadcenterX, quadcenterY, animationstate, underwater, ducking, hats, graphic, quad, pointingangle, shot, upsidedown, colors, lastportal, portal1color, portal2color, runframe, swimframe, climbframe, jumpframe, biggraphic, fireanimationtimer, char)
	x = x-6

	local scale = scale
	if cscale then
		scale = cscale
	end
	
	local v
	
	if not offsetX then
		v = objects["player"][i]
	else
		v = {offsetX=offsetX, offsetY=offsetY, rotation=rotation, quadcenterX=quadcenterX, quadcenterY=quadcenterY, animationstate=animationstate, underwater=underwater, ducking=ducking, hats=hats, graphic=graphic, quad=quad, pointingangle=pointingangle, shot=shot, upsidedown=upsidedown, colors=colors, lastportal=lastportal, portal1color=portal1color, portal2color=portal2color, runframe=runframe, swimframe=swimframe, climbframe=climbframe, jumpframe=jumpframe, biggraphic=biggraphic, fireanimationtimer=fireanimationtimer, char=char}
		if v.char and v.graphic == v.char.biggraphic then
			v.size = 2
		else
			v.size = 1
		end
	end
	
	if (not objects or not objects["player"][i] or objects["player"][i].portalsavailable[1] or objects["player"][i].portalsavailable[2]) then
		if v.pointingangle > 0 then
			dirscale = -scale
		else
			dirscale = scale
		end
	else
		if objects["player"][i].animationdirection == "right" then
			dirscale = scale
		else
			dirscale = -scale
		end
	end
	
	local horscale = scale
	if v.shot or v.upsidedown then
		horscale = -scale
	end
	
	if type(v.graphic) == "table" then
		for k = 1, #v.graphic do
			if v.colors[k] then
				love.graphics.setColor(v.colors[k])
			else
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.drawq(v.graphic[k], v.quad, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end
	else
		if v.graphic and v.quad then
			love.graphics.setColor(255, 255, 255)
			love.graphics.drawq(v.graphic, v.quad, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end	
	end
	
	
	if v.drawhat ~= false then
		local offsets = gethatoffset(v.char, v.graphic, v.animationstate, v.runframe, v.jumpframe, v.climbframe, v.swimframe, v.underwater, v.infunnel, v.fireanimationtimer, v.ducking)
		
		if offsets and #v.hats > 0 then
			local yadd = 0
			for i = 1, #v.hats do
				if v.hats[i] == 1 then
					love.graphics.setColor(v.colors[1])
				else
					love.graphics.setColor(255, 255, 255)
				end
				if v.graphic == v.biggraphic or v.animationstate == "grow" then
					love.graphics.draw(bighat[v.hats[i]].graphic, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
					yadd = yadd + bighat[v.hats[i]].height
				else
					local debugtable = {x, v.offsetX, y, v.offsetY, v.quadcenterX, hat[v.hats[i]].x, offsets[1], v.quadcenterY, hat[v.hats[i]].y, offsets[2], yadd}
					--TIMETRIAL
					for i, v in pairs(debugtable) do
						if type(v) == "table" then
							return
						end
					end
					
					love.graphics.draw(hat[v.hats[i]].graphic, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
					yadd = yadd + hat[v.hats[i]].height
				end
			end
		end
	end
	
	if type(v.graphic) == "table" then
		if v.graphic[0] then
			love.graphics.setColor(255, 255, 255)
			love.graphics.drawq(v.graphic[0], v.quad, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end
		if v.graphic.dot then
			love.graphics.setColor(unpack(v["portal" .. v.lastportal .. "color"]))
			love.graphics.drawq(v.graphic["dot"], v.quad, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end	
	end
end

function reachedx(currentx)
	if not currentx or currentx <= lastrepeat+width then
		return
	end
	
	lastrepeat = math.floor(currentx)-width
	--castlerepeat?
	--get mazei
	local mazei = 0
	
	for j = 1, #mazeends do
		if mazeends[j] < currentx then
			mazei = j
		end
	end
	
	--check if maze was solved!
	for i = 1, players do
		if objects["player"][i].mazevar == mazegates[mazei] then
			local actualmaze = 0
			for j = 1, #mazestarts do
				if objects["player"][i].x > mazestarts[j] then
					actualmaze = j
				end
			end
			mazesolved[actualmaze] = true
			for j = 1, players do
				objects["player"][j].mazevar = 0
			end
			break
		end
	end
	
	if not mazesolved[mazei] or mazeinprogress then --get if inside maze
		if not mazesolved[mazei] then
			mazeinprogress = true
		end
		
		local x = math.ceil(currentx)
		
		if repeatX == 0 then
			repeatX = mazestarts[mazei]
		end
		
		table.insert(map, x, {{1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}})
		for y = 1, mapheight do
			for j = 1, #map[repeatX][y] do
				map[x][y][j] = map[repeatX][y][j]
			end
			map[x][y]["gels"] = {}
			map[x][y]["portaloverride"] = {}
			
			for cox = mapwidth, x, -1 do
				--move objects
				if objects["tile"][cox .. "-" .. y] then
					objects["tile"][cox + 1 .. "-" .. y] = tile:new(cox, y-1)
					objects["tile"][cox .. "-" .. y] = nil
				end
			end
			
			--create object for block
			if tilequads[map[repeatX][y][1]].collision == true then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
			end
		end
		mapwidth = mapwidth + 1
		repeatX = repeatX + 1
		if flagx then
			flagx = flagx + 1
			flagimgx = flagimgx + 1
			objects["screenboundary"]["flag"].x = objects["screenboundary"]["flag"].x + 1
		end
		
		if axex then
			axex = axex + 1
			objects["screenboundary"]["axe"].x = objects["screenboundary"]["axe"].x + 1
		end
		
		if firestartx then
			firestartx = firestartx + 1
		end
		
		objects["screenboundary"]["right"].x = objects["screenboundary"]["right"].x + 1
		
		--move mazestarts and ends
		for i = 1, #mazestarts do
			mazestarts[i] = mazestarts[i]+1
			mazeends[i] = mazeends[i]+1
		end
		
		--check for endblock
		local x = math.ceil(currentx)
		for y = 1, mapheight do
			if map[x][y][2] and entityquads[map[x][y][2]].t == "mazeend" then
				if mazesolved[mazei] then
					repeatX = mazestarts[mazei+1]
				end
				mazeinprogress = false
			end
		end
		
		--reset thingie
		
		local x = math.ceil(currentx)-1
		for y = 1, mapheight do
			if map[x][y][2] and entityquads[map[x][y][2]].t == "mazeend" then
				for j = 1, players do
					objects["player"][j].mazevar = 0
				end
			end
		end
	end
	
	--ENEMY STUFF
	--[[if editormode == false and currentx < mapwidth then
		for y = 1, mapheight do
			spawnenemy(currentx, y)
		end
		if goombaattack then
			local randomtable = {}
			for y = 1, mapheight do
				table.insert(randomtable, y)
			end
			while #randomtable > 0 do
				local rand = math.random(#randomtable)
				if tilequads[map[currentx][randomtable[rand] ][1] ].collision then
					table.remove(randomtable, rand)
				else
					table.insert(objects["goomba"], goomba:new(currentx-.5, math.random(13)))
					break
				end
			end
		end
	end--]]
end

function loadlevel(level)
	collectgarbage("collect")
	love.audio.stop()
	animationsystem_load()
	
	timetrialstarted = false
	ttcountdown = 3
	ttname = ""
	ttstate = "demo"
	ttcurrentletter = 1
	ttname = ""
	autoscroll = false
	ttrestarttimer = 0
	amountofreplays = #replaydata
	
	ttidletimer = 0
	
	replayi = 0
	
	mariosizes[1] = 1

	local sublevel = false
	if type(level) == "number" then
		sublevel = true
	end
	
	if sublevel then
		prevsublevel = mariosublevel
		mariosublevel = level
		if level ~= 0 then
			level = marioworld .. "-" .. mariolevel .. "_" .. level
		else
			level = marioworld .. "-" .. mariolevel
		end
	else
		local s = level:split("_")
		if s[2] then
			mariosublevel = tonumber(s[2])
		else
			mariosublevel = 0
		end
		prevsublevel = false
		mariotime = 400
		
		--check for checkpoint!
		if checkpointsub then
			mariosublevel = checkpointsub
			
			if checkpointsub ~= 0 then
				level = marioworld .. "-" .. mariolevel .. "_" .. checkpointsub
			else
				level = marioworld .. "-" .. mariolevel
			end
		end
	end
	
	--MISC VARS
	everyonedead = false
	levelfinished = false
	coinanimation = 1
	flagx = false
	levelfinishtype = nil
	firestartx = false
	firestarted = false
	firedelay = math.random(4)
	flyingfishdelay = 1
	flyingfishstarted = false
	flyingfishstartx = false
	flyingfishendx = false
	bulletbilldelay = 1
	bulletbillstarted = false
	bulletbillstartx = false
	bulletbillendx = false
	firetimer = firedelay
	flyingfishtimer = flyingfishdelay
	bulletbilltimer = bulletbilldelay
	axex = false
	axey = false
	lakitoendx = false
	lakitoend = false
	noupdate = false
	xscroll = 0
	repeatX = 0
	lastrepeat = 0
	ylookmodifier = 0
	displaywarpzonetext = false
	mazestarts = {}
	mazeends = {}
	mazesolved = {}
	mazesolved[0] = true
	mazeinprogress = false
	earthquake = 0
	sunrot = 0
	gelcannontimer = 0
	pausemenuselected = 1
	coinblocktimers = {}
	
	portaldelay = {}
	for i = 1, players do
		portaldelay[i] = 0
	end
	
	--Minecraft
	breakingblockX = false
	breakingblockY = false
	breakingblockprogress = 0
	
	--class tables
	coinblockanimations = {}
	scrollingscores = {}
	scrollingtexts = {}
	portalparticles = {}
	portalprojectiles = {}
	emancipationgrills = {}
	platformspawners = {}
	rocketlaunchers = {}
	userects = {}
	blockdebristable = {}
	fireworks = {}
	seesaws = {}
	bubbles = {}
	rainbooms = {}
	emancipateanimations = {}
	emancipationfizzles = {}
	textentities = {}
	pedestals = {}
	dialogboxes = {}
	miniblocks = {}
	inventory = {}
	for i = 1, 9 do
		inventory[i] = {}
	end
	mccurrentblock = 1
	itemanimations = {}
	
	blockbouncetimer = {}
	blockbouncex = {}
	blockbouncey = {}
	blockbouncecontent = {}
	blockbouncecontent2 = {}
	warpzonenumbers = {}
	
	portals = {}
	
	objects = {}
	objects["player"] = {}
	objects["portalwall"] = {}
	objects["tile"] = {}
	objects["vine"] = {}
	objects["box"] = {}
	objects["door"] = {}
	objects["button"] = {}
	objects["groundlight"] = {}
	objects["wallindicator"] = {}
	objects["walltimer"] = {}
	objects["notgate"] = {}
	objects["orgate"] = {}
	objects["andgate"] = {}
	objects["musicentity"] = {}
	objects["enemyspawner"] = {}
	objects["squarewave"] = {}
	objects["lightbridge"] = {}
	objects["lightbridgebody"] = {}
	objects["faithplate"] = {}
	objects["laser"] = {}
	objects["laserdetector"] = {}
	objects["gel"] = {}
	objects["geldispenser"] = {}
	objects["cubedispenser"] = {}
	objects["pushbutton"] = {}
	objects["fireball"] = {}
	objects["platform"] = {}
	objects["platformspawner"] = {}
	objects["castlefire"] = {}
	objects["castlefirefire"] = {}
	objects["bowser"] = {}
	objects["spring"] = {}
	objects["seesawplatform"] = {}
	objects["ceilblocker"] = {}
	objects["funnel"] = {}
	objects["panel"] = {}
	objects["scaffold"] = {}
	objects["regiontrigger"] = {}
	objects["animationtrigger"] = {}
	objects["checkpoints"] = {}
	objects["portalent"] = {}
	objects["actionblock"] = {}
	
	--!
	objects["enemy"] = {}
	
	xscroll = 0
	yscroll = 0
	ylookmodifier = 0
	
	startx = {3, 3, 3, 3, 3}
	starty = {13, 13, 13, 13, 13}
	pipestartx = nil
	pipestarty = nil
	local animation = nil
	
	enemiesspawned = {}
	
	intermission = false
	haswarpzone = false
	underwater = false
	bonusstage = false
	custombackground = false
	mariotimelimit = 400
	spriteset = 1
	
	--LOAD THE MAP
	if loadmap(level) == false then --make one up
		mapwidth = width
		background = {unpack(backgroundcolor[1])}
		mapheight = 15
		portalsavailable = {true, true}
		musicname = "overworld.ogg"
		map = {}
		for x = 1, width do
			map[x] = {}
			for y = 1, mapheight do
				if y > 13 then
					map[x][y] = {2}
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
					map[x][y]["gels"] = {}
					map[x][y]["portaloverride"] = {}
				else
					map[x][y] = {1}
					map[x][y]["gels"] = {}
					map[x][y]["portaloverride"] = {}
				end
			end
		end
	end
	
	
	enemies_load()
	
	objects["screenboundary"] = {}
	objects["screenboundary"]["left"] = screenboundary:new(0)
	
	objects["screenboundary"]["right"] = screenboundary:new(mapwidth)
	
	if flagx then
		objects["screenboundary"]["flag"] = screenboundary:new(flagx+6/16)
	end
	
	if axex then
		objects["screenboundary"]["axe"] = screenboundary:new(axex+1)
	end
	
	if intermission then
		animation = "intermission"
	end
	
	if not sublevel then
		mariotime = mariotimelimit
	end
	
	--Maze setup
	--check every block between every start/end pair to see how many gates it contains
	if #mazestarts == #mazeends then
		mazegates = {}
		for i = 1, #mazestarts do
			local maxgate = 1
			for x = mazestarts[i], mazeends[i] do
				for y = 1, mapheight do
					if map[x][y][2] and entityquads[map[x][y][2]] and entityquads[map[x][y][2]].t == "mazegate" then
						if tonumber(map[x][y][3]) > maxgate then
							maxgate = tonumber(map[x][y][3])
						end
					end
				end
			end
			mazegates[i] = maxgate
		end
	else
		print("Mazenumber doesn't fit!")
	end
	
	--background
	love.graphics.setBackgroundColor(unpack(background))
	
	--check if it's a bonusstage (boooooooonus!)
	if bonusstage then
		animation = "vinestart"
	end
		
	--set startx to pipestart
	if pipestartx then
		startx = {pipestartx-1, pipestartx-1, pipestartx-1, pipestartx-1, pipestartx-1}
		starty = {pipestarty, pipestarty, pipestarty, pipestarty, pipestarty}
		--check if startpos is a colliding block
		if tilequads[map[startx[1]][starty[1]][1]].collision then
			animation = "pipeup"
		end
	end
	
	--set starts to checkpoint
	if not sublevel and checkpointsub then
		for i = 1, 5 do
			if checkpointx[i] then
				startx[i] = checkpointx[i]
			end
			if checkpointy[i] then
				starty[i] = checkpointy[i]
			end
		end
	end
	
	--Adjust start X scroll
	xscroll = startx[1]-scrollingleftcomplete-2
	if xscroll > mapwidth - width then
		xscroll = mapwidth - width
	end
	
	if xscroll < 0 then
		xscroll = 0
	end
	
	--and Y too
	yscroll = starty[1]-height+downscrollborder
	if yscroll > mapheight - height - 1 then
		yscroll = mapheight - height - 1
	end
	
	if yscroll < 0 then
		yscroll = 0
	end
	
	spawnrestrictions = {}
	
	--Clear spawn area from enemies
	for i = 1, #startx do
		if startx[i] == checkpointx[i] and starty[i] == checkpointy[i] then
			table.insert(spawnrestrictions, {startx[i], starty[i]})
		end
	end
	
	--add the players
	local mul = 0.5
	if mariosublevel ~= 0 or prevsublevel ~= false then
		mul = 2/16
	end
	
	objects["player"] = {}
	local spawns = {}
	for i = 1, players do
		local animation = animation
		
		if arcade and not arcadeplaying[i] then
			animation = nil
		end
		
		local astartx, astarty
		if i > 4 then
			astartx = startx[5]
			astarty = starty[5]
		else
			astartx = startx[i]
			astarty = starty[i]
		end
		
		if astartx then
			local add = -6/16
			for j, v in pairs(spawns) do
				if v.x == astartx and v.y == astarty then
					add = add + mul
				end
			end
			
			table.insert(spawns, {x=astartx, y=astarty})
			
			objects["player"][i] = mario:new(astartx+add, astarty-1, i, animation, mariosizes[i], playertype)
		else
			objects["player"][i] = mario:new(1.5 + (i-1)*mul-6/16+1.5, 13, i, animation, mariosizes[i], playertype)
		end
	end
	
	--disable non playing players
	if arcade then
		for i = 1, players do
			if not arcadeplaying[i] then
				objects["player"][i].active = false
				objects["player"][i].drawable = false
				objects["player"][i].controlsenabled = false
			end
		end
	end
	
	--ADD ENEMIES ON START SCREEN
	if editormode == false then
		local xtodo = width+1
		if mapwidth < width+1 then
			xtodo = mapwidth
		end
			
		for x = math.floor(xscroll), math.floor(xscroll)+xtodo do
			for y = 1, mapheight do
				spawnenemy(x, y)
			end
		end
	end
	
	--load editor
	editor_load()
	
	updateranges()
	
	generatespritebatch()

	if timetrials then
		objects["player"][1].controlsenabled = false
		objects["player"][1].drawable = false
	end

	
	-- set up replays
	print("game load!")
	replays = {}
	for _, v in ipairs(replaydata) do
		table.insert(replays, replay:new(v))
	end
end

function ttlosetime()
	mariotime = mariotime - 7.5
	table.insert(scrollingtexts, scrollingtext:new("-3sec", objects["player"][1].x-0.7, objects["player"][1].y))
	
	local framesLost = 3*(1/targetdt)

	for _, v in ipairs(replays) do
		v:tick(framesLost)
	end
	
	objects.player[1].replayFrames = objects.player[1].replayFrames + framesLost
	objects.player[1].noChangeFrames = objects.player[1].noChangeFrames + framesLost
end

function ttentrydown()
	if ttrestarttimer > 0 then
		return
	end
	arcadestartblink = 0
	ttcurrentletter = ttcurrentletter - 1
	if ttcurrentletter <= 0 then
		ttcurrentletter = #ttalphabet
	end
	playsound("fireball")
end

function ttentryup()
	if ttrestarttimer > 0 then
		return
	end
	arcadestartblink = 0
	ttcurrentletter = ttcurrentletter + 1
	if ttcurrentletter > #ttalphabet then
		ttcurrentletter = 1
	end
	playsound("fireball")
end

function startlevel(levelstart)
	gamestate = "game"
	skipupdate = true
	
	--PLAY BGM
	if intermission == false then
		playmusic()
	else
		playsound("intermission")
	end
	
	if replaysystem and levelstart then
		livereplaydata = {{}}
		livereplaydelay = {0}
		livereplaystored = {{}}
	end
	
	if timetrials then
		local self = objects["player"][1]
	
		self.size = 1
		self.colors = mariocolors[self.playernumber]
		self.drawable = true
		self.height = 12/16
	end
end

function loadmap(filename)
	print("**************************" .. string.rep("*", #(mappack .. filename)))
	print("* Loading mappacks/" .. mappack .. "/" .. filename .. ".txt *")
	if love.filesystem.exists("mappacks/" .. mappack .. "/" .. filename .. ".txt") == false then
		print("mappacks/" .. mappack .. "/" .. filename .. ".txt not found!")
		return false
	end
	local s = love.filesystem.read( "mappacks/" .. mappack .. "/" .. filename .. ".txt" )
	local s2 = s:split(";")
	
	local t
	if string.find(s2[1], ",") then
		mapheight = 15
		t = s2[1]:split(",")
	else
		mapheight = tonumber(s2[1])
		t = s2[2]:split(",")
	end
	
	map = {}
	unstatics = {}
	
	--get mapwidth
	local entries = 0
	for i = 1, #t do
		local s = t[i]:split("*")
		if s[2] then
			entries = entries + tonumber(s[2])
		else
			entries = entries + 1
		end
	end
	
	if math.mod(entries, mapheight) ~= 0 then
		print("Incorrect number of entries: " .. #t)
		return false
	end
	
	mapwidth = entries/mapheight
	coinmap = {}
	
	for x = 1, mapwidth do
		map[x] = {}
		coinmap[x] = {}
		for y = 1, mapheight do
			map[x][y] = {}
			map[x][y]["gels"] = {}
			map[x][y]["portaloverride"] = {}
		end
	end
	
	local x, y = 1, 1
	for i = 1, #t do
		if string.find(t[i], "*") then --new stuff!
			local r = tostring(t[i]):split("*")
			
			local coin = false
			if string.sub(r[1], -1) == "c" then
				r[1] = string.sub(r[1], 1, -2)
				coin = true
			end
			
			for j = 1, tonumber(r[2]) do
				if coin then
					coinmap[x][y] = true
				end
			
				if (tonumber(r[1]) > smbtilecount+portaltilecount+customtilecount and tonumber(r[1]) <= 10000) or tonumber(r[1]) > 10000+animatedtilecount then
					r[1] = 1
				end
				
				map[x][y][1] = tonumber(r[1])
				
			
				--create object for block
				if tilequads[tonumber(r[1])].collision == true then
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				end
				
				x = x + 1
				if x > mapwidth then
					x = 1
					y = y + 1
				end
			end
			
		else --Old stuff.
			local r = tostring(t[i]):split("-")
			
			if string.sub(r[1], -1) == "c" then
				r[1] = string.sub(r[1], 1, -2)
				coinmap[x][y] = true
			end
			
			if (tonumber(r[1]) > smbtilecount+portaltilecount+customtilecount and tonumber(r[1]) <= 10000) or tonumber(r[1]) > 10000+animatedtilecount then
				r[1] = 1
			end
			
			for i = 1, #r do
				if tonumber(r[i]) then
					map[x][y][i] = tonumber(r[i])
				else
					map[x][y][i] = r[i]
				end
			end
			
			--create object for block
			if tilequads[tonumber(r[1])].collision == true then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
			end
			
			x = x + 1
			if x > mapwidth then
				x = 1
				y = y + 1
			end
		end
	end
	
	for y = 1, mapheight do
		for x = 1, mapwidth do
			local r = map[x][y]
			if tilequads[r[1] ].coin then
				coinmap[x][y] = true
			end
			
			if #r > 1 then 
				if entityquads[r[2]] then
					local t = entityquads[r[2]].t
					if t == "spawn" then
						local r2 = {unpack(r)}
						table.remove(r2, 1)
						table.remove(r2, 1)
						
						--compatibility for Mari0
						if #r2 == 0 then
							startx = {x, x, x, x, x}
							starty = {y, y, y, y, y}
						else
							if r2[1] == "true" then --all
								startx = {x, x, x, x, x}
								starty = {y, y, y, y, y}
							else
								for i = 1, 5 do
									if r2[i+1] == "true" then
										startx[i] = x
										starty[i] = y
									end
								end
							end
						end
						
					elseif not editormode then
						if t == "warppipe" then
							table.insert(warpzonenumbers, {x, y, r[3]})
							
						elseif t == "manycoins" then
							map[x][y][3] = 7
							
						elseif t == "flag" then
							flagx = x-1
							flagy = y
							
						elseif t == "firestart" then
							firestartx = x
							
						elseif t == "flyingfishstart" then
							flyingfishstartx = x
						elseif t == "flyingfishend" then
							flyingfishendx = x
							
						elseif t == "bulletbillstart" then
							bulletbillstartx = x
						elseif t == "bulletbillend" then
							bulletbillendx = x
							
						elseif t == "axe" then
							axex = x
							axey = y
						
						elseif t == "lakitoend" then
							lakitoendx = x
							
						elseif t == "pipespawn" and (prevsublevel == r[3]-1 or (mariosublevel == r[3]-1 and blacktime == sublevelscreentime)) then
							pipestartx = x
							pipestarty = y
							
						elseif t == "gel" then
							if tilequads[map[x][y][1]].collision then
								if r[4] == "true" then
									map[x][y]["gels"]["left"] = r[3]
								end
								if r[5] == "true" then
									map[x][y]["gels"]["top"] = r[3]
								end
								if r[6] == "true" then
									map[x][y]["gels"]["right"] = r[3]
								end
								if r[7] == "true" then
									map[x][y]["gels"]["bottom"] = r[3]
								end
							end
							
						elseif t == "checkpoint" then
							table.insert(objects["checkpoints"], checkpoint:new(x, y, r))
						elseif t == "mazestart" then
							if not tablecontains(mazestarts, x) then
								table.insert(mazestarts, x)
							end
							
						elseif t == "mazeend" then
							if not tablecontains(mazeends, x) then
								table.insert(mazeends, x)
							end
							
						elseif t == "emance" then
							table.insert(emancipationgrills, emancipationgrill:new(x, y, r))
							
						elseif t == "door" then
							table.insert(objects["door"], door:new(x, y, r))
							
						elseif t == "button" then
							table.insert(objects["button"], button:new(x, y, r))
							
						elseif t == "pushbutton" then
							table.insert(objects["pushbutton"], pushbutton:new(x, y, r))
							
						elseif t == "wallindicator" then
							table.insert(objects["wallindicator"], wallindicator:new(x, y, r))
							
						elseif t == "groundlightver" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 1, r))
						elseif t == "groundlighthor" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 2, r))
						elseif t == "groundlightupright" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 3, r))
						elseif t == "groundlightrightdown" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 4, r))
						elseif t == "groundlightdownleft" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 5, r))
						elseif t == "groundlightleftup" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 6, r))
							
						elseif t == "faithplate" then
							table.insert(objects["faithplate"], faithplate:new(x, y, r))
							
						elseif t == "laser" then
							table.insert(objects["laser"], laser:new(x, y, r))
							
						elseif t == "lightbridge" then
							table.insert(objects["lightbridge"], lightbridge:new(x, y, r))
							
						elseif t == "laserdetector" then
							table.insert(objects["laserdetector"], laserdetector:new(x, y, r))
							
						elseif t == "boxtube" then
							table.insert(objects["cubedispenser"], cubedispenser:new(x, y, r))
						
						elseif t == "timer" then
							table.insert(objects["walltimer"], walltimer:new(x, y, r))
							
						elseif t == "notgate" then
							table.insert(objects["notgate"], notgate:new(x, y, r))
							
						elseif t == "orgate" then
							table.insert(objects["orgate"], orgate:new(x, y, r))
							
						elseif t == "andgate" then
							table.insert(objects["andgate"], andgate:new(x, y, r))
							
						elseif t == "musicentity" then
							table.insert(objects["musicentity"], musicentity:new(x, y, r))
							
						elseif t == "enemyspawner" then
							table.insert(objects["enemyspawner"], enemyspawner:new(x, y, r))
							
						elseif t == "squarewave" then
							table.insert(objects["squarewave"], squarewave:new(x, y, r))
							
						elseif t == "platformspawner" then
							table.insert(platformspawners, platformspawner:new(x, y, r))
							
						elseif t == "scaffold" then
							table.insert(objects["scaffold"], scaffold:new(x, y, r))
							
						elseif t == "box" then
							table.insert(objects["box"], box:new(x, y))
							
						elseif t == "portal1" then
							table.insert(objects["portalent"], portalent:new(x, y, 1, r))
							
						elseif t == "portal2" then
							table.insert(objects["portalent"], portalent:new(x, y, 2, r))
							
						elseif t == "spring" then
							table.insert(objects["spring"], spring:new(x, y))
							
						elseif t == "seesaw" then
							table.insert(seesaws, seesaw:new(x, y, r))
						
						elseif t == "ceilblocker" then
							table.insert(objects["ceilblocker"], ceilblocker:new(x))
							
						elseif t == "funnel" then
							table.insert(objects["funnel"], funnel:new(x, y, r))
							
						elseif t == "regiontrigger" then
							table.insert(objects["regiontrigger"], regiontrigger:new(x, y, r))
							
						elseif t == "animationtrigger" then
							table.insert(objects["animationtrigger"], animationtrigger:new(x, y, r))
							
						elseif t == "pedestal" then
							table.insert(pedestals, pedestal:new(x, y, r))
							
						elseif t == "actionblock" then
							table.insert(objects["actionblock"], actionblock:new(x, y, r))
							
						end
					end
				end
			end
		end
	end
	
	--Add links
	for i, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.link then
				w:link()
			end
		end
	end
	
	--emancipation links
	for i, v in pairs(emancipationgrills) do
		v:link()
	end
	
	if flagx then
		flagimgx = flagx+8/16
		flagimgy = flagy-10+1/16
	end
	
	for x = 0, -30, -1 do
		map[x] = {}
		for y = 1, mapheight-2 do
			map[x][y] = {1}
		end
	
		for y = mapheight-1, mapheight do
			map[x][y] = {2}
			objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
		end
	end
	
	--background
	background = {unpack(backgroundcolor[1])}
	custombackground = false
	
	--portalgun
	portalsavailable = {true, true}
	
	levelscreenback = nil
	levelscreenbackname = nil
	
	--MORE STUFF
	for i = 3, #s2 do
		s3 = s2[i]:split("=")
		if s3[1] == "backgroundr" then
			background[1] = tonumber(s3[2])
		elseif s3[1] == "backgroundg" then
			background[2] = tonumber(s3[2])
		elseif s3[1] == "backgroundb" then
			background[3] = tonumber(s3[2])
		elseif s3[1] == "background" then
			background = {unpack(backgroundcolor[tonumber(s3[2])])}
		elseif s3[1] == "spriteset" then
			spriteset = tonumber(s3[2])
		elseif s3[1] == "intermission" then
			intermission = true
		elseif s3[1] == "haswarpzone" then
			haswarpzone = true
		elseif s3[1] == "underwater" then
			underwater = true
		elseif s3[1] == "music" then
			if tonumber(s3[2]) then
				local i = tonumber(s3[2])
				musicname = musiclist[i]
			else
				musicname = s3[2]
			end
		elseif s3[1] == "bonusstage" then
			bonusstage = true
		elseif s3[1] == "custombackground" or s3[1] == "portalbackground" then
			custombackground = true
			if s3[2] and custombackgroundimg[s3[2]] then
				custombackground = s3[2]
			end
		elseif s3[1] == "customforeground" then
			customforeground = true
			if s3[2] and custombackgroundimg[s3[2]] then
				customforeground = s3[2]
			end
		elseif s3[1] == "timelimit" then
			mariotimelimit = tonumber(s3[2])
		elseif s3[1] == "scrollfactor" then
			scrollfactor = tonumber(s3[2])
		elseif s3[1] == "fscrollfactor" then
			fscrollfactor = tonumber(s3[2])
		elseif s3[1] == "portalgun" then
			if s3[2] == "none" then
				portalsavailable = {false, false}
			elseif s3[2] == "blue" then
				portalsavailable = {true, false}
			elseif s3[2] == "orange" then
				portalsavailable = {false, true}
			end
		elseif s3[1] == "levelscreenback" then
			if love.filesystem.exists("mappacks/" .. mappack .. "/levelscreens/" .. s3[2] .. ".png") then
				levelscreenbackname = s3[2]
				levelscreenback = love.graphics.newImage("mappacks/" .. mappack .. "/levelscreens/" .. s3[2] .. ".png")
			end
		end
	end
	
	print("* DONE!" .. string.rep(" ", #(mappack .. filename)+17) .. " *")
	print("**************************" .. string.rep("*", #(mappack .. filename)))
	return true
end

function changemapwidth(width)
	if width > mapwidth then
		for x = mapwidth+1, width do
			map[x] = {}
			for y = 1, mapheight-2 do
				map[x][y] = {1}
				map[x][y].gels = {}
				map[x][y].portaloverride = {}
				objects["tile"][x .. "-" .. y] = nil
			end
		
			for y = mapheight-1, mapheight do
				map[x][y] = {2}
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				map[x][y].gels = {}
				map[x][y].portaloverride = {}
			end
		end
	end

	mapwidth = width
	objects["screenboundary"]["right"].x = mapwidth
	
	if objects["player"][1].x > mapwidth then
		objects["player"][1].x = mapwidth-1
	end
	
	generatespritebatch()
end

function changemapheight(height)
	if height > mapheight then
		for x = 1, mapwidth do
			for y = mapheight+1, height do
				map[x][y] = {currenttile}
				map[x][y].gels = {}
				map[x][y].portaloverride = {}
				
				if tilequads[currenttile].collision == true then
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
				else
					objects["tile"][x .. "-" .. y] = nil
				end			
			end
		end
	end
	
	mapheight = height
	
	for i, v in pairs(objects["screenboundary"]) do
		v.height = 1000+mapheight
	end
	
	if objects["player"][1].y > mapheight then
		objects["player"][1].y = mapheight-1
	end
	
	generatespritebatch()
end

function generatespritebatch()
	local smbmsb = smbspritebatch
	local portalmsb = portalspritebatch
	local custommsb
	if customtiles then
		custommsb = customspritebatch
	end
	smbspritebatch:clear()
	smbspritebatchfront:clear()
	
	portalspritebatch:clear()
	portalspritebatchfront:clear()
	if customtiles then
		customspritebatch:clear()
		customspritebatchfront:clear()
	end
	
	local xtodraw
	if mapwidth < width+1 then
		xtodraw = math.ceil(mapwidth)
	else
		if mapwidth > width and xscroll < mapwidth-width then
			xtodraw = math.ceil(width+1)
		else
			xtodraw = math.ceil(width)
		end
	end
	
	local ytodraw
	if mapheight < height+1 then
		ytodraw = math.ceil(mapheight)
	else
		if mapheight > height and yscroll < mapheight-height then
			ytodraw = height+1
		else
			ytodraw = height
		end
	end
	
	local lmap = map
	
	local flooredxscroll
	if xscroll >= 0 then
		flooredxscroll = math.floor(xscroll)
	else
		flooredxscroll = math.ceil(xscroll)
	end
	
	local flooredyscroll
	if yscroll >= 0 then
		flooredyscroll = math.floor(yscroll)
	else
		flooredyscroll = math.ceil(yscroll)
	end
	
	for y = 0, ytodraw+1 do
		for x = 1, xtodraw do
			if inmap(flooredxscroll+x, math.min(flooredyscroll+y+1, mapheight)) then
				local bounceyoffset = 0
				
				local draw = true
				for i, v in pairs(blockbouncex) do
					if blockbouncex[i] == flooredxscroll+x and blockbouncey[i] == math.min(flooredyscroll+y+1, mapheight) then
						draw = false
					end
				end	
				if draw == true then
					local t = lmap[flooredxscroll+x][math.min(flooredyscroll+y+1, mapheight)]
					
					local tilenumber = t[1]
					
					if not tilequads[tilenumber].foreground then
						if tilenumber ~= 0 and tilequads[tilenumber].invisible == false and tilequads[tilenumber].coinblock == false then
							if tilenumber <= smbtilecount then
								smbspritebatch:addq( tilequads[tilenumber].quad, (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
							elseif tilenumber <= smbtilecount+portaltilecount then
								portalspritebatch:addq( tilequads[tilenumber].quad, (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
							elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
								customspritebatch:addq( tilequads[tilenumber].quad, (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
							end
						end
					else
						if tilenumber ~= 0 and tilequads[tilenumber].invisible == false and tilequads[tilenumber].coinblock == false then
							if tilenumber <= smbtilecount then
								smbspritebatchfront:add( tilequads[tilenumber].quad, (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
							elseif tilenumber <= smbtilecount+portaltilecount then
								portalspritebatchfront:add( tilequads[tilenumber].quad, (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
							elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
								customspritebatchfront:add( tilequads[tilenumber].quad, (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
							end
						end
					end
				end
			end
		end
	end
end

function game_keypressed(key, unicode)
	if key == "return" then
		game_joystickpressed(1, 4)
	end
	
	if key == "f" then
		objects["player"][1]:grow()
	end
	
	if key == "g" then
		timetrialstarted = true
	end

	if pausemenuopen then
		if menuprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					pausemenuopen = false
					saveconfig()
					menuprompt = false
					menu_load()
				else
					menuprompt = false
				end
			elseif key == "escape" then
				menuprompt = false
			end
			return
		elseif desktopprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					love.event.quit()
				else
					desktopprompt = false
				end
			elseif key == "escape" then
				desktopprompt = false
			end
			return
		elseif suspendprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					suspendgame()
					suspendprompt = false
					pausemenuopen = false
					saveconfig()
				else
					suspendprompt = false
				end
			elseif key == "escape" then
				suspendprompt = false
			end
			return
		end
		if (key == "down" or key == "s") then
			if pausemenuselected < #pausemenuoptions then
				pausemenuselected = pausemenuselected + 1
			end
		elseif (key == "up" or key == "w") then
			if pausemenuselected > 1 then
				pausemenuselected = pausemenuselected - 1
			end
		elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			if pausemenuoptions[pausemenuselected] == "resume" then
				pausemenuopen = false
				saveconfig()
				love.audio.resume()
			elseif pausemenuoptions[pausemenuselected] == "suspend" then
				suspendprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "menu" then
				menuprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "desktop" then
				desktopprompt = true
				pausemenuselected2 = 1
			end
		elseif key == "escape" then
			pausemenuopen = false
			saveconfig()
			love.audio.resume()
		elseif (key == "right" or key == "d") then
			if pausemenuoptions[pausemenuselected] == "volume" then
				if volume < 1 then
					volume = volume + 0.1
					love.audio.setVolume( volume )
					soundenabled = true
					playsound("coin")
				end
			end
			
		elseif (key == "left" or key == "a") then
			if pausemenuoptions[pausemenuselected] == "volume" then
				volume = math.max(volume - 0.1, 0)
				love.audio.setVolume( volume )
				if volume == 0 then
					soundenabled = false
				end
				playsound("coin")
			end
		end
			
		return
	end
	
	if endpressbutton then
		endpressbutton = false
		endgame()
		return
	end

	for i = 1, players do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:jump()
		elseif controls[i]["run"][1] == key then
			objects["player"][i]:fire()
		elseif controls[i]["reload"][1] == key then
			objects["player"][i]:removeportals()
		elseif controls[i]["use"][1] == key then
			objects["player"][i]:use()
		elseif controls[i]["left"][1] == key then
			objects["player"][i]:leftkey()
		elseif controls[i]["right"][1] == key then
			objects["player"][i]:rightkey()
		end
		
		if controls[i]["portal1"][i] == key then
			shootportal(i, 1, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
			return
		end
		
		if controls[i]["portal2"][i] == key then
			shootportal(i, 2, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
			return
		end
	end
	
	if key == "escape" then
		if not editormode and testlevel then
			checkpointsub = false
			marioworld = testlevelworld
			mariolevel = testlevellevel
			testlevel = false
			editormode = true
			loadlevel(marioworld .. "-" .. mariolevel)
			startlevel()
			return
		elseif not editormode and not everyonedead then
			pausemenuopen = true
			love.audio.pause()
			playsound("pause")
		end
	end
	
	if key == "t" then
		editormode = not editormode
	end
	
	if editormode then
		editor_keypressed(key, unicode)
	end
end

function game_keyreleased(key, unicode)
	for i = 1, players do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:stopjump()
		end
	end
end

function shootportal(plnumber, i, sourcex, sourcey, direction, mirrored)
	--check if available
	if not objects["player"][plnumber].portalsavailable[i] then
		return
	end
	
	--box
	if objects["player"][plnumber].pickup then
		return
	end
	--portalgun delay
	if portaldelay[plnumber] > 0 then
		return
	else
		portaldelay[plnumber] = portalgundelay
	end
	
	track("portals_shot_" .. i)
	
	local otheri = 1
	local color = objects["player"][plnumber].portal2color
	if i == 1 then
		otheri = 2
		color = objects["player"][plnumber].portal1color
	end
	
	if not mirrored then
		objects["player"][plnumber].lastportal = i
	end
	local cox, coy, side, tendency, x, y = traceline(sourcex, sourcey, direction)
	
	local mirror = false
	if cox and tilequads[map[cox][coy][1]].mirror then
		mirror = true
	end
	
	objects["player"][plnumber].lastportal = i
	
	table.insert(portalprojectiles, portalprojectile:new(sourcex, sourcey, x, y, color, true, {objects["player"][plnumber].portal, i, cox, coy, side, tendency, x, y}, mirror, mirrored))
end

function game_mousepressed(x, y, button)
	if pausemenuopen then
		return
	end
	
	if debugtimescale then
		if button == "wd" then
			speed = math.max(0, speed - .1)
			return
		elseif button == "wu" then
			speed = speed + .1
			return
		end
	end
	
	if editormode then
		editor_mousepressed(x, y, button)
	else
		if editormode then
			editor_mousepressed(x, y, button)
		end
		
		if not noupdate and objects["player"][mouseowner] and objects["player"][mouseowner].controlsenabled and objects["player"][mouseowner].vine == false then
		
			if button == "l" or button == "r" and objects["player"][mouseowner] then
				--knockback
				if portalknockback then
					local xadd = math.sin(objects["player"][mouseowner].pointingangle)*30
					local yadd = math.cos(objects["player"][mouseowner].pointingangle)*30
					objects["player"][mouseowner].speedx = objects["player"][mouseowner].speedx + xadd
					objects["player"][mouseowner].speedy = objects["player"][mouseowner].speedy + yadd
					objects["player"][mouseowner].falling = true
					objects["player"][mouseowner].animationstate = "falling"
					objects["player"][mouseowner]:setquad()
				end
			end
		
			if button == "l" then
				if playertype == "portal" then
					local sourcex = objects["player"][mouseowner].x+6/16
					local sourcey = objects["player"][mouseowner].y+6/16
					local direction = objects["player"][mouseowner].pointingangle
					
					shootportal(mouseowner, 1, sourcex, sourcey, direction)
					if mkstation then
						--objects["player"][1]:use()
					end
				elseif playertype == "minecraft" then
					local v = objects["player"][mouseowner]
					local sourcex, sourcey = v.x+6/16, v.y+6/16
					local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, v.pointingangle)
					
					if cox then
						local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
						if dist <= minecraftrange then
							breakingblockX = cox
							breakingblockY = coy
							breakingblockprogress = 0
						end
					end
				end
				
			elseif button == "r" then
				if playertype == "portal" then
					local sourcex = objects["player"][mouseowner].x+6/16
					local sourcey = objects["player"][mouseowner].y+6/16
					local direction = objects["player"][mouseowner].pointingangle
					
					shootportal(mouseowner, 2, sourcex, sourcey, direction)
					if mkstation then
						--objects["player"][1]:use()
					end
				elseif playertype == "minecraft" then
					local v = objects["player"][mouseowner]
					local sourcex, sourcey = v.x+6/16, v.y+6/16
					local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, v.pointingangle)
					
					if cox then
						local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
						if dist <= minecraftrange then
							placeblock(cox, coy, side)
						end
					end
				end
			end
		end
			
		if button == "wd" then
			if playertype == "minecraft" then
				mccurrentblock = mccurrentblock + 1
				if mccurrentblock >= 10 then
					mccurrentblock = 1
				end
			elseif bullettime then
				speedtarget = speedtarget - 0.1
				if speedtarget < 0.1 then
					speedtarget = 0.1
				end
			else
				--[[for i, v in pairs(characters) do
					if objects.player[1].char.name == v.name then
						local j = 1
						while characterlist[j] ~= i do
							j = j + 1
						end
						j = j + 1
						if j > #characterlist then
							j = 1
						end
						mariocharacter[1] = characterlist[j]
						
						--change colors
						mariocolors[1] = {}
						if characters[characterlist[j] ].defaultcolors[1] then
							local i = j
							for j = 1, #characters[characterlist[i] ].defaultcolors[1] do
								mariocolors[1][j] = {characters[characterlist[i] ].defaultcolors[1][j][1], characters[characterlist[i] ].defaultcolors[1][j][2], characters[characterlist[i] ].defaultcolors[1][j][3]}
							end
						end
						
						objects.player[1] = mario:new(objects.player[1].x, objects["player"][1].y, 1)
						objects.player[1].jumping = true
						objects.player[1].animationstate = "jumping"
						break
					end
				end--]]
				--speed = math.max(0, speed-.1)
			end
		elseif button == "wu" then
			if playertype == "minecraft" then
				mccurrentblock = mccurrentblock - 1
				if mccurrentblock <= 0 then
					mccurrentblock = 9
				end
			elseif bullettime then
				speedtarget = speedtarget + 0.1
				if speedtarget > 1 then
					speedtarget = 1
				end
			else
				--speed = math.min(1, speed+.1)
			end
		end
	end
end

function modifyportalwalls()
	--Create and remove new stuff
	for a, b in pairs(portals) do
		for i = 1, 2 do
			if b["x" .. i] then
				if b["facing" .. i] == "up" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i], b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]+1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i]+1, b["y" .. i]-1, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 1, 0, portals[a], i, "remove")
				elseif b["facing" .. i] == "down" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-2, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-2, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-2, b["y" .. i], 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i], b["y" .. i], 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], -1, 0, portals[a], i, "remove")
				elseif b["facing" .. i] == "left" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i], b["y" .. i]-2, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-2, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-2, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 0, -1, portals[a], i, "remove")
				elseif b["facing" .. i] == "right" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]-1, b["y" .. i]+1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i], b["y" .. i]+1, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 0, 1, portals[a], i, "remove")
				end
			end
		end
	end
	
	--remove conflicting portalwalls (only exist when both portals exists!)
	for a, b in pairs(portals) do
		for j = 1, 2 do
			local otherj = 1
			if j == 1 then
				otherj = 2
			end
			for c, d in pairs(portals) do
				for i = 1, 2 do
					local otheri = 1
					if i == 1 then
						otheri = 2
					end
					--B.J PORTAL WILL REMOVE WALLS OF D.OTHERJ, SO B.OTHERJ MUST EXIST
					
					if b["x" .. j] and b["x" .. otherj] and d["x" .. i] then
						local conside, conx, cony = b["facing" .. j], b["x" .. j], b["y" .. j]
						
						for k = 1, 4 do
							local w = objects["portalwall"][c .. "-" .. i .. "-" .. k]
							if w then
								if conside == "right" then
									if w.x == conx and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								elseif conside == "left" then
									if w.x == conx-1 and w.y == cony-2 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								elseif conside == "up" then
									if w.x == conx-1 and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								else
									if w.x == conx-2 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function modifyportaltiles(x, y, xplus, yplus, portal, i, mode)
	if not x or not y then
		return
	end
	if i == 1 then
		if portal.facing2 ~= false then
			if mode == "add" then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				objects["tile"][x+xplus .. "-" .. y+yplus] = tile:new(x-1+xplus, y-1+yplus)
			else
				objects["tile"][x .. "-" .. y] = nil
				objects["tile"][x+xplus .. "-" .. y+yplus] = nil
			end
		end
	else
		if portal.facing1 ~= false then
			if mode == "add" then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				objects["tile"][x+xplus .. "-" .. y+yplus] = tile:new(x-1+xplus, y-1+yplus)
			else
				objects["tile"][x .. "-" .. y] = nil
				objects["tile"][x+xplus .. "-" .. y+yplus] = nil
			end
		end
	end
end

function getportalposition(i, x, y, side, tendency) --returns the "optimal" position according to the parsed arguments (or false if no possible position was found)
	local xplus, yplus = 0, 0
	if side == "up" then
		yplus = -1
	elseif side == "right" then
		xplus = 1
	elseif side == "down" then
		yplus = 1
	elseif side == "left" then
		xplus = -1
	end
	
	if side == "up" or side == "down" then
		if tendency == -1 then
			if getTile(x-1, y, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x-1, y+yplus, nil, false, side, true) == false and getTile(x, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			elseif getTile(x, y, true, true, side) == true and getTile(x+1, y, true, true, side) == true and getTile(x, y+yplus, nil, false, side, true) == false and getTile(x+1, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			end
		else
			if getTile(x, y, true, true, side) == true and getTile(x+1, y, true, true, side) == true and getTile(x, y+yplus, nil, false, side, true) == false and getTile(x+1, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			elseif getTile(x-1, y, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x-1, y+yplus, nil, false, side, true) == false and getTile(x, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			end
		end
	else
		if tendency == -1 then
			if getTile(x, y-1, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x+xplus, y-1, nil, false, side, true) == false and getTile(x+xplus, y, nil, false, side, true) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			elseif getTile(x, y, true, true, side) == true and getTile(x, y+1, true, true, side) == true and getTile(x+xplus, y, nil, false, side, true) == false and getTile(x+xplus, y+1, nil, false, side, true) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			end
		else
			if getTile(x, y, true, true, side) == true and getTile(x, y+1, true, true, side) == true and getTile(x+xplus, y, nil, false, side, true) == false and getTile(x+xplus, y+1, nil, false, side, true) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			elseif getTile(x, y-1, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x+xplus, y-1, nil, false, side, true) == false and getTile(x+xplus, y, nil, false, side, true) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			end
		end
	end
	
	return false
end

function getTile(x, y, portalable, portalcheck, facing, ignoregrates, dir) --returns masktable value of block (As well as the ID itself as second return parameter) also includes a portalcheck and returns false if a portal is on that spot.
	if portalcheck then
		for i, v in pairs(portals) do
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.facing1 == "up" then
				portal1xplus = 1
			elseif v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			elseif v.facing1 == "left" then
				portal1yplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
			elseif v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			elseif v.facing2 == "left" then
				portal2yplus = -1
			end
			
			if v.x1 ~= false then
				if (x == v.x1 or x == v.x1+portal1xplus) and (y == v.y1 or y == v.y1+portal1yplus) and (facing == nil or v.facing1 == facing) then
					return false
				end
			end
		
			if v.x2 ~= false then
				if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) and (facing == nil or v.facing2 == facing) then
					return false
				end
			end
		end
	end
	
	--check for tubes
	for i, v in pairs(objects["geldispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(objects["cubedispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	--bonusstage thing for keeping it from fucking up by allowing portals to be shot next to the vine in 4-2_2 for example
	if bonusstage then
		if y == mapheight and (x == 4 or x == 6) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	if x <= 0 or y <= 0 or y >= mapheight+1 or x > mapwidth then
		return false, 1
	end
	
	if tilequads[map[x][y][1]].invisible then
		return false
	end
	
	if portalcheck then
		local side
		if facing == "up" then
			side = "top"
		elseif facing == "right" then
			side = "right"
		elseif facing == "down" then
			side = "bottom"
		elseif facing == "left" then
			side = "left"
		end
		
		--To stop people from portalling under the vine, which caused problems, but was fixed elsewhere (and betterer)
		--[[for i, v in pairs(objects["vine"]) do
			if x == v.cox and y == v.coy and side == "top" then
				return false, 1
			end
		end--]]
		
		if map[x][y]["portaloverride"][side] then
			return true, map[x][y][1]
		end
		
		if map[x][y]["gels"][side] == 3 then
			return true, map[x][y][1]
		else
			return tilequads[map[x][y][1]].collision and tilequads[map[x][y][1]].portalable and tilequads[map[x][y][1]].grate == false and tilequads[map[x][y][1]].mirror == false, map[x][y][1]
		end
	else
		if ignoregrates then
			return tilequads[map[x][y][1]].collision and tilequads[map[x][y][1]].grate == false, map[x][y][1]
		else
			return tilequads[map[x][y][1]].collision, map[x][y][1]
		end
	end
end

function getPortal(x, y, dir) --returns the block where you'd come out when you'd go in the argument's block
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.facing1 == "up" then
				portal1xplus = 1
			elseif v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			elseif v.facing1 == "left" then
				portal1yplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
			elseif v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			elseif v.facing2 == "left" then
				portal2yplus = -1
			end
			
			if v.x1 ~= false and (not dir or v.facing1 == dir) then
				if (x == v.x1 or x == v.x1+portal1xplus) and (y == v.y1 or y == v.y1+portal1yplus) and (facing == nil or v.facing1 == facing) then
					if v.facing1 ~= v.facing2 then
						local xplus, yplus = 0, 0
						if v.facing1 == "left" or v.facing1 == "right" then
							if y == v.y1 then
								if v.facing2 == "left" or v.facing2 == "right" then
									yplus = portal2yplus
								else
									xplus = portal2xplus
								end
							end
							
							return v.x2+xplus, v.y2+yplus, v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
						else
							if x == v.x1 then
								if v.facing2 == "left" or v.facing2 == "right" then
									yplus = portal2yplus
								else
									xplus = portal2xplus
								end
							end
							
							return v.x2+xplus, v.y2+yplus, v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
						end	
					else
						return v.x2+(x-v.x1), v.y2+(y-v.y1), v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
					end
				end
			end
		
			if v.x2 ~= false and (not dir or v.facing2 == dir) then
				if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) and (facing == nil or v.facing2 == facing) then
					if v.facing1 ~= v.facing2 then
						local xplus, yplus = 0, 0
						if v.facing2 == "left" or v.facing2 == "right" then
							if y == v.y2 then
								if v.facing1 == "left" or v.facing1 == "right" then
									yplus = portal1yplus
								else
									xplus = portal1xplus
								end
							end
							
							return v.x1+xplus, v.y1+yplus, v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
						else
							if x == v.x2 then
								if v.facing1 == "left" or v.facing1 == "right" then
									yplus = portal1yplus
								else
									xplus = portal1xplus
								end
							end
							
							return v.x1+xplus, v.y1+yplus, v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
						end	
					else
						return v.x1+(x-v.x2), v.y1+(y-v.y2), v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
					end
				end
			end
		end
	end
	
	return false
end

function insideportal(x, y, width, height) --returns whether an object is in, and which, portal.
	if width == nil then
		width = 12/16
	end
	if height == nil then
		height = 12/16
	end
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
			for j = 1, 2 do				
				local portalx, portaly, portalfacing
				if j == 1 then
					portalx = v.x1
					portaly = v.y1
					portalfacing = v.facing1
				else
					portalx = v.x2
					portaly = v.y2
					portalfacing = v.facing2
				end
				
				if portalfacing == "up" then
					xplus = 1
				elseif portalfacing == "down" then
					xplus = -1
				elseif portalfacing == "left" then
					yplus = -1
				end
				
				if portalfacing == "right" then
					if (math.floor(y) == portaly or math.floor(y) == portaly-1) and inrange(x, portalx-width, portalx, false) then
						return portals[i], j
					end
				elseif portalfacing == "left" then
					if (math.floor(y) == portaly-1 or math.floor(y) == portaly-2) and inrange(x, portalx-1-width, portalx-1, false) then
						return portals[i], j
					end
				elseif portalfacing == "up" then
					if inrange(y, portaly-height-1, portaly-1, false) and inrange(x, portalx-1.5-.2, portalx+.5+.2, true) then
						return portals[i], j
					end	
				elseif portalfacing == "down" then
					if inrange(y, portaly-height, portaly, false) and inrange(x, portalx-2, portalx-.5, true) then
						return portals[i], j
					end	
				end
				
				--widen rect by 3 pixels?
				
			end
		end
	end
	
	return false
end

function moveoutportal() --pushes objects out of the portal i in.
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" then
			for j, w in pairs(v) do
				if w.active and w.static == false then
					local p1, p2 = insideportal(w.x, w.y, w.width, w.height)
					
					if p1 ~= false then
						local portalfacing, portalx, portaly
						if p2 == 1 then
							portalfacing = p1.facing1
							portalx = p1.x1
							portaly = p1.y1
						else
							portalfacing = p1.facing2
							portalx = p1.x2
							portaly = p1.y2
						end
						
						if portalfacing == "right" then
							w.x = portalx
						elseif portalfacing == "left" then
							w.x = portalx - 1 - w.width
						elseif portalfacing == "up" then
							w.y = portaly - 1 - w.height
						elseif portalfacing == "down" then
							w.y = portaly
						end
					end
				end
			end
		end
	end
end

function nextlevel()
	if not levelfinished then
		return
	end
	
	love.audio.stop()
	
	if timetrials then
		levelscreen_load("next")
		return
	end
	
	mariolevel = mariolevel + 1
	if mariolevel > 4 then
		mariolevel = 1
		marioworld = marioworld + 1
	end
	levelscreen_load("next")
end

function highscoreentry()
	ttstate = "entry"
	ttname = ""
end

function warpzone(w, l)	
	love.audio.stop()
	mariolevel = l
	marioworld = w
	mariosublevel = 0
	prevsublevel = false
	
	-- minus 1 world glitch just because I can.
	if not arcade and not displaywarpzonetext and w == 4 and l == 1 and mappack == "smb" then
		marioworld = "M"
	end
	
	levelscreen_load("next")
end

function game_mousereleased(x, y, button)
	if button == "l" then
		if playertype == "minecraft" then
			breakingblockX = false
		end
	end
	
	if editormode then
		editor_mousereleased(x, y, button)
	end
end

function getMouseTile(x, y)
	local xout = math.floor((x+xscroll*16*scale)/(16*scale))+1
	local yout = math.floor((y+yscroll*16*scale-yoffset*scale)/(16*scale))+1
	return xout, yout
end

function savemap(filename)
	local s = ""
	
	--mapheight
	local s = s .. mapheight .. ";"
	
	local mul = 1
	local prev = nil
	
	for y = 1, mapheight do
		for x = 1, mapwidth do
			local current = map[x][y][1] .. (coinmap[x][y] and "c" or "")
			
			--check if previous is the same
			if #map[x][y] == 1 then
				if prev == current and (y ~= mapheight or x ~= mapwidth) then
					mul = mul + 1
				elseif prev == current and y == mapheight and x == mapwidth then
					mul = mul + 1
					s = s .. prev .. "*" .. mul
				else
					if prev then
						if mul > 1 then
							s = s .. prev .. "*" .. mul
						else
							s = s .. prev
						end
						
						if y ~= mapheight or x ~= mapwidth then
							s = s .. ","
						end
					end
					prev = current
					mul = 1
					if y == mapheight and x == mapwidth then
						if prev then
							s = s .. ","
						end
						s = s .. prev
					end
				end
			else
				if prev then
					if mul > 1 then
						s = s .. prev .. "*" .. mul
					else
						s = s .. prev
					end
					
					s = s .. ","
				end
				prev = nil
				mul = 1
				
				for i = 1, #map[x][y] do
					if tonumber(map[x][y][i]) and tonumber(map[x][y][i]) < 0 then
						s = s .. "m" .. math.abs(tostring(map[x][y][i]))
					else
						s = s .. tostring(map[x][y][i])
					end
					
					if i == 1 and coinmap[x][y] then
						s = s .. "c"
					end
					
					if i ~= #map[x][y] then
						s = s .. "-"
					end
				end
				
				if y ~= mapheight or x ~= mapwidth then
					s = s .. ","
				end
			end
		end
	end
	
	--options
	s = s .. ";backgroundr=" .. background[1]
	s = s .. ";backgroundg=" .. background[2]
	s = s .. ";backgroundb=" .. background[3]
	s = s .. ";spriteset=" .. spriteset
	if musicname then
		s = s .. ";music=" .. musicname
	end
	if intermission then
		s = s .. ";intermission"
	end
	if bonusstage then
		s = s .. ";bonusstage"
	end
	if haswarpzone then
		s = s .. ";haswarpzone"
	end
	if underwater then
		s = s .. ";underwater"
	end
	if custombackground then
		if custombackground == true then
			s = s .. ";custombackground"
		else
			s = s .. ";custombackground=" .. custombackground
		end
	end
	if customforeground then
		if customforeground == true then
			s = s .. ";customforeground"
		else
			s = s .. ";customforeground=" .. customforeground
		end
	end
	s = s .. ";timelimit=" .. mariotimelimit
	s = s .. ";scrollfactor=" .. scrollfactor
	s = s .. ";fscrollfactor=" .. fscrollfactor
	if not portalsavailable[1] or not portalsavailable[2] then
		local ptype = "none"
		if portalsavailable[1] then
			ptype = "blue"
		elseif portalsavailable[2] then
			ptype = "orange"
		end
		
		s = s .. ";portalgun=" .. ptype
	end
	
	if levelscreenbackname then
		s = s .. ";levelscreenback=" .. levelscreenbackname
	end
	
	--tileset
	
	love.filesystem.mkdir( "mappacks" )
	love.filesystem.mkdir( "mappacks/" .. mappack )
	
	love.filesystem.write("mappacks/" .. mappack .. "/" .. filename .. ".txt", s)
	print("Map saved as " .. "mappacks/" .. filename .. ".txt")
end

function savelevel()
	if mariosublevel == 0 then
		savemap(marioworld .. "-" .. mariolevel)
	else
		savemap(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel)
	end
end

function traceline(sourcex, sourcey, radians, reportal)
	local currentblock = {}
	local x, y = sourcex, sourcey
	currentblock[1] = math.floor(x)
	currentblock[2] = math.floor(y+1)
		
	local emancecollide = false
	for i, v in pairs(emancipationgrills) do
		if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
			emancecollide = true
		end
	end
	
	local doorcollide = false
	for i, v in pairs(objects["door"]) do
		if v.dir == "hor" then
			if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
				doorcollide = true
			end
		else
			if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
				doorcollide = true
			end
		end
	end
	
	if emancecollide or doorcollide then
		return false, false, false, false, x, y
	end
	
	local side
	
	while currentblock[1]+1 > 0 and currentblock[1]+1 <= mapwidth and (flagx == false or currentblock[1]+1 <= flagx or radians > 0) and (axex == false or currentblock[1]+1 <= axex) and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5)) and currentblock[2] < mapheight+1 do --while in map range
		local oldy = y
		local oldx = x
		
		--calculate X and Y diff..
		local ydiff, xdiff
		local side1, side2
		
		if inrange(radians, -math.pi/2, math.pi/2, true) then --up
			ydiff = (y-(currentblock[2]-1)) / math.cos(radians)
			y = currentblock[2]-1
			side1 = "down"
		else
			ydiff = (y-(currentblock[2])) / math.cos(radians)
			y = currentblock[2]
			side1 = "up"
		end
		
		if inrange(radians, 0, math.pi, true) then --left
			xdiff = (x-(currentblock[1])) / math.sin(radians)
			x = currentblock[1]
			side2 = "right"
		else
			xdiff = (x-(currentblock[1]+1)) / math.sin(radians)
			x = currentblock[1]+1
			side2 = "left"
		end
		
		--smaller diff wins
		
		if xdiff < ydiff then
			y = oldy - math.cos(radians)*xdiff
			side = side2
		else
			x = oldx - math.sin(radians)*ydiff
			side = side1
		end
		
		if side == "down" then
			currentblock[2] = currentblock[2]-1
		elseif side == "up" then
			currentblock[2] = currentblock[2]+1
		elseif side == "left" then
			currentblock[1] = currentblock[1]+1
		elseif side == "right" then
			currentblock[1] = currentblock[1]-1
		end
		
		local collide, tileno = getTile(currentblock[1]+1, currentblock[2])
		local emancecollide = false
		for i, v in pairs(emancipationgrills) do
			if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
				emancecollide = true
			end
		end
		
		local doorcollide = false
		for i, v in pairs(objects["door"]) do
			if v.dir == "hor" then
				if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
					doorcollide = true
				end
			else
				if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
					doorcollide = true
				end
			end
		end
		
		-- < 0 rechts
		
		if collide == true and tilequads[map[currentblock[1]+1][currentblock[2]][1]].grate == false then
			break
		elseif emancecollide or doorcollide then
			return false, false, false, false, x, y
		elseif (radians <= 0 and x > xscroll + width) or (radians >= 0 and x < xscroll) then
			return false, false, false, false, x, y
		end
	end
	
	if currentblock[1]+1 > 0 and currentblock[1]+1 <= mapwidth and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5))  and currentblock[2] < mapheight+1 and currentblock[1] ~= nil then
		local tendency
	
		--get tendency
		if side == "down" or side == "up" then
			if math.mod(x, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		elseif side == "left" or side == "right" then
			if math.mod(y, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		end
		
		return currentblock[1]+1, currentblock[2], side, tendency, x, y
	else
		return false, false, false, false, x, y
	end
end

function spawnenemy(x, y)
	if not inmap(x, y) then
		return
	end
	
	--don't spawn when on a coinblock or breakable block
	if tilequads[map[x][y][1] ].breakable or tilequads[map[x][y][1] ].coinblock then
		table.insert(enemiesspawned, {x, y})
		return
	end

	for i = 1, #enemiesspawned do
		if x == enemiesspawned[i][1] and y == enemiesspawned[i][2] then
			return
		end
	end
	
	--spawnrestriction
	allowenemy = true
	for i = 1, #spawnrestrictions do
		if x > spawnrestrictions[i][1]-6 and x < spawnrestrictions[i][1]+6 and y > spawnrestrictions[i][2]-6 and y < spawnrestrictions[i][2]+6 then
			allowenemy = false
		end
	end
	
	local r = map[x][y]
	if #r > 1 then 
		local wasenemy = false
		if allowenemy and tablecontains(enemies, r[2]) and not editormode then
			if not tilequads[map[x][y][1] ].breakable and not tilequads[map[x][y][1] ].coinblock then
				table.insert(objects["enemy"], enemy:new(x, y, r[2], r))
				wasenemy = true
			end
		else
			local t = entitylist[r[2]]
			if allowenemy and t == "cheepcheep" then
				if math.random(2) == 1 then
					table.insert(objects["enemy"], enemy:new(x, y, "cheepcheepwhite", r))
				else
					table.insert(objects["enemy"], enemy:new(x, y, "cheepcheepred", r))
				end
				wasenemy = true
			
			elseif t == "bowser" then
				objects["bowser"][1] = bowser:new(x, y-1/16)
				
			elseif t == "castlefire" then
				table.insert(objects["castlefire"], castlefire:new(x, y, r))
				
			elseif t == "platform" then
				table.insert(objects["platform"], platform:new(x, y, r)) --Platform
				
			elseif t == "platformfall" then
				table.insert(objects["platform"], platform:new(x, y, {0, 0, "fall", r[3], 0, 0})) --Platform fall
				
			elseif t == "platformbonus" then
				table.insert(objects["platform"], platform:new(x, y, {0, 0, "justright", 3}))
			
			elseif t == "bulletbill" then
				table.insert(rocketlaunchers, rocketlauncher:new(x, y))
			
			elseif t == "geldispenser" then
				table.insert(objects["geldispenser"], geldispenser:new(x, y, r))
				
			elseif t == "upfire" then
				table.insert(objects["upfire"], upfire:new(x, y, r))
				
			elseif t == "panel" then
				table.insert(objects["panel"], panel:new(x-1, y-1, r))
				
			elseif t == "textentity" then
				table.insert(textentities, textentity:new(x-1, y-1, r))
			end
		end
		
		table.insert(enemiesspawned, {x, y})
		
		if wasenemy then
			--spawn enemies in 5x1 line so they spawn as a unit and not alone.
			spawnenemy(x-2, y)
			spawnenemy(x-1, y)
			spawnenemy(x+1, y)
			spawnenemy(x+2, y)
		end
	end
end

function item(i, x, y, size)
	if i == "powerup" then
		if size == 1 then
			table.insert(itemanimations, itemanimation:new(x, y, "mushroom"))
		else
			table.insert(itemanimations, itemanimation:new(x, y, "flower"))
		end
	elseif enemiesdata[i] then
		table.insert(itemanimations, itemanimation:new(x, y, i))
	end
end

function givelive(id, t)
	if mariolivecount ~= false then
		for i = 1, players do
			mariolives[i] = mariolives[i]+1
			respawnplayers()
		end
	end
	t.destroy = true
	t.active = false
	table.insert(scrollingscores, scrollingscore:new("1up", t.x, t.y))
	playsound("oneup")
end	

function addpoints(i, x, y)
	if i > 0 then
		marioscore = marioscore + i
		if x ~= nil and y ~= nil then
			table.insert(scrollingscores, scrollingscore:new(i, x, y))
		end
	else
		table.insert(scrollingscores, scrollingscore:new(-i, x, y))
	end
end

function addzeros(s, i)
	for j = string.len(s)+1, i do
		s = "0" .. s
	end
	return s
end

function properprint2(s, x, y)
	for i = 1, string.len(tostring(s)) do
		if fontquads[string.sub(s, i, i)] then
			love.graphics.drawq(fontimage2, font2quads[string.sub(s, i, i)], x+((i-1)*4)*scale, y, 0, scale, scale)
		end
	end
end

function playsound(sound)
	if not soundlist[sound] then
		return
	end

	if soundenabled then
		if delaylist[sound] then
			local currenttime = love.timer.getTime()
			if currenttime-soundlist[sound].lastplayed > delaylist[sound] then
				soundlist[sound].lastplayed = currenttime
			else
				return
			end
		end
		
		soundlist[sound].source:stop()
		soundlist[sound].source:rewind()
		soundlist[sound].source:play()
	end
end

function runkey(i)
	if true then return true end
	local s = controls[i]["run"]
	return checkkey(s)
end

function rightkey(i)
	local s
	if objects["player"][i].gravitydirection > math.pi/4*1 and objects["player"][i].gravitydirection <= math.pi/4*3 then
		s = controls[i]["right"]
	elseif objects["player"][i].gravitydirection > math.pi/4*3 and objects["player"][i].gravitydirection <= math.pi/4*5 then
		s = controls[i]["down"]
	elseif objects["player"][i].gravitydirection > math.pi/4*5 and objects["player"][i].gravitydirection <= math.pi/4*7 then
		s = controls[i]["left"]
	else
		s = controls[i]["up"]
	end
	return checkkey(s)
end

function leftkey(i)
	local s
	if objects["player"][i].gravitydirection > math.pi/4*1 and objects["player"][i].gravitydirection <= math.pi/4*3 then
		s = controls[i]["left"]
	elseif objects["player"][i].gravitydirection > math.pi/4*3 and objects["player"][i].gravitydirection <= math.pi/4*5 then
		s = controls[i]["up"]
	elseif objects["player"][i].gravitydirection > math.pi/4*5 and objects["player"][i].gravitydirection <= math.pi/4*7 then
		s = controls[i]["right"]
	else
		s = controls[i]["down"]
	end
	return checkkey(s)
end

function downkey(i)
	local s
	if objects["player"][i].gravitydirection > math.pi/4*1 and objects["player"][i].gravitydirection <= math.pi/4*3 then
		s = controls[i]["down"]
	elseif objects["player"][i].gravitydirection > math.pi/4*3 and objects["player"][i].gravitydirection <= math.pi/4*5 then
		s = controls[i]["left"]
	elseif objects["player"][i].gravitydirection > math.pi/4*5 and objects["player"][i].gravitydirection <= math.pi/4*7 then
		s = controls[i]["up"]
	else
		s = controls[i]["right"]
	end
	return checkkey(s)
end

function upkey(i)
	local s
	if objects["player"][i].gravitydirection > math.pi/4*1 and objects["player"][i].gravitydirection <= math.pi/4*3 then
		s = controls[i]["up"]
	elseif objects["player"][i].gravitydirection > math.pi/4*3 and objects["player"][i].gravitydirection <= math.pi/4*5 then
		s = controls[i]["right"]
	elseif objects["player"][i].gravitydirection > math.pi/4*5 and objects["player"][i].gravitydirection <= math.pi/4*7 then
		s = controls[i]["down"]
	else
		s = controls[i]["left"]
	end
	return checkkey(s)
end

function checkkey(s)
	if s[1] == "joy" then
		if s[3] == "hat" then
			--arcade hack
			if arcade or true then
				if s[5] == "r" then
					if love.joystick.getAxis(s[2], 1) > joystickdeadzone then
						return true
					end
				elseif s[5] == "l" then
					if love.joystick.getAxis(s[2], 1) < -joystickdeadzone then
						return true
					end
				elseif s[5] == "u" then
					if love.joystick.getAxis(s[2], 2) < -joystickdeadzone then
						return true
					end
				elseif s[5] == "d" then
					if love.joystick.getAxis(s[2], 2) > joystickdeadzone then
						return true
					end
				end
			end
			
			if string.match(love.joystick.getHat(s[2], s[4]), s[5]) then
				return true
			else
				return false
			end
		elseif s[3] == "but" then
			if love.joystick.isDown(s[2], s[4]) then
				return true
			else
				return false
			end
		elseif s[3] == "axe" then
			if s[5] == "pos" then
				if love.joystick.getAxis(s[2], s[4]) > joystickdeadzone then
					return true
				else
					return false
				end
			else
				if love.joystick.getAxis(s[2], s[4]) < -joystickdeadzone then
					return true
				else
					return false
				end
			end
		end
	elseif s[1] then
		if love.keyboard.isDown(s[1]) then
			return true
		else 
			return false
		end
	end
end

function game_joystickpressed( joystick, button )
	if ttstate == "entry" and ttrestarttimer > 0 then
		return
	end

	if pausemenuopen then
		return
	end
	if endpressbutton then
		endgame()
		return
	end
	
	if ttstate == "entry" then
		if button == 4 or button == 1 then
			playsound("coin")
			if #ttname >= 2 then
				ttname = ttname .. string.sub(ttalphabet, ttcurrentletter, ttcurrentletter)
				objects["player"][1]:replayNameEntered()
				ttrestarttimer = 1
			else
				ttname = ttname .. string.sub(ttalphabet, ttcurrentletter, ttcurrentletter)
			end
		elseif button == 2 then
			ttname = string.sub(ttname, 1, -2)
		end
		return
	end
	
	
	if button == 4 or button == 1 or button == 2 then
		if ttstate == "demo" then
			ttstate = "idle"
			
			replayi = 0
			
			xscroll = 0
			objects["player"][1].drawable = true
			objects["enemy"] = {}
			objects["bowser"] = {}
			enemiesspawned = {}
			generatespritebatch()
			autoscroll = true
			
		elseif ttstate == "idle" then
			ttstate = "countdown"
			
			love.audio.stop()
			
		elseif ttstate == "playing" and button == 4 then
			levelfinished = true
			nextlevel()
		end
	end
	
	for i = 1, players do
		if not noupdate and objects["player"][i].controlsenabled and not objects["player"][i].vine then
			local s1 = controls[i]["jump"]
			local s2 = controls[i]["run"]
			local s3 = controls[i]["reload"]
			local s4 = controls[i]["use"]
			local s5 = controls[i]["left"]
			local s6 = controls[i]["right"]
			if s1[1] == "joy" and joystick == tonumber(s1[2]) and s1[3] == "but" and button == tonumber(s1[4]) then
				objects["player"][i]:jump()
				return
			elseif s2[1] == "joy" and joystick == s2[2] and s2[3] == "but" and button == s2[4] then
				objects["player"][i]:fire()
				return
			elseif s3[1] == "joy" and joystick == s3[2] and s3[3] == "but" and button == s3[4] then
				objects["player"][i]:removeportals()
				return
			elseif s4[1] == "joy" and joystick == s4[2] and s4[3] == "but" and button == s4[4] then
				objects["player"][i]:use()
				return
			elseif s5[1] == "joy" and joystick == s5[2] and s5[3] == "but" and button == s5[4] then
				objects["player"][i]:leftkey()
				return
			elseif s6[1] == "joy" and joystick == s6[2] and s6[3] == "but" and button == s6[4] then
				objects["player"][i]:rightkey()
				return
			end
			
			if i ~= mouseowner then
				local s = controls[i]["portal1"]
				if s and s[1] == "joy" then
					if s[3] == "but" then
						if joystick == s[2] and button == s[4] then
							shootportal(i, 1, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
							return
						end
					end
				end
				
				local s = controls[i]["portal2"]
				if s and s[1] == "joy" then
					if s[3] == "but" then
						if joystick == tonumber(s[2]) and button == tonumber(s[4]) then
							shootportal(i, 2, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
							return
						end
					end
				end
			end
		end
	end
end

function game_joystickreleased( joystick, button )
	for i = 1, players do
		local s = controls[i]["jump"]
		if s[1] == "joy" then
			if s[3] == "but" then
				if joystick == tonumber(s[2]) and button == tonumber(s[4]) then
					objects["player"][i]:stopjump()
					return
				end
			end
		end
	end
end

function inrange(i, a, b, include)
	if a > b then
		b, a = a, b
	end
	
	if include then
		if i >= a and i <= b then
			return true
		else
			return false
		end
	else
		if i > a and i < b then
			return true
		else
			return false
		end
	end
end

function adduserect(x, y, width, height, callback)
	local t = {}
	t.x = x
	t.y = y
	t.width = width
	t.height = height
	t.callback = callback
	t.delete = false
	
	table.insert(userects, t)
	return t
end

function userect(x, y, width, height)
	local outtable = {}
	
	local j
	
	for i, v in pairs(userects) do
		if aabb(x, y, width, height, v.x, v.y, v.width, v.height) then
			table.insert(outtable, v.callback)
			if not j then
				j = i
			end
		end
	end
	
	return outtable, j
end

function drawrectangle(x, y, width, height)
	love.graphics.rectangle("fill", x*scale, y*scale, width*scale, scale)
	love.graphics.rectangle("fill", x*scale, y*scale, scale, height*scale)
	love.graphics.rectangle("fill", x*scale, (y+height-1)*scale, width*scale, scale)
	love.graphics.rectangle("fill", (x+width-1)*scale, y*scale, scale, height*scale)
end

function inmap(x, y)
	if not x or not y then
		return false
	end
	if x >= 1 and x <= mapwidth and y >= 1 and y <= mapheight then
		return true
	else
		return false
	end
end

function playmusic()
	if musicname then
		if mariotime <= 99 and mariotime > 0 then
			music:play(musicname, true)
		else
			music:play(musicname)
		end
	end
end

function stopmusic()
	if musicname then
		if mariotime <= 99 and mariotime > 0 then
			music:stop(musicname, true)
		else
			music:stop(musicname)
		end
	end
end

function updatesizes()
	mariosizes = {}
	if not objects then
		for i = 1, players do
			mariosizes[i] = 1
		end
	else
		for i = 1, players do
			mariosizes[i] = objects["player"][i].size
		end
	end
end

function hitrightside()
	if haswarpzone then
		for i, v in pairs(objects["enemy"]) do
			if v.t == "plant" then	
				v.kill = true
			end
		end
		displaywarpzonetext = true
	end
end

function getclosestplayer(x)
	closestplayer = 1
	for i = 2, players do
		if math.abs(objects["player"][closestplayer].x+6/16-x) < math.abs(objects["player"][i].x+6/16-x) then
			closestplayer = i
		end
	end
	
	return closestplayer
end

function endgame()
	if testlevel then
		marioworld = testlevelworld
		mariolevel = testlevellevel
		testlevel = false
		editormode = true
		loadlevel(marioworld .. "-" .. mariolevel)
		startlevel()
	else
		love.audio.stop()
		playertype = "minecraft"
		playertypei = 2
		gamefinished = true
		saveconfig()
		menu_load()
	end
end

function respawnplayers()
	if mariolivecount == false then
		return
	end
	for i = 1, players do
		if mariolives[i] == 1 and objects["player"].dead then
			objects["player"][i]:respawn()
		end
	end
end

function cameraxpan(target, t)
	xpan = true
	xpanstart = xscroll
	xpandiff = target-xpanstart
	xpantime = t
	xpantimer = 0
end

function cameraypan(target, t)
	ypan = true
	ypanstart = yscroll
	ypandiff = target-ypanstart
	ypantime = t
	ypantimer = 0
end

function arcadejoin(joystick, i)
	mouseowner = 5
	mariolives[i] = 3

	--get rightest
	local hx = 0
	local hy = 0
	for i = 1, 4 do
		if objects["player"][i] and not objects["player"][i].dead then
			if objects["player"][i].x > hx then
				hx = objects["player"][i].x
				hy = objects["player"][i].y
			end
		end
	end
	
	objects["player"][i] = mario:new(hx, hy-4/16, i, nil, 1, playertype)
	objects["player"][i]:respawn()
	objects["player"][i].drawable = true
	objects["player"][i].controlsenabled = true
	
	controls[i] = {}
	controls[i]["right"] = {"joy", joystick, "hat", 1, "r"}
	controls[i]["left"] = {"joy", joystick, "hat", 1, "l"}
	controls[i]["down"] = {"joy", joystick, "hat", 1, "d"}
	controls[i]["up"] = {"joy", joystick, "hat", 1, "u"}
	controls[i]["run"] = {"joy", joystick, "but", 3}
	controls[i]["jump"] = {"joy", joystick, "but", 1}
	controls[i]["aimx"] = {"joy", joystick, "axe", 5, "pos"}
	controls[i]["aimy"] = {"joy", joystick, "axe", 4, "pos"}
	controls[i]["portal1"] = {"joy", joystick, "but", 5}
	controls[i]["portal2"] = {"joy", joystick, "but", 6}
	controls[i]["reload"] = {"joy", joystick, "but", 4}
	controls[i]["use"] = {"joy", joystick, "but", 2}
	
	arcadeplaying[i] = true
end

function arcadeleave(i)
	if objects["player"][i].controlsenabled then
		arcadeplaying[i] = false
		
		local v = objects["player"][i]
		v.drawable = false
		v.controlsenabled = false
		v.active = false
		v.animation = nil
		mariolives[i] = 3
	end
end

function updateranges()
	for i, v in pairs(objects["laser"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["lightbridge"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["funnel"]) do
		v:updaterange()
	end
end

function createdialogbox(text, speaker)
	dialogboxes = {}
	table.insert(dialogboxes, dialogbox:new(text, speaker))
end

--Minecraft stuff

function placeblock(x, y, side)
	if side == "up" then
		y = y - 1
	elseif side == "down" then
		y = y + 1
	elseif side == "left" then
		x = x - 1
	elseif side == "right" then
		x = x + 1
	end
	
	if not inmap(x, y) then
		return false
	end
	
	--get block
	local tileno
	if inventory[mccurrentblock].t ~= nil then
		tileno = inventory[mccurrentblock].t
	else
		return false
	end
	
	if #checkrect(x-1, y-1, 1, 1, "all") == 0 then
		map[x][y][1] = tileno
		objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
		generatespritebatch()
	
		inventory[mccurrentblock].count = inventory[mccurrentblock].count - 1
		
		if inventory[mccurrentblock].count == 0 then
			inventory[mccurrentblock].t = nil
		end
		
		return true
	else
		return false
	end
end

function collectblock(i)
	local success = false
	for j = 1, 9 do
		if inventory[j].t == i and inventory[j].count < 64 then
			inventory[j].count = inventory[j].count+1
			success = true
			break
		end
	end
	
	if not success then
		for j = 1, 9 do
			if inventory[j].t == nil then
				inventory[j].count = 1
				inventory[j].t = i
				success = true
				break
			end
		end
	end
	
	return success
end

function breakblock(x, y)
	--create a cute block
	table.insert(miniblocks, miniblock:new(x-.5, y-.2, map[x][y][1]))
	
	map[x][y][1] = 1
	map[x][y]["gels"] = {}
	map[x][y]["portaloverride"] = {}
	objects["tile"][x .. "-" .. y] = nil
	
	generatespritebatch()
end