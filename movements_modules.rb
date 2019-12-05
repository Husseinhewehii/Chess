module DiagonalMove
    def right_diagonal
        possible_moves = []
        make_x = @x
        make_y = @y
        until make_x == 7 || make_y == 7
            make_x += 1
            make_y += 1
            possible_moves.push([make_x,make_y]) if @board[make_x][make_y].color != @color
            if !@board[make_x][make_y].type.nil?
                break
            end
        end
        make_x = @x
        make_y = @y
        until make_x.zero? || make_y.zero?
            make_x -= 1
            make_y -= 1
            possible_moves.push([make_x,make_y]) if @board[make_x][make_y].color != @color
            break if !@board[make_x][make_y].type.nil?
        end
        possible_moves
    end

    def left_diagonal
        possible_moves = []
        make_x = @x
        make_y = @y
        until make_x == 7 || make_y.zero?
            make_x += 1
            make_y -= 1
            possible_moves.push([make_x,make_y]) if @board[make_x][make_y].color != @color
            if !@board[make_x][make_y].type.nil?
                break
            end
        end
        make_x = @x
        make_y = @y
        until make_x.zero? || make_y == 7
            make_x -= 1
            make_y += 1
            possible_moves.push([make_x,make_y]) if @board[make_x][make_y].color != @color
            break if !@board[make_x][make_y].type.nil?
        end
        possible_moves
    end
end

module VerHorMove
    def vertical 
        possible_moves = []
        make_x = @x
        until make_x.zero?
            make_x -= 1
            possible_moves.push([make_x,@y]) if @board[make_x][@y].color != @color
            break if !@board[make_x][@y].type.nil?
        end
        make_x = @x
        until make_x == 7
            make_x += 1
            possible_moves.push([make_x,@y]) if @board[make_x][@y].color != @color
            break if !@board[make_x][@y].type.nil?
        end
        possible_moves
    end 

    def horizontal
        possible_moves = []
        make_y = @y
        until make_y.zero?
            make_y -= 1
            possible_moves.push([@x,make_y]) if @board[@x][make_y].color != @color
            break if !@board[@x][make_y].type.nil?
        end
        make_y = @y
        until make_y == 7
            make_y += 1
            possible_moves.push([@x,make_y]) if @board[@x][make_y].color != @color
            break if !@board[@x][make_y].type.nil?
        end
        possible_moves
    end

end