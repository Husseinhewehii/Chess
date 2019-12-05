module Castling

    def castling_available?(king,rook)
        king.y > rook.y ? cast = -2 : cast = +2
        !(king.moved) && !(rook.moved) && !(check?(king.color)) && !(check?(king.color,[king.x,king.y+cast])) && (rook.x == king.x) && all_empty?(king,rook) ? true : false
    end

    def castling(input)
        king,rook = get_rook_king_by_input(input)
        if king.y > rook.y
            move_piece(king.x,king.y,king.x,king.y-2)
            move_piece(rook.x,rook.y,rook.x,king.y+1)
        elsif king.y < rook.y
            move_piece(king.x,king.y,king.x,king.y+2)
            move_piece(rook.x,rook.y,rook.x,king.y-1)
        end
    end

    def all_empty?(king,rook)
        empty = true
        model_y = rook.y
        if rook.y > king.y
            until model_y == king.y+1
                model_y -= 1
                unless @board[rook.x][model_y].type.nil?
                    empty = false
                end
            end
        elsif rook.y < king.y
            until model_y == king.y-1
                model_y += 1
                unless @board[rook.x][model_y].type.nil?
                    empty = false
                end
            end
        end
        empty
    end

end