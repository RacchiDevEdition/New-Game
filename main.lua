-- Load some default values for our rectangle.

function love.load()
    camera = require 'libraries/camera'
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    wf = require 'libraries/windfield/windfield'

    world = wf.newWorld(0,0)

    cam = camera()


    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.collider = world:newBSGRectangleCollider(400, 250, 50, 100, 10)
    player.collider:setFixedRotation(true)
    player.x = 400
    player.y = 200
    player.speed = 300
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.down
    
    background = sti('maps/testMap.lua')
    
    walls = {}
    if background.layers["Walls"] then
        for i, obj in pairs(background.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        
        end
    end
    
end 

function love.update(dt)

    local isMoving = false
    local vx = 0
    local vy = 0

    if love.keyboard.isDown("s") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end
    if love.keyboard.isDown("a") then
        vx = player.speed *  -1
        player.anim = player.animations.left
        isMoving = true
    end
    if love.keyboard.isDown("w") then
        vy = player.speed * -1
       player.anim = player.animations.up
       isMoving = true
    end
    if love.keyboard.isDown("d") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    player.collider:setLinearVelocity(vx,vy)

    if isMoving == false then
      player.anim:gotoFrame(2)
    end
    cam:lookAt(player.x, player.y)

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    if cam.x < width / 2 then
       cam.x = width / 2
    end

    if cam.y < height / 2 or cam.y > height * 2 then
        cam.y = height / 2
    end
    
    local mapW = background.width * background.tilewidth
    local mapH = background.height * background.tileheight

    if cam.x > (mapW - width / 2) then
        cam.x = mapW - (width / 2)
    end

    
    if cam.y > (mapH - height / 2) then
        cam.y = mapH - (height / 2)
    end


    player.anim:update(dt)
    world:update(dt)

    player.x = player.collider:getX()
    player.y = player.collider:getY()
    end

function love.draw()
    cam:attach()
     background:drawLayer(background.layers["Floor"])
     background:drawLayer(background.layers["Tree"])
     player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)
    cam:detach()
end