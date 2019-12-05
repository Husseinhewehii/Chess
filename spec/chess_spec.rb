require './board'
require './pieces'
require './game_movements'
require './checkmate'
require './game'
require './castling'

describe Board do
    let(:da_board) {Board.new}

    describe "#initialize" do
        it{is_expected.not_to be_nil}
        it '-upon initialization' do
            expect(da_board.board_test[4][4].class).to eql(Cell)
        end
    end

    describe "#display_board" do
        it '-display board' do
            expect(da_board).to receive(:display_board)
            da_board.display_board()
        end
    end

    describe "#initialize pieces" do
        it "-initialize pieces in white" do
            expect(da_board.board_test[7][7].color).to eql('white')
            expect(da_board.board_test[7][4].class).to eql(King)
        end
        it "-initialize pieces in black" do
            expect(da_board.board_test[0][1].color).to eql('black')
            expect(da_board.board_test[0][4].class).to eql(King)
        end
    end
end

describe GameMovements do
    let(:da_game) {Game.new}
    describe " #get_player_pieces" do
        it " -returns an array with the players' pieces" do
            expect(da_game.get_player_pieces('white')[2].type).to eql("pawn")
        end
    end
    describe " #move_piece" do
        it " -expects pawn to move two steps forward and leave a blank" do
            da_game.move_piece(1,3,3,3)
            expect(da_game.board[1][3].class).to eql(Cell)
            expect(da_game.board[3][3].type).to eql("pawn")
        end
    end
    describe " #move_piece" do
        it " -expects rook's (moved attribute) to be true" do
            da_game.move_piece(0,0,3,3)
            expect(da_game.board[3][3].moved).to eql(true)
        end
    end
    describe " #set_enpassant" do
        it " -sets the left_enpassant of a pawn to true" do
            da_game.move_piece(1,4,4,4)
            da_game.move_piece(6,3,4,3)
            da_game.board[4][3].killable = true
            da_game.set_enpassant(4,4)
            expect(da_game.board[4][4].left_enpassant).to eql(true)
        end
        it " -sets the right_enpassant of a pawn to true" do
            da_game.move_piece(1,4,4,4)
            da_game.move_piece(6,5,4,5)
            da_game.board[4][5].killable = true
            da_game.set_enpassant(4,4)
            expect(da_game.board[4][4].right_enpassant).to eql(true)
        end
    end

    describe " #play_pawn" do
        it ' -sets pawn killable to true if moved two rows' do
            da_game.play_pawn(1,3,[3,3])
            expect(da_game.board[3][3].killable).to eql(true)
        end
        it ' -sets pawn killable to true if moved two rows' do
            da_game.play_pawn(6,6,[4,6])
            expect(da_game.board[4][6].killable).to eql(true)
        end
        it ' -sets right_enpassant and captures accordingly' do
            da_game.play_pawn(1,4,[3,4])
            da_game.play_pawn(6,3,[3,3])
            da_game.set_enpassant(3,3)
            da_game.play_pawn(3,3,[2,4])
            expect(da_game.board[2][4].color).to eql('white')
            expect(da_game.board[2][4].type).to eql('pawn')
        end
        it ' -sets left_enpassant and captures accordingly' do
            da_game.play_pawn(1,4,[4,4])
            da_game.play_pawn(6,3,[4,3])
            da_game.set_enpassant(4,4)
            da_game.play_pawn(4,4,[5,3])
            expect(da_game.board[5][3].color).to eql('black')
            expect(da_game.board[5][3].type).to eql('pawn')
        end
        it ' -turns (white) pawn into queen upon reaching first row' do
            da_game.move_piece(0,0,5,5)
            da_game.move_piece(1,0,5,4)
            da_game.move_piece(6,0,1,0)
            expect(da_game.board[1][0].color).to eql('white')
            expect(da_game.board[1][0].type).to eql('pawn')
            da_game.play_pawn(1,0,[0,0])
            expect(da_game.board[0][0].color).to eql('white')
            expect(da_game.board[0][0].type).to eql('queen')
        end
        it ' -turns (black) pawn into queen upon reaching first row' do
            da_game.move_piece(7,0,5,5)
            da_game.move_piece(6,0,5,4)
            da_game.move_piece(1,0,6,0)
            expect(da_game.board[6][0].color).to eql('black')
            expect(da_game.board[6][0].type).to eql('pawn')
            da_game.play_pawn(6,0,[7,0])
            expect(da_game.board[7][0].color).to eql('black')
            expect(da_game.board[7][0].type).to eql('queen')
        end
    end

    describe " #play_piece" do
        it 'moves a (black) pawn' do
            expect(da_game.board[1][1].killable).to eql(false)
            da_game.play_piece(1,1,3,1)
            expect(da_game.board[3][1].killable).to eql(true)
        end
        it 'moves a (white) pawn' do
            expect(da_game.board[6][4].killable).to eql(false)
            da_game.play_piece(6,4,4,4)
            expect(da_game.board[4][4].killable).to eql(true)
        end
        it 'moves a (black) knight' do
            expect(da_game.board[0][1].type).to eql('knight')
            da_game.play_piece(0,1,2,0)
            expect(da_game.board[2][0].type).to eql('knight')
        end
        it 'moves a (white) pawn' do
            expect(da_game.board[7][6].type).to eql('knight')
            da_game.play_piece(7,6,5,7)
            expect(da_game.board[5][7].type).to eql('knight')
        end
    end

