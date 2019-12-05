require './movements_modules'
require 'colorize'

class Cell
    attr_accessor :icon
    attr_reader :x, :y, :color, :type
    def initialize(x, y,type = nil,icon = ' ', color = nil)
        @x = x
        @y = y
        @type = type
        @color = color
        @icon = icon
        @board = Board.class_variable_get(:@@board)
    end

    def to_s
        @icon
    end

    def move(toward_x, toward_y)
        @x = toward_x
        @y = toward_y
    end

    def move?(toward_x, toward_y)
        moves = available_moves
        moves.include?([toward_x, toward_y]) ? [toward_x, toward_y] : nil

    end
end

class Rook < Cell
    include VerHorMove

    attr_accessor :moved
    def initialize(x,y,type,icon,color)
        super
        @moved = false
    end

    def available_moves
        available_moves = []
        available_moves.push(*vertical)
        available_moves.push(*horizontal)
        available_moves
    end
end

class Knight < Cell
    def available_moves
        available_moves = []
        possible_moves = [[2, 1], [2, -1], [-2, -1], [-2, 1], [1, 2], [1, -2], [-1, -2], [-1, 2]]
        board_limits = (0..7).to_a
        possible_moves.each do |move|
            if board_limits.include?(@x+move[0]) && board_limits.include?(@y+move[1])
                available_moves.push([@x + move[0], @y + move[1]]) if @board[@x + move[0]][@y + move[1]].color != @color 
            end
        end
        available_moves
    end
end

class Bishop < Cell
    include DiagonalMove
    
    def available_moves
        available_moves = []
        available_moves.push(*left_diagonal)
        available_moves.push(*right_diagonal)
        available_moves
    end
end

class Queen < Cell
    include DiagonalMove,VerHorMove

    def available_moves
        available_moves = []
        available_moves.push(*vertical)
        available_moves.push(*horizontal)
        available_moves.push(*left_diagonal)
        available_moves.push(*right_diagonal)
        available_moves
    end
end

class King < Cell

    attr_accessor :moved
    def initialize(x,y,type,icon,color)
        super
        @moved = false
    end
    def available_moves
        available_moves = []
        board_limits = 0..7
        possible_moves = [[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1]]
        possible_moves.each do |move|
            if board_limits.include?(@x + move[0]) && board_limits.include?(@y + move[1])
                available_moves.push([@x + move[0], @y + move[1]]) if @board[@x + move[0]][@y + move[1]].color != @color
            end
        end
        available_moves
    end
end

class Pawn < Cell
    attr_accessor :first_move, :left_enpassant, :right_enpassant, :killable
    def initialize(x, y, type, icon, color)
        super
        @first_move = false
        @left_enpassant = false
        @right_enpassant = false
        @killable = false
    end

    def get_moves_by_color(player_color,step = 1,double_step = 2)
        moves_by_color = []
           if player_color == 'white'
            step = -1
            double_step = -2
        end
        moves_by_color.push([@x + step, @y]) if @board[@x + step][@y].type.nil? && @board[@x + step][@y].color != @color #normal_move
        moves_by_color.push([@x + double_step, @y]) if !first_move && @board[@x + double_step][@y].type.nil?  && @board[@x + step][@y].type.nil? && @board[@x + double_step][@y].color != @color #first_move
        moves_by_color.push([@x + step, @y+1]) if @y != 7 && (!@board[@x + step][@y+1].type.nil?) && @board[@x + step][@y+1].color != @color || @right_enpassant #right_capture
        moves_by_color.push([@x + step, @y-1]) if @y != 0 && (!@board[@x + step][@y-1].type.nil?) && @board[@x + step][@y-1].color != @color || @left_enpassant #left_capture
        moves_by_color
    end

    def available_moves
        available_moves = []
        available_moves.push(*get_moves_by_color(@color))
        available_moves
    end
end