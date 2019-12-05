module GameMovements

    def get_player_pieces(player_color)
        #returns all current pieces of player
        pieces = []
        @board.each_with_index do |row,row_idx|
            row.each_with_index do |col,col_idx|           
                pieces.push(@board[row_idx][col_idx]) if @board[row_idx][col_idx].color == player_color
            end
        end
        pieces
    end 

    def move_piece(x, y, toward_x, toward_y)
        #changes coordinates of the class in [x,y] to be [twrd_x,twrd_y] .
        #replaces the class in [twrd_x,twrd_y] with a copy of the modified [x,y] class .
        #then replaces the class in [x,y] with a Cell class .
        @board[x][y].moved = true if @board[x][y].type == 'king' || @board[x][y].type == 'rook'
        @board[x][y].move(toward_x,toward_y)
        modified_x = @board[x][y].x
        modified_y = @board[x][y].y
        @board[modified_x][modified_y] = @board[x][y]
        @board[x][y] = Cell.new(x,y)
    end

    def set_enpassant(x,y)
        #checks if piece is pawn and the one next to it is pawn
        #checks if the other pawn is killable 
        #checks if the other pawn has different color 
        #switches enpassant to true
        if @board[x][y].type == 'pawn'
            if (y-1 >= 0) && @board[x][y-1].type == 'pawn' && (@board[x][y].color != @board[x][y-1].color) && @board[x][y-1].killable
                p 'A Left Enpassant'
                @board[x][y].left_enpassant = true
            end

            if (y+1 <= 7) && @board[x][y+1].type == 'pawn' && @board[x][y].color != @board[x][y+1].color && @board[x][y+1].killable
                p 'A Right Enpassant'
                @board[x][y].right_enpassant = true
            end
        end
    end

    def play_pawn(x, y, target)
        @board[x][y].first_move = true unless @board[x][y].first_move
        @board[x][y].killable = true if (x-target[0]).abs == 2
        if target[0] == 7 || target[0].zero?
            #turns pawn into queen
            @board[x][y].color == 'white' ? icon = '♛' : icon = '♕'
            @board[target[0]][target[1]] = Queen.new(target[0],target[1],'queen',icon,@board[x][y].color)
            @board[x][y] = Cell.new(x,y)
        elsif @board[x][y].type == 'pawn' && (@board[x][y].right_enpassant || @board[x][y].left_enpassant)
            if @board[x][y].color == 'black' && @board[target[0]-1][target[1]].type == 'pawn' && @board[target[0]-1][target[1]].killable 
                move_piece(x,y,target[0],target[1])
                @board[target[0]-1][target[1]] = Cell.new(target[0]-1,target[1])
            elsif @board[x][y].color == 'white' && @board[target[0]+1][target[1]].type == 'pawn' && @board[target[0]+1][target[1]].killable 
                move_piece(x,y,target[0],target[1])
                @board[target[0]+1][target[1]] = Cell.new(target[0]+1,target[1])
            end
        else
            move_piece(x,y,target[0],target[1])
        end
    end

    def play_piece(x, y, toward_x,toward_y)
        if @board[x][y].type == 'pawn'
            @board[x][y].killable = false if @board[x][y].killable
            play_pawn(x,y,[toward_x,toward_y])
        else
            move_piece(x,y,toward_x,toward_y)
        end
    end

    def close_possible_movements()
        @board.each_with_index do |row,row_idx|
            row.each_with_index do |col,col_idx|
                @board[row_idx][col_idx].icon = @board[row_idx][col_idx].icon.no_colors
            end
        end
    end

    def colorize_movements(movements)
        movements.each do |movement|
            if @board[movement[0]][movement[1]].type != nil
                @board[movement[0]][movement[1]].icon = @board[movement[0]][movement[1]].icon.bg_red
            else
                @board[movement[0]][movement[1]].icon = @board[movement[0]][movement[1]].icon.bg_green
            end
        end
    end

    def normal_possible_moves(x,y)
        possible_moves = []
        @board[x][y].available_moves.each do |available_move|
          possible_moves.push(available_move)
        end
        possible_moves
    end

    def display_possible_movements(x,y)
        if @board[x][y].type == 'king'
            colorize_movements(get_checked_king_moves(@board[x][y]))
        elsif check?(@board[x][y].color) 
            colorize_movements(get_moves_while_checked(@board[x][y]))
        else
            colorize_movements(normal_possible_moves(x,y))
        end
    end

    def normal_move(input,player_color)
        input = convert_input(input)
        set_enpassant(input[0],input[1])
        display_possible_movements(input[0],input[1])
        @board_class.display_board
        target = get_target_piece(player_color,input)
        play_piece(input[0],input[1],target[0],target[1])
        close_possible_movements()
        @board_class.display_board
        
    end

end