end

describe Castling do
    let(:da_game) {Game.new}
    describe " #all_empty?" do
        it ' -returns true if no pieces between rook and king' do
            da_game.play_piece(0,1,4,4)
            da_game.play_piece(0,2,5,5)
            da_game.play_piece(0,3,4,5)
            expect(da_game.all_empty?(da_game.board[0][0],da_game.board[0][4])).to eql(true)
        end
        it ' -returns true if no pieces between rook and king' do
            da_game.play_piece(0,0,3,0)
            da_game.play_piece(0,4,3,5)
            expect(da_game.all_empty?(da_game.board[3][0],da_game.board[3][5])).to eql(true)
        end
        it ' -returns false if there are pieces between rook and king' do
            expect(da_game.all_empty?(da_game.board[0][0],da_game.board[0][4])).to eql(false)
        end
    end
    describe " #castling_available?" do
        it ' -returns false if castling not available ' do
            expect(da_game.castling_available?(da_game.board[0][4],da_game.board[0][0])).to eql(false)
        end
        it ' -returns true if castling is available ' do
            da_game.play_piece(0,1,3,3)
            da_game.play_piece(0,2,2,3)
            da_game.play_piece(0,3,4,3)
            expect(da_game.castling_available?(da_game.board[0][4],da_game.board[0][0])).to eql(true)
        end
    end
    
end

