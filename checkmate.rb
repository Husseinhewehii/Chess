module CheckMate
    def get_king_piece(player_color)
        #return the King Class
        player_pieces = get_player_pieces(player_color)
        player_pieces.each do |player_piece|
            return player_piece if player_piece.type == 'king'
        end
    end

    def get_moves_against_checker_pieces(piece)
        #returns all possible moves against checkers
        moves_against_checker_pieces = []
        checker_pieces = get_opponent_checker_pieces(piece.color)
        piece.available_moves.each do |available_move|
            checker_pieces.each do |checker_piece| 
                if available_move == [checker_piece.x,checker_piece.y]
                    moves_against_checker_pieces.push(available_move)     
                end
            end
        end
        moves_against_checker_pieces
    end

    def get_opponent_checker_pieces(player_color)
        #returns all opponent's pieces checking player's king
        opponent_checker_pieces = []
        player_king = get_king_piece(player_color)
        opponent_color = player_color == 'white' ? 'black' : 'white'
        opponent_pieces = get_player_pieces(opponent_color)
        opponent_pieces.each do |opponent_piece|
            opponent_piece.available_moves.each do |available_move|
                opponent_checker_pieces.push(opponent_piece) if available_move == [player_king.x, player_king.y]
            end
        end
        opponent_checker_pieces 
    end

    def block_path_to_king(piece)
        #returns available moves to block path of checker to king
        block_moves = []
        player_king = get_king_piece(piece.color)
        opponent_checker_pieces = get_opponent_checker_pieces(piece.color)
        opponent_checker_pieces.each do |opponent_checker_piece|
            opponent_checker_piece_path = get_path_to_king(opponent_checker_piece,player_king)
            opponent_checker_piece_path.each do |opponent_checker_piece_position|
                piece.available_moves.each do |available_move|
                    block_moves.push(opponent_checker_piece_position) if opponent_checker_piece_position == available_move
                end
            end
        end
        block_moves
    end

    def get_moves_while_checked(piece)
        #returns all available moves while checked
        available_moves = []
        available_moves.push(*block_path_to_king(piece))
        available_moves.push(*get_moves_against_checker_pieces(piece))
        available_moves
    end

    def get_verhor_path_to_king(piece,king)
        #returns horizontal and vertical path between checker and king
        positions = []
        if piece.type == 'queen' || piece.type == 'rook'
            if piece.x == king.x
                #horizontal path
                model_y = piece.y
                if piece.y > king.y + 1
                    until model_y == king.y + 1
                        model_y -= 1
                        positions.push([piece.x , model_y])
                    end
                elsif piece.y < king.y - 1
                    until model_y == king.y - 1
                        model_y += 1
                        positions.push([piece.x , model_y])
                    end
                end
            elsif piece.y == king.y
                #vertical path
                model_x = piece.x
                if piece.x > king.x + 1
                    until model_x == king.x + 1
                        model_x -= 1
                        positions.push([model_x , piece.y])
                    end
                elsif piece.x < king.x - 1
                    until model_x == king.x - 1
                        model_x += 1
                        positions.push([model_x, piece.y])
                    end
                end
            end
        end      
        positions
    end

    def get_diagonal_path_to_king(piece,king)
        #returns all diagonals paths between checker and king
        if piece.type == 'queen' || piece.type == 'bishop'
            positions = []
            model_x = piece.x
            model_y = piece.y
            if king.x > model_x && king.y > model_y
                #king on lower right diagonal
                until model_x == 7 || model_y == 7
                    model_x += 1
                    model_y += 1
                    positions.push([model_x,model_y])
                    return positions if model_x == king.x - 1 && model_y == king.y - 1  
                end
            elsif king.x < model_x && king.y < model_y
                #king on higher right diagonal
                until model_x == 0 || model_y == 0
                    model_x -= 1
                    model_y -= 1
                    positions.push([model_x,model_y])
                    return positions if model_x == king.x + 1 && model_y == king.y + 1  
                end
            elsif king.x > model_x && king.y < model_y
                #king on lower left diagonal
                until model_x == 7 || model_y == 0
                    model_x += 1
                    model_y -= 1
                    positions.push([model_x,model_y])
                    return positions if model_x == king.x - 1 && model_y == king.y + 1  
                end
            elsif king.x < model_x && king.y > model_y
                #king on higher left diagonal
                until model_x == 0 || model_y == 7
                    model_x -= 1
                    model_y += 1
                    positions.push([model_x,model_y])
                    return positions if model_x == king.x + 1 && model_y == king.y - 1  
                end
            end
        end
    end

    def get_path_to_king(piece,king)
        #returns all paths between checker and king
        path_to_king = []
        path_to_king.push(*get_verhor_path_to_king(piece,king))
        path_to_king.push(*get_diagonal_path_to_king(piece,king))
        path_to_king
    end

    def get_king_position(player_color)
        #returns an array of 2 items (x&y) of king
        player_king = get_king_piece(player_color)
        [player_king.x, player_king.y]
    end

    
    def check?(player_color, king_position = get_king_position(player_color))
        #returns true of king is checked
        opponent_color = player_color == 'white' ? 'black' : 'white'
        opponent_pieces = get_player_pieces(opponent_color)
        opponent_pieces.each do |opponent_piece|
            opponent_piece.available_moves.each do |available_move|
            return true if available_move == king_position
          end
        end
        false
    end

    def get_checked_king_moves(king)
        #returns all possbile moves for the king while he is checked
        checked_king_moves = []
        king.available_moves.each do |available_move|
            model = @board[available_move[0]][available_move[1]]
            @board[available_move[0]][available_move[1]] = king
            @board[king.x][king.y] = Cell.new(king.x,king.y)
            unless check?(king.color,available_move)
                @board[available_move[0]][available_move[1]] = model
                @board[king.x][king.y] = king
                checked_king_moves.push(available_move)
            end
            @board[available_move[0]][available_move[1]] = model
            @board[king.x][king.y] = king
        end
        checked_king_moves
    end

    def can_king_move?(player_color)
        #returns true if king has any possible moves
        king = get_king_piece(player_color)
        king.available_moves.each do |available_move|
            model = @board[available_move[0]][available_move[1]]
            @board[available_move[0]][available_move[1]] = king
            @board[king.x][king.y] = Cell.new(king.x,king.y)
            unless check?(king.color,available_move)
                @board[available_move[0]][available_move[1]] = model
                @board[king.x][king.y] = king
                return true
            end
            @board[available_move[0]][available_move[1]] = model
            @board[king.x][king.y] = king
        end
        false
    end

    def kill_checker?(player_color)
        #returns true if there is just one checked whom can be captured
        player_pieces = get_player_pieces(player_color)
        opponent_checker_pieces = get_opponent_checker_pieces(player_color)
        return false if opponent_checker_pieces.length > 1

        player_pieces.each do |player_piece|

            next if player_piece.type == 'king'

            player_piece.available_moves.each do |available_move|
                opponent_checker_pieces.each do |opponent_checker_piece|
                    if available_move == [opponent_checker_piece.x,opponent_checker_piece.y]
                        opponent_checker_pieces.delete(opponent_checker_piece) 
                        break
                    end
                end
            end
        end
        opponent_checker_pieces.length.zero? ? true : false
    end

    def block_check?(player_color)
        #returns true if path between checker and king can be blocked
        player_pieces = get_player_pieces(player_color)
        player_king = get_king_piece(player_color)
        opponent_checker_pieces = get_opponent_checker_pieces(player_color)
        return false if opponent_checker_pieces.length > 1
        opponent_checker_pieces.each do |opponent_checker_piece|
            opponent_checker_piece_path_to_king = get_path_to_king(opponent_checker_piece,player_king)
            opponent_checker_piece_path_to_king.each do |position_in_path|
                player_pieces.each do |player_piece|
                    next if player_piece.type == 'king'
                    player_piece.available_moves.each do |available_move|
                        if available_move == position_in_path
                           opponent_checker_pieces.delete(opponent_checker_piece) 
                            break
                        end
                    end
                end
            end
        end
        opponent_checker_pieces.length.zero? ? true : false
    end

    def checkmate?(player_color)
        if check?(player_color)
            return false if can_king_move?(player_color) || kill_checker?(player_color) || block_check?(player_color)
            true
        end
    end


    def stalemate?(player_color)
        unless check?(player_color)
          stalemate = true
          player_pieces = get_player_pieces(player_color)
          player_pieces.each do |piece|
            if piece.type == 'king'
              get_checked_king_moves(piece).each do |pos_xy|
                stalemate = false unless pos_xy.length.zero?
              end
            else
              piece.available_moves.each do |pos_xy|
                stalemate = false unless pos_xy.length.zero?
              end
            end
          end
          return stalemate
        end
        false
    end
    
end