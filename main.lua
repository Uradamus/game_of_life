--[[ Conway's Game of Life clone implemented in LÖVE 0.9.1 ]]--

--[[ CONTROLS:
 * Space bar starts and pauses the simulation, game starts out puased to allow
    for setup.
 * While paused:
    * Left mouse sets the state of the cell under the cursor to true (alive).
    * Right mouse sets the state of the cell under the cursor to False (dead).
    * return/enter key clears the board.
--]]

function love.load()
    -- Settings
    rows = 48
    cols = 48
    size = 12
    delay = 0.3
    
    -- Window config
    love.window.setTitle("Conway's Game of Life")
    love.window.setMode(cols * size, rows * size)
    
    -- 3D array containing 2 2D arrays for the board.
    -- This setup allows for a current and buffer version of the board.
    board = {}
    for tbl = 1, 2, 1 do
        board[tbl] = {}
        for col = 1, cols, 1 do
            board[tbl][col] = {}
            for row = 1, rows, 1 do
                board[tbl][col][row] = false
            end
        end
    end
    
    -- Image used to represent the board on the screen.
    -- The image is 1 pixel per cell, it gets enlarged to size * size pixels
    -- at draw time.
    img_data = love.image.newImageData(cols, rows)
    img_data:mapPixel(function(x, y, r, g, b, a) return 255, 255, 255, 255 end)
    img = love.graphics.newImage(img_data)
    img:setFilter("nearest", "nearest")
    
    -- Runtime variables.
    running = false  -- Flag for toggling between running and paused.
    time = 0  -- Used for the delay simulation updates and puase/start.
    -- These get switched at the start of each frame of the simulation.
    buffer = 1  -- Buffer saves the new state and is used for drawing.
    current = 2  -- Current is used for checking the status of cell neighbors.
end


function love.update(dt)
    time = time + dt
    
    -- This is where the main simulation happens
    if running then
        if time > delay then
            -- Swap buffer and current.
            if current == 2 then
                buffer = 2
                current = 1
            else
                buffer = 1
                current = 2
            end
            
            -- Update the stae of each cell, save results to buffer.
            for col = 1, cols, 1 do
                for row = 1, rows, 1 do
                    board[buffer][col][row] = cell_state(col, row)
                end
            end
            time = 0
        -- Space bar while running pauses the game.
        elseif love.keyboard.isDown(" ") and time > delay/2 then
            running = false
            time = 0
        end
    -- This is the paused state.
    else
        -- Left mouse sets the state of cell under cursor to true (alive).
        if love.mouse.isDown("l") then
            change(true)
        end
        -- Right mouse sets the state of cell under cursor to false (dead).
        if love.mouse.isDown("r") then
            change(false)
        end
        -- Space bar starts the simulation.
        if love.keyboard.isDown(" ") and time > delay then
            running = true
        end
        -- Return/enter clears the board.
        if love.keyboard.isDown("return") then
            clear()
        end
    end
end


function love.draw()
    -- Update the image with the buffer before drawing.
    img_data:mapPixel(fill)
    img:refresh()
    love.graphics.draw(img, 0, 0, 0, size, size)
end


-- Thie Game of Life logic function.
function cell_state(x, y)
    -- Get a count of the living neighbors around the cell.
    local count = 0
    for col = x-1, x+1, 1 do
        for row = y-1, y+1, 1 do
            if col > 0 and col <= cols and row > 0 and row <= rows then
                if board[current][col][row] == true 
                and not (col == x and row == y) then
                    count = count + 1
                end
            end
        end
    end
    
    -- Update the cell based on the rules.
    local alive = board[current][x][y]
    if count < 2 or count > 3 then
        return false
    elseif alive and (count == 2 or count == 3) then
        return true
    elseif not alive and count == 3 then
        return true
    else
        return false
    end
end


-- This fills the image based on the values in the buffer.
function fill (x, y, r, g, b, a)
    -- False = dead = white.
    if board[buffer][x+1][y+1] == false then
        return 255, 255, 255, 255
    -- True = alive = black.
    else
        return 0, 0, 0, 255
    end
end


-- Sets the state of the cell under the cursor to status.
-- Used during the set up phase and while the game is paused.
function change (status)
    local x, y = love.mouse.getPosition()
    x = math.ceil(x / size)
    y = math.ceil(y / size)
    
    if x > 0 and x <= cols and y > 0 and y <= rows then
        board[buffer][x][y] = status
    end
end


-- Clear the board back to all dead.
function clear ()
    for tbl = 1, 2, 1 do
        board[tbl] = {}
        for col = 1, cols, 1 do
            board[tbl][col] = {}
            for row = 1, rows, 1 do
                board[tbl][col][row] = false
            end
        end
    end
end