describe UserInput do
    let(:da_game) {Game.new}
    describe " #convert_input" do
        it 'returns the position on board' do
            expect(da_game.convert_input('h8')).to eql([7,7])
        end
        it 'returns the position on board' do
            expect(da_game.convert_input('g1')).to eql([0,6])
        end
    end
    describe " #ally?" do
        it 'returns false if targeted square has different color' do
            da_game.play_piece(1,1,5,3)
            expect(da_game.ally?(5,3,da_game.board[6][2].color)).to eql(false)
        end
        it 'returns true if targeted square has same color' do
            da_game.play_piece(6,1,5,3)
            expect(da_game.ally?(5,3,da_game.board[6][2].color)).to eql(true)
        end
    end

    describe " #valid_input?" do
        it 'returns false if input is not valid' do
            expect(da_game.valid_input?(['h','9'])).to eql(false)
        end
        it 'returns true if input is  valid' do
            expect(da_game.valid_input?(['h','8'])).to eql(true)
        end
    end

    describe " #castling_input?" do
        it ' -returns false if castling not available input not correct ' do
            expect(da_game.castling_input?('castling-e8-a8')).to eql(false)
        end
        it ' -returns true if castling is available and correct input' do
            da_game.play_piece(7,1,3,3)
            da_game.play_piece(7,2,2,3)
            da_game.play_piece(7,3,4,3)
            expect(da_game.castling_input?('castling-e8-a8')).to eql(true)
        end
    end 

    describe " #can_not_become_check?" do
        it 'returns true if the move causes no check' do
            da_game.play_piece(0,5,3,0)
            expect(da_game.can_not_become_check?('black',[6,2])).to eql(true)
        end
        it 'returns false if the move causes a check' do
            da_game.play_piece(0,5,3,0)
            expect(da_game.can_not_become_check?('black',[6,3])).to eql(false)
        end
   end

   describe " #valid_piece?" do
        it 'returns true if the piece is available to move' do
            da_game.play_piece(0,2,3,0)
            expect(da_game.valid_piece?('white','e7')).to eql(true)
        end
        it 'returns false if the piece is unavailable to move' do
            da_game.play_piece(0,2,3,0)
            expect(da_game.valid_piece?('white','d7')).to eql(false)
        end
        it 'returns true if the piece is available to move' do
            da_game.play_piece(0,2,3,0)
            da_game.play_piece(6,3,5,3)
            da_game.play_piece(6,4,5,4)
            expect(da_game.valid_piece?('white','e8')).to eql(true)
        end
        it 'returns false if the piece is unavailable to move' do
            da_game.play_piece(0,2,3,0)
            da_game.play_piece(6,3,5,3)
            expect(da_game.valid_piece?('white','e8')).to eql(false)
        end
   end

   describe " #get_rook_king_by_input()" do
    it ' -returns rook piece and king piece' do
        expect(da_game.get_rook_king_by_input('castling-e8-a8')[0].type).to eql('king')
        expect(da_game.get_rook_king_by_input('castling-e8-a8')[1].type).to eql('rook')
    end
    it ' -returns rook piece and king piece' do
        expect(da_game.get_rook_king_by_input('castling-e1-h8')[0].type).to eql('king')
        expect(da_game.get_rook_king_by_input('castling-e1-h8')[1].type).to eql('rook')
    end
   end

   describe " #pick_piece?" do
        it 'returns true if the piece is available to move' do
            da_game.play_piece(0,2,3,0)
            expect(da_game.pick_piece?('white','c7')).to eql(true)
        end
        it 'returns false if the piece is unavailable to move' do
            da_game.play_piece(0,2,3,0)
            expect(da_game.pick_piece?('white','d7')).to eql(false)
        end
        it 'returns true if the piece is available to move' do
            da_game.play_piece(6,3,5,3)
            da_game.play_piece(6,4,5,4)
            da_game.play_piece(0,2,3,0)
            expect(da_game.pick_piece?('white','c8')).to eql(true)
        end
        it 'returns false if the piece is unavailable to move' do
            da_game.play_piece(0,2,3,0)
            da_game.play_piece(6,3,5,3)
            expect(da_game.pick_piece?('white','e8')).to eql(false)
        end
   end

   describe " #valid_target?" do
        it 'returns true if the move is valid' do
            da_game.play_piece(0,5,3,0)
            expect(da_game.valid_target?('black',[3,0],['d',7])).to eql(true)
        end
        it 'returns false if the move is invalid' do
            da_game.play_piece(0,5,3,0)
            expect(da_game.valid_target?('black',[3,0],['d',8])).to eql(false)
        end
        it 'returns true if the move is valid' do
            da_game.play_piece(6,3,3,3)
            da_game.play_piece(1,4,3,2)
            da_game.board[3][3].left_enpassant = true
            expect(da_game.valid_target?('white',[3,3],['c',3])).to eql(true)
        end
        it 'returns false if the move is invalid' do
            da_game.play_piece(6,3,3,3)
            da_game.play_piece(1,4,3,2)
            expect(da_game.valid_target?('white',[3,3],['c',3])).to eql(false)
        end
        it 'returns true if the move is valid' do
            da_game.play_piece(6,3,3,3)
            da_game.play_piece(1,4,2,4)
            expect(da_game.valid_target?('white',[3,3],['e',3])).to eql(true)
        end
        it 'returns false if the move is invalid' do
            da_game.play_piece(6,3,3,3)
            da_game.play_piece(0,5,3,0)
            expect(da_game.valid_target?('white',[6,2],['c',5])).to eql(false)
        end
        it 'returns true if the move is valid' do
            da_game.play_piece(6,3,3,3)
            da_game.play_piece(0,5,3,0)
            expect(da_game.valid_target?('white',[6,2],['c',6])).to eql(true)
        end
        it 'returns false if the move is invalid' do
            da_game.play_piece(6,3,3,3)
            da_game.play_piece(0,5,3,0)
            expect(da_game.valid_target?('white',[7,4],['d',7])).to eql(false)
        end
        it 'returns true if the move is valid' do
            da_game.play_piece(6,3,3,3)
            da_game.play_piece(6,4,5,3)
            da_game.play_piece(0,5,3,0)
            expect(da_game.valid_target?('white',[7,4],['e',7])).to eql(true)
        end
    end

end

describe CheckMate do
    let(:da_game) {Game.new}
    describe "#get_king_piece" do
        it "-returns the king's class in white" do
            expect(da_game.get_king_piece('white').type).to eql("king")
        end
        it "-returns the king's class in black" do
            expect(da_game.get_king_piece('black').type).to eql("king")
        end
    end
    describe "#get_opponent_checker_pieces" do
        it '-returns the Knight class in black' do
            knight = Knight.new(5,3,'knight','K','black')
            knight_2 = Knight.new(5,5,'knight','K','black')
            spot = Cell.new(0,1)
            spot_2 = Cell.new(0,6)
            da_game.board[5][3] = knight
            da_game.board[0][1] = spot
            da_game.board[5][5] = knight_2
            da_game.board[0][6] = spot_2
            first = da_game.get_opponent_checker_pieces('white')[0].icon
            second = da_game.get_opponent_checker_pieces('white')[1].icon
            expect([first,second]).to eql(['K','K'])
        end
        it '-returns the Knight class in white' do
            knight = Knight.new(2,3,'knight','K','white')
            spot = Cell.new(7,1)
            da_game.board[2][3] = knight
            da_game.board[7][1] = spot
            expect(da_game.get_opponent_checker_pieces('black')[0].icon).to eql('K')
        end
    end

    describe "#get_moves_against_checker_pieces" do
        it '-returns moves against the checker' do
             knight = Knight.new(2,5,'knight','K','white')
             spot = Cell.new(7,1)
             spot_2 = Cell.new(1,6)
             spot_3 = Cell.new(1,4)
             da_game.board[2][5] = knight
             da_game.board[7][1] = spot
             da_game.board[1][6] = spot_2
             da_game.board[1][4] = spot_3
             #da_game.board_class.display_board
             expect(da_game.get_moves_against_checker_pieces(da_game.board[0][6])).to eql([[2,5]])
        end
     end
 
     describe "#get_verhor_path_to_king" do
        context '--returns positions of path from piece to king' do
         it '-King is on higher Row(Vertical)' do
             white_king = King.new(4,3,'king','K','white')
             black_queen = Queen.new(1,3,'queen','Q','black')
             spot = Cell.new(7,4)
             spot_2 = Cell.new(0,3)
             da_game.board[4][3] = white_king
             da_game.board[7][4] = spot
             da_game.board[0][3] = spot_2
             da_game.board[1][3] = black_queen
             #da_game.board_class.display_board
             expect(da_game.get_verhor_path_to_king(black_queen,white_king)).to eql([[2, 3], [3, 3]])
         end
        end
        context '--returns positions of path from piece to king' do
            it '-King is on lower Row(Vertical)' do
                white_king = King.new(3,5,'king','K','white')
                black_queen = Queen.new(5,5,'queen','Q','black')
                spot = Cell.new(7,4)
                spot_2 = Cell.new(0,3)
                da_game.board[3][5] = white_king
                da_game.board[7][4] = spot
                da_game.board[0][3] = spot_2
                da_game.board[5][5] = black_queen
                #da_game.board_class.display_board
                expect(da_game.get_verhor_path_to_king(black_queen,white_king)).to eql([[4,5]])
            end
           end
        context '--returns positions of path from piece to king' do
         it '-King is on higher Column(Horizontal)' do
             white_king = King.new(4,5,'king','K','white')
             black_queen = Queen.new(4,2,'queen','Q','black')
             spot = Cell.new(7,4)
             spot_2 = Cell.new(0,3)
             da_game.board[4][5] = white_king
             da_game.board[7][4] = spot
             da_game.board[0][3] = spot_2
             da_game.board[4][2] = black_queen
             #da_game.board_class.display_board
             expect(da_game.get_verhor_path_to_king(black_queen,white_king)).to eql([[4, 3], [4, 4]])
         end
        end
        context '--returns positions of path from piece to king' do
         it '-King is on lower Column(Horizontal)' do
             white_king = King.new(5,2,'king','K','white')
             black_queen = Queen.new(5,6,'queen','Q','black')
             spot = Cell.new(7,4)
             spot_2 = Cell.new(0,3)
             da_game.board[5][2] = white_king
             da_game.board[7][4] = spot
             da_game.board[0][3] = spot_2
             da_game.board[5][6] = black_queen
             #da_game.board_class.display_board
             expect(da_game.get_verhor_path_to_king(black_queen,white_king)).to eql([[5, 5], [5, 4],[5,3]])
         end
        end        
     end

     describe "#get_diagnal_path_to_king" do
        context '--returns positions of path from piece to king(Diagonally)' do
         it '-King is on higher right diagonal' do
             white_king = King.new(2,7,'king','K','white')
             black_queen = Queen.new(5,4,'queen','Q','black')
             spot = Cell.new(7,4)
             spot_2 = Cell.new(0,3)
             da_game.board[2][7] = white_king
             da_game.board[7][4] = spot
             da_game.board[0][3] = spot_2
             da_game.board[5][4] = black_queen
             #da_game.board_class.display_board
             expect(da_game.get_diagonal_path_to_king(black_queen,white_king)).to eql([[4, 5], [3, 6]])
         end
        end
        context '--returns positions of path from piece to king' do
            it '-King is on higher left digonal' do
                white_king = King.new(2,2,'king','K','white')
                black_queen = Queen.new(5,5,'queen','Q','black')
                spot = Cell.new(7,4)
                spot_2 = Cell.new(0,3)
                da_game.board[2][2] = white_king
                da_game.board[7][4] = spot
                da_game.board[0][3] = spot_2
                da_game.board[5][5] = black_queen
                #da_game.board_class.display_board
                expect(da_game.get_diagonal_path_to_king(black_queen,white_king)).to eql([[4,4],[3,3]])
            end
           end
        context '--returns positions of path from piece to king' do
         it '-King is on lower right diagonal' do
             white_king = King.new(5,5,'king','K','white')
             black_queen = Queen.new(2,2,'queen','Q','black')
             spot = Cell.new(7,4)
             spot_2 = Cell.new(0,3)
             da_game.board[5][5] = white_king
             da_game.board[7][4] = spot
             da_game.board[0][3] = spot_2
             da_game.board[2][2] = black_queen
             #da_game.board_class.display_board
             expect(da_game.get_diagonal_path_to_king(black_queen,white_king)).to eql([[3, 3], [4, 4]])
         end
        end
        context '--returns positions of path from piece to king' do
         it '-King is on lower left diagonal' do
             white_king = King.new(5,0,'king','K','white')
             black_queen = Queen.new(2,3,'queen','Q','black')
             spot = Cell.new(7,4)
             spot_2 = Cell.new(0,3)
             da_game.board[5][0] = white_king
             da_game.board[7][4] = spot
             da_game.board[0][3] = spot_2
             da_game.board[2][3] = black_queen
             #da_game.board_class.display_board
             expect(da_game.get_diagonal_path_to_king(black_queen,white_king)).to eql([[3, 2], [4, 1]])
         end
        end        
      end

      describe " #get_path_to_king" do
        context '--returns positions of path from piece to king' do
         it '-King is on lower left diagonal' do
             white_king = King.new(5,0,'king','K','white')
             black_queen = Queen.new(2,3,'queen','Q','black')
             spot = Cell.new(7,4)
             spot_2 = Cell.new(0,3)
             da_game.board[5][0] = white_king
             da_game.board[7][4] = spot
             da_game.board[0][3] = spot_2
             da_game.board[2][3] = black_queen
             #da_game.board_class.display_board
             expect(da_game.get_path_to_king(black_queen,white_king)).to eql([[3, 2], [4, 1]])
         end
        end
        context '--returns positions of path from piece to king' do
         it '-King is on lower Column(Horizontal)' do
             white_king = King.new(5,2,'king','K','white')
             black_queen = Queen.new(5,6,'queen','Q','black')
             spot = Cell.new(7,4)
             spot_2 = Cell.new(0,3)
             da_game.board[5][2] = white_king
             da_game.board[7][4] = spot
             da_game.board[0][3] = spot_2
             da_game.board[5][6] = black_queen
             #da_game.board_class.display_board
             expect(da_game.get_path_to_king(black_queen,white_king)).to eql([[5, 5], [5, 4],[5,3]])
         end
        end
      end

      describe " #block_path_to_king" do
        it ' -returns available moves to block a check' do
            white_king = King.new(5,0,'king','K','white')
            black_queen = Queen.new(2,3,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)

            da_game.board[5][0] = white_king
            da_game.board[2][3] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            #da_game.board_class.display_board
            expect(da_game.block_path_to_king(da_game.board[6][1])).to eql([[4,1]])
        end
        it ' -returns available moves to block a check' do
            white_king = King.new(4,4,'king','K','white')
            black_queen = Queen.new(4,0,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)

            da_game.board[4][4] = white_king
            da_game.board[4][0] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            #da_game.board_class.display_board
            expect(da_game.block_path_to_king(da_game.board[6][1])).to eql([[4,1]])
        end
        it ' -returns available moves to block a check' do
            white_king = King.new(4,4,'king','K','white')
            black_queen = Queen.new(4,0,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)

            da_game.board[4][4] = white_king
            da_game.board[4][0] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            #da_game.board_class.display_board
            expect(da_game.block_path_to_king(da_game.board[6][2])).to eql([[4,2]])
        end
      end

      describe " #get_moves_while_checked" do
        it ' -returns all available moves while king is checked' do
            white_king = King.new(5,0,'king','K','white')
            black_queen = Queen.new(5,3,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)
            
            da_game.board[5][0] = white_king
            da_game.board[5][3] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            #da_game.board_class.display_board
            expect(da_game.get_moves_while_checked(da_game.board[6][1])).to eql([[5,1]])    
        end
        it ' -returns all available moves while king is checked' do
            white_king = King.new(5,0,'king','K','white')
            black_queen = Queen.new(5,3,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)
            
            da_game.board[5][0] = white_king
            da_game.board[5][3] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            #da_game.board_class.display_board
            expect(da_game.get_moves_while_checked(da_game.board[6][2])).to eql([[5,2],[5,3]])    
        end
      end

      describe " #check?" do
        it ' -returns true if (white) king is checked' do
            white_king = King.new(5,0,'king','K','white')
            black_queen = Queen.new(2,3,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)
            
            da_game.board[5][0] = white_king
            da_game.board[2][3] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            #da_game.board_class.display_board
            expect(da_game.check?('white')).to eql(true)
        end
        it ' -returns true if (black) king is checked' do
            white_knight = Knight.new(2,3,'knight','N','white')
            da_game.board[2][3] = white_knight
            #da_game.board_class.display_board
            expect(da_game.check?('black')).to eql(true)
        end
        it ' -returns false if (black) king is not checked' do
            white_knight = Knight.new(2,4,'knight','N','white')
            da_game.board[2][4] = white_knight
            #da_game.board_class.display_board
            expect(da_game.check?('black')).to eql(false)
        end
      end

      describe ' #get_checked_king_moves' do
        it 'returns available moves of the checked king' do
            white_knight = Knight.new(2,3,'knight','N','white')
            black_queen = Queen.new(5,5,'queen','Q','black')
            spot_2 = Cell.new(0,3)
            spot_3 = Cell.new(7,1)
            spot = Cell.new(0,5)
            da_game.board[2][3] = white_knight
            da_game.board[5][5] = black_queen
            da_game.board[0][3] = spot_2
            da_game.board[7][1] = spot_3
            da_game.board[0][5] = spot
            #da_game.board_class.display_board
            expect(da_game.get_checked_king_moves(da_game.board[0][4])).to eql([[0,5],[0,3]])
        end
        it 'returns available moves of the checked king' do
            white_knight = Knight.new(2,3,'knight','N','white')
            black_queen = Queen.new(5,5,'queen','Q','black')
            white_knight_2 = Knight.new(2,2,'knight','N','white')
            spot_2 = Cell.new(0,3)
            spot_3 = Cell.new(7,1)
            spot_4 = Cell.new(7,6)
            spot = Cell.new(0,5)
            da_game.board[2][3] = white_knight
            da_game.board[5][5] = black_queen
            da_game.board[2][2] = white_knight_2
            da_game.board[7][6] = spot_4
            da_game.board[0][3] = spot_2
            da_game.board[7][1] = spot_3
            da_game.board[0][5] = spot
            #da_game.board_class.display_board
            expect(da_game.get_checked_king_moves(da_game.board[0][4])).to eql([[0,5]])
        end
      end

      describe ' #can_king_move?' do
        it 'returns true if the checked king can move' do
            white_knight = Knight.new(2,3,'knight','N','white')
            black_queen = Queen.new(5,5,'queen','Q','black')
            spot_2 = Cell.new(0,3)
            spot_3 = Cell.new(7,1)
            da_game.board[2][3] = white_knight
            da_game.board[5][5] = black_queen
            da_game.board[0][3] = spot_2
            da_game.board[7][1] = spot_3
            #da_game.board_class.display_board
            expect(da_game.can_king_move?('black')).to eql(true)
        end
        it 'returns false if the checked king cannot move' do
            white_knight = Knight.new(2,3,'knight','N','white')
            black_queen = Queen.new(5,5,'queen','Q','black')
            white_knight_2 = Knight.new(2,2,'knight','N','white')
            pawn = Pawn.new(4,7,'pawn','P','black')
            spot_2 = Cell.new(0,3)
            spot_3 = Cell.new(7,1)
            spot_4 = Cell.new(7,6)
            spot = Cell.new(1,4)
            da_game.board[2][3] = white_knight
            da_game.board[4][7] = pawn
            da_game.board[5][5] = black_queen
            da_game.board[2][2] = white_knight_2
            da_game.board[7][6] = spot_4
            da_game.board[0][3] = spot_2
            da_game.board[7][1] = spot_3
            da_game.board[1][4] = spot
            #da_game.board_class.display_board
            expect(da_game.can_king_move?('black')).to eql(false)
        end
      end

      describe ' #kill_checker?' do
        it 'returns true if checker can be killed' do
            white_knight = Knight.new(2,3,'knight','N','white')
            black_queen = Queen.new(5,5,'queen','Q','black')
            spot_2 = Cell.new(0,3)
            spot_3 = Cell.new(7,1)
            da_game.board[2][3] = white_knight
            da_game.board[5][5] = black_queen
            da_game.board[0][3] = spot_2
            da_game.board[7][1] = spot_3
            #da_game.board_class.display_board
            expect(da_game.kill_checker?('black')).to eql(true)
        end
        it 'returns false if checker cannot be killed' do
            white_knight = Knight.new(2,3,'knight','N','white')
            white_knight_2 = Knight.new(2,5,'knight','N','white')
            black_queen = Queen.new(5,5,'queen','Q','black')
            spot_2 = Cell.new(0,3)
            spot_3 = Cell.new(7,1)
            spot_4 = Cell.new(7,6)
            da_game.board[2][3] = white_knight
            da_game.board[2][5] = white_knight_2
            da_game.board[5][5] = black_queen
            da_game.board[0][3] = spot_2
            da_game.board[7][1] = spot_3
            da_game.board[7][6] = spot_4
            #da_game.board_class.display_board
            expect(da_game.kill_checker?('black')).to eql(false)
        end
      end

      describe ' #block_check?' do
        it 'returns true if path between checker and king can be blocked' do 
            white_king = King.new(5,0,'king','K','white')
            black_queen = Queen.new(2,3,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)

            da_game.board[5][0] = white_king
            da_game.board[2][3] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            #da_game.board_class.display_board
            expect(da_game.block_check?('white')).to eql(true)
        end
        it 'returns false if path between checker and king cannot be blocked' do 
            white_king = King.new(5,0,'king','K','white')
            black_queen = Queen.new(2,0,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)

            da_game.board[5][0] = white_king
            da_game.board[2][0] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            #da_game.board_class.display_board
            expect(da_game.block_check?('white')).to eql(false)
        end
      end

      describe " #checkmate?" do
        it 'returns false if not checkmate' do
            white_king = King.new(5,0,'king','K','white')
            black_queen = Queen.new(2,0,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)
            block_rook = Rook.new(5,5,'rook','R','black')
            spot_6 = Cell.new(0,0)

            da_game.board[5][0] = white_king
            da_game.board[2][0] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            da_game.board[5][5] = block_rook
            da_game.board[0][0] = spot_6

            #da_game.board_class.display_board
            expect(da_game.checkmate?('white')).to eql(false)
        end
        it 'returns true if checkmate' do
            white_king = King.new(5,0,'king','K','white')
            black_queen = Queen.new(2,0,'queen','Q','black')
            spot = Cell.new(7,4)
            spot_2 = Cell.new(0,3)
            block_rook = Rook.new(2,1,'rook','R','black')
            spot_6 = Cell.new(0,0)

            da_game.board[5][0] = white_king
            da_game.board[2][0] = black_queen
            da_game.board[7][4] = spot
            da_game.board[0][3] = spot_2
            da_game.board[2][1] = block_rook
            da_game.board[0][0] = spot_6

            #da_game.board_class.display_board
            expect(da_game.checkmate?('white')).to eql(true)
        end
      end
end