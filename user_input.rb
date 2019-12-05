module UserInput

    def ally?(toward_x, toward_y, player_color)
        #returns true if targeted square is ally
        @board[toward_x][toward_y].color == player_color
    end

    def convert_input(input)
        letters = ('a'..'h').to_a
        the_y = letters.index(input[0].downcase).to_s
        [input[1].to_i - 1, the_y.to_i]     
    end

    def get_user_input
        print "Enter: "
        gets.chomp
    end

    def get_rook_king_by_input(input)
        king_location = convert_input(input[9..10])
        king = @board[king_location[0]][king_location[1]]
        rook_location = convert_input(input[12..13])
        rook = @board[rook_location[0]][rook_location[1]]
        return [king,rook]
    end

    def castling_input?(input)
        #returns true if castling input is correct and available
        numbers = ('1'..'8').to_a
        letters = ('a'..'h').to_a
        if input.length == 14 && input[0..7] == 'castling' && letters.include?(input[9]) && letters.include?(input[12]) && numbers.include?(input[10]) && numbers.include?(input[13])
            king,rook = get_rook_king_by_input(input)
            if king.type == 'king' && rook.type == 'rook' && king.color == rook.color
                if castling_available?(king,rook)
                    puts "\n\t#{king.color.capitalize} King & #{rook.color.capitalize} Rook Castled"
                    return true
                end
                puts "\n\tCastling Not Available"
            else
                return false
            end
        end
        false
    end

    def valid_input?(input)
        #returns true of input is valid
        letters = ('a'..'h').to_a
        numbers = ('1'..'8').to_a
        if input.length == 14 && input[0..7] == 'castling' && letters.include?(input[9]) && letters.include?(input[12]) && numbers.include?(input[10]) && numbers.include?(input[13])
            return true
        end
        input.length == 2 && letters.include?(input[0]) && numbers.include?(input[1]) ? true : false
    end

    def valid_target?(player_color, input, target_square)
        #returns true if target is valid
        target = convert_input(target_square)
        if @board[input[0]][input[1]].type == 'king'
            if get_checked_king_moves(@board[input[0]][input[1]]).include?([target[0],target[1]])
                return true                
            else
                return false
            end
        elsif check?(player_color)
            return true if get_moves_while_checked(@board[input[0]][input[1]]).include?([target[0],target[1]])
        elsif @board[input[0]][input[1]].available_moves.include?([target[0], target[1]]) && @board[target[0]][target[1]].type != 'king'
            return true
        elsif @board[input[0]][input[1]].type == 'pawn' && (@board[input[0]][input[1]].right_enpassant || @board[input[0]][input[1]].left_enpassant) && can_not_become_check?(player_color,input)
            if @board[input[0]][input[1]].color == 'black' && @board[target[0]-1][target[1]].type == 'pawn' && @board[target[0]-1][target[1]].killable
                return true               
            elsif @board[input[0]][input[1]].color == 'white' && @board[target[0]+1][target[1]].type == 'pawn' && @board[target[0]+1][target[1]].killable
                return true
            end
        end
        false
    end

    def valid_piece?(player_color,input)
        #returns true if chosen piece is valid
        chosen_piece = convert_input(input)
        if @board[chosen_piece[0]][chosen_piece[1]].type == 'king'
            if get_checked_king_moves(@board[chosen_piece[0]][chosen_piece[1]]).length.positive?
                return true
            else
                return false
            end
        elsif @board[chosen_piece[0]][chosen_piece[1]].color == player_color && can_not_become_check?(player_color,chosen_piece)
            if check?(player_color)
                return true if get_moves_while_checked(@board[chosen_piece[0]][chosen_piece[1]]).length.positive?
            else
                return true
            end
        elsif @board[chosen_piece[0]][chosen_piece[1]].class == Cell
            puts "\tThat's Empty Square !!"
            return false
        end 
        false
    end

    def pick_piece?(player_color,input)
        #returns if valid input and valid piece
        valid_input?(input) && valid_piece?(player_color,input) ? true : false
    end

    def can_not_become_check?(player_color,input)
        #returns true if input leads to check
        piece_moves = []
        piece = @board[input[0]][input[1]]
        piece.available_moves.each do |available_move|
            temp_piece = @board[available_move[0]][available_move[1]]
            @board[available_move[0]][available_move[1]] = piece
            @board[piece.x][piece.y] = Cell.new(piece.x,piece.y)
            unless check?(piece.color)
                @board[available_move[0]][available_move[1]] = temp_piece
                @board[piece.x][piece.y] = piece
                piece_moves.push(available_move)
            end
            @board[available_move[0]][available_move[1]] = temp_piece
            @board[piece.x][piece.y] = piece
        end
        piece_moves.length.positive? ? true : false
    end

    def get_target_piece(player_color,input)
        player_color == 'white' ? color = 'White' : color = 'Black'
        loop do
            board_class.display_board
            puts "\n(#{color} #{@board[input[0]][input[1]].type.capitalize}) Please Select Target Square.."
            target = get_user_input
            if valid_input?(target) && valid_target?(player_color,input,target)
                return convert_input(target)
            end
            puts "\n\tInvalid Target !!" if !valid_target?(player_color,input,target) 
            puts "\n\tInvalid Input: \n\tLimit : 1~8 & a~h (eg:'c4','b6')." if !valid_input?(target) 
        end
    end

    def decide_user_input(player_color)
        old_pawns = get_pawns_locations(@board.map(&:clone))
        old_pieces = get_pieces(@board.map(&:clone))
        player_color == 'white' ? color = 'White' : color = 'Black'
        loop do
            board_class.display_board
            puts "(#{color}) "
            puts "Please Select The Stone You Want To Play(eg:'a7')"
            puts "\tor" 
            puts "Castling (eg: 'castling-e8-a8' e8 is king & a8 is rook)"
            input = get_user_input()
            if castling_input?(input)
                castling(input)
                new_pawns = get_pawns_locations(@board.map(&:clone))
                new_pieces = get_pieces(@board.map(&:clone))
                repetition?(old_pieces,old_pawns,new_pieces,new_pawns)
                break
            elsif pick_piece?(player_color,input)
                normal_move(input,player_color)
                new_pawns = get_pawns_locations(@board.map(&:clone))
                new_pieces = get_pieces(@board.map(&:clone))
                repetition?(old_pieces,old_pawns,new_pieces,new_pawns)
                #p @repetition
                game_over?(player_color)
                if game_over?(player_color)
                    puts 'GAME OVER'
                end
                break
            end
            puts "\n\tInvalid Piece"
            puts "\n\tInvalid Input: \n\tLimit : 1~8 & a~h (eg:'c4','b6')." if !valid_input?(input)
        end
    end

end
