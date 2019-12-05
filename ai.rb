module AI
    def ai_pick_piece(player_color)
        numbers = ('1'..'8').to_a
        letters = ('a'..'h').to_a
        loop do
          l = letters[rand(0..7)]
          n = numbers[rand(0..7)]
          return [l,n] if pick_piece?(player_color,[l,n])
        end
    end

    def ai_pick_target(player_color,input)
        numbers = ('1'..'8').to_a
        letters = ('a'..'h').to_a
        loop do
          l = letters[rand(0..7)]
          n = numbers[rand(0..7)]
          target = [l,n]
          return target if valid_input?(target) && valid_target?(player_color,input,target)
        end
    end
    def ai_play_piece(player_color)
        old_pawns = get_pawns_locations(@board.map(&:clone))
        old_pieces = get_pieces(@board.map(&:clone))
        input = ai_pick_piece(player_color)
        input = convert_input(input)
        set_enpassant(input[0],input[1])
        display_possible_movements(input[0],input[1])
        @board_class.display_board
        # sleep(0.25)
        target = ai_pick_target(player_color,input)
        target = convert_input(target)
        play_piece(input[0],input[1],target[0],target[1])
        close_possible_movements()
        @board_class.display_board
        # sleep(0.25)
        new_pawns = get_pawns_locations(@board.map(&:clone))
        new_pieces = get_pieces(@board.map(&:clone))
        repetition?(old_pieces,old_pawns,new_pieces,new_pawns)
        p @repetition
        game_over?(player_color)
    end
end