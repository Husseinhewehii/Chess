require './board'
require './checkmate'
require './game_movements'
require './user_input'
require './castling'
require './ai'

class String
    def bg_red
      "\e[41m#{self}\e[0m"
    end

    def bg_green
        "\e[42m#{self}\e[0m"
    end
  
    def no_colors
      gsub /\e\[\d+m/, ''
    end
end

class Game
    include AI
    include GameMovements
    include CheckMate
    include UserInput
    include Castling

    attr_reader :board, :board_class, :game_over

    def initialize 
        @board_class = Board.new
        @board_class.display_board()
        @board = Board.class_variable_get(:@@board)
        @game_over = false
        @repetition = 0
    end

    def get_pieces(board)
        board_pieces = []
        board.each_with_index do |row,row_index|
            row.each_with_index do |col,col_index|
            if !(board[row_index][col_index].type.nil?)
                board_pieces.push(board[row_index][col_index])
            end
            end
        end
        board_pieces
    end
    
    def get_pawns_locations(board)
        locations = []
        board.each_with_index do |r, row|
            r.each_with_index do |_c, col|
            locations.push([row,col]) if board[row][col].type == 'pawn'
            end
        end
        locations
    end

    def no_pawn_move?(old_pawns,new_pawns)
        new_pawns.each do |new_location|
            old_pawns.delete(new_location) if old_pawns.include?(new_location)
        end
        old_pawns.length.zero? ? true : false
    end

    def repetition?(old_pieces,old_pawns,new_pieces,new_pawns)
        old_pieces.length == new_pieces.length && no_pawn_move?(old_pawns,new_pawns) ? @repetition += 1 : @repetition = 0
    end

    def game_over?(player_color)
        enemy_color = player_color == 'white' ? 'black' : 'white'
        @game_over = true if checkmate?(enemy_color) || stalemate?(enemy_color) || @repetition == 50
    end
    
end


def play_again?(answer='')
    loop do 
        print "->"
        answer = gets.chomp.downcase
        break if answer == 'y' || answer == 'n'
        puts "\n\t Invalid Input"
        puts "\t Do you want to play again? (y/n)"
    end
    play_game() if  answer == 'y'
end

def get_player_or_ai(answer='',num)
    loop do
        print "->"
        answer = gets.chomp.downcase
        return answer if answer == 'ai' || answer == 'player'
        puts "\n\t Invalid Choice"
        puts "\t Player #{num}(White): AI Or Player?" if num == '1'
        puts "\t Player #{num}(Black): AI Or Player?" if num == '2'
    end
    answer
end

def player_plays(player,player_color,game)
    player == 'player' ? game.decide_user_input(player_color) : game.ai_play_piece(player_color)
    #game.board_class.display_board
end

def play_game()
    game = Game.new
    puts "\nPlayer 1(White): AI Or Player?"
    player1 = get_player_or_ai('1')
    puts "\nPlayer 2(Black): AI Or Player?"
    player2 = get_player_or_ai('2')
  
  
  loop do
    player_plays(player1,'white',game)
    break if game.game_over
    player_plays(player2,'black',game)
    break if game.game_over
  end
  puts 'Game Over!'
  puts 'Do you want to play again? (y/n)'
  play_again?
end

play_game()

# g = Game.new
# g.board_class.display_board
# g.play_piece(0,0,5,7)
# g.board_class.display_board
# g.decide_user_input('white')
# g.board_class.display_board
