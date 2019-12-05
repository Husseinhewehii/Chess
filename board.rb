require './pieces'


class Board

    attr_reader :board, :board_test
    def initialize
        @@board = Array.new(8) {Array.new(8)}
        initialize_pieces('white')
        initialize_pieces('black')
        
        @@board.each_with_index do |row,r_idx|
            row.each_with_index do |col,c_idx|
                @@board[r_idx][c_idx] = Cell.new(r_idx,c_idx) if @@board[r_idx][c_idx].nil?
            end
        end
        @board_test = @@board
    end

    def initialize_pieces(color,rook_icon = '♖', knight_icon = '♘', pawn_icon = '♙', king_icon = '♔', queen_icon = '♕', bishop_icon = '♗', piece_row = 0, pawn_row = 1)
        if color == 'white'
            pawn_row = 6
            piece_row = 7
            rook_icon = '♜'
            knight_icon = '♞'
            pawn_icon = '♟'
            king_icon = '♚'
            queen_icon = '♛'
            bishop_icon = '♝'
        end
        #@@board[2][2] = Rook.new(2,2,'rook','♜','white')
        @@board[piece_row][7] = Rook.new(piece_row,7,'rook',rook_icon,color)
        @@board[piece_row][0] = Rook.new(piece_row,0,'rook',rook_icon,color)
        @@board[piece_row][6] = Knight.new(piece_row,6,'knight',knight_icon,color)
        @@board[piece_row][1] = Knight.new(piece_row,1,'knight',knight_icon,color)
        @@board[piece_row][5] = Bishop.new(piece_row,5,'bishop',bishop_icon,color)
        @@board[piece_row][2] = Bishop.new(piece_row,2,'bishop',bishop_icon,color)
        @@board[piece_row][4] = King.new(piece_row,4,'king',king_icon,color)
        @@board[piece_row][3] = Queen.new(piece_row,3,'queen',queen_icon,color)
        @@board[pawn_row].each_with_index do |pawn_item,pawn_idx|
            @@board[pawn_row][pawn_idx] = Pawn.new(pawn_row,pawn_idx,'pawn',pawn_icon,color)
        end
    end

    def display_board
        puts "\t  ┏━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┓"
        @@board.each_with_index do |row,index|
            puts "\t#{index + 1} ┃ " + row.join(' ┃ ') + " ┃"
            puts "\t  ┣━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━┫" if index != @@board.length - 1
        end
        puts "\t  ┗━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┛"
        puts "\t    A   B   C   D   E   F   G   H"
    end
    
    
end

#g = Board.new
#p g.get_player_pieces('black')


