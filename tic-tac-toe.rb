class Board
	@@winners = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]

	def initialize
		@cells = [1,2,3,4,5,6,7,8,9]
		make_board
	end

	#outputs the board
	def make_board
		puts ""
		puts " #{@cells[0]} | #{@cells[1]} | #{@cells[2]} "
		puts "---+---+---"
		puts " #{@cells[3]} | #{@cells[4]} | #{@cells[5]} "
		puts "---+---+---"
		puts " #{@cells[6]} | #{@cells[7]} | #{@cells[8]} "
		puts ""
	end

	#checks to see if the target move is valid
	def valid_move(input)
		if @cells.include?(input)
			true
		else
			false
		end
	end

	#replaces the number on the board with X or O depending on who the current player is
	def move(input, output)
		@cells = @cells.map do |num|
			if num == input
				output
			else
				num
			end
		end
		make_board
	end

	#checks to see if there is a winner
	def check_for_win(symbol)
		@@winners.each do |array|
			count = 0
			array.each do |num|
				if @cells[num] == symbol
					count += 1
				end
			end
			return true if count == 3
		end
		false
	end

	def cells
		@cells
	end

	def winners
		@@winners
	end

end

class Ai

	def initialize(winners)
		@winners = winners
	end

	#order of operations for the AI on each of its turns
	def turn (cells)
		target = false
		target = check_win(cells) 
		target =  check_lose(cells)	if target == false 
		target =  check_soon_win(cells) if target == false
		target = 1 + rand(9) if target == false
		target
	end

	#checks to see if the AI has two in a row that are not blocked and returns 
	#the target to make it win
	def check_win(cells)
		@winners.each do |array|
			count = 0
			possible_move = false
			array.each do |num|
				if cells[num] == "O"
					count += 1
				elsif cells[num] != "X"
					possible_move = cells[num]
				end
			end
			return possible_move if count == 2 and possible_move
		end
		false
	end

	#checks to see if the player has two in a row that the AI does not already have 
	#blocked and returns the target to block the player
	def check_lose(cells)
		@winners.each do |array|
			count = 0
			possible_move = false
			array.each do |num|
				if cells[num] == "X"
					count += 1
				elsif cells[num] != "O"
					possible_move = cells[num]
				end
			end
			return possible_move if count == 2 and possible_move
		end
		false
	end

	#checks to see if the AI has a row with an O in place without any Xs in the way yet
	def check_soon_win(cells)
		@winners.each do |array|
			o_count = 0
			x_count = 0
			possible_move = false
			array.each do |num|
				if cells[num] == "O"
					o_count += 1
				elsif cells[num] != "X"
					possible_move = cells[num]
				else
					x_count += 1
				end
			end
			return possible_move if o_count >= 1 and x_count == 0 and possible_move 
		end
		false
	end

end


class Game

	def initialize
		run_game
	end

	#the engine for the game.  Calls the methods to run the game. 
	def run_game
		@ai_on = false
		title
		@board = Board.new
		if @ai_on == true
			@ai = Ai.new(@board.winners)
			ending = play_with_ai
		else
			ending = play_with_two_people
		end
		announce_winner(ending)
		end_of_game
	end

	#outputs the title and asked if there are 2 people playing or if 1 vs. AI
	def title
		puts "Welcome to Tic Tac Toe!"
		puts ""
		puts "Press '1' to play against the computer or '2' for 2 people!"
		input = gets.chomp.to_i
		ai_on_or_off(input)
	end

	#turns the AI on or off depending on the users input
	def ai_on_or_off(input)
		if input == 1
			@ai_on = true
		elsif input == 2
			@ai_on = false
		else
			error
			title				
		end
	end

	#turn by turn engine for 1 person vs. AI
	def play_with_ai
		turn = who_goes_first
		finish = false
		counter = 9
		until counter == 0
			if turn == "player"
				break if finish = make_a_move("Player", "X")
				turn = "ai"
			elsif turn == "ai"
				input = false
				puts "Computer's turn"
				until @board.valid_move(input)
					input = @ai.turn(@board.cells)
				end
				@board.move(input, "O")
				break if finish = @board.check_for_win("O")
				turn = "player"
			end
			counter -= 1
		end
		if counter == 0
			return "draw"
		end
		turn
	end

	def who_goes_first
		puts "We need to decide who goes first! Pick 'heads' or 'tails'!"
		input = gets.chomp.downcase
		until input == "heads" || input == "tails"
			error
			puts "We need to decide who goes first! Pick 'heads' or 'tails'!"
			input = gets.chomp.downcase			
		end
		results = rand(2) + 1
		puts ''
		if results == 1 && input == "heads"
			puts "The result was 'heads'! You go first!"
			puts ''
			return "player"
		elsif results == 1 && input == "tails"
			puts "The result was 'heads'! The computer goes first!"
			puts ''
			return "ai"
		elsif results == 2 && input == "heads"
			puts "The result was 'tails'! The computer goes first!"
			puts ''
			return "ai"
		elsif results == 2 && input == "tails"
			puts "The result was 'tails'! You go first!"
			puts ''
			return "player"
		end
	end



	#turn by turn engine for 2 people playing against each other
	def play_with_two_people
		turn = "player 1"
		finish = false
		counter = 9
		until counter == 0
			if turn == "player 1"
				break if finish = make_a_move("Player 1", "X")
				turn = "player 2"
			elsif turn == "player 2"
				break if finish = make_a_move("Player 2", "O")
				turn = "player 1"
			end
			counter -= 1
		end
		if counter == 0
			return "draw"
		end
		turn	
	end

	#move method for human players. Asks for move, checks validity, 
	#makes move, checks for win
	def make_a_move(player, symbol)
		puts "#{player}: Pick a spot by entering the number of that spot"
		input = gets.chomp.to_i
		until @board.valid_move(input)
			error
			puts "#{player}: Pick a spot by entering the number of that spot"
			input = gets.chomp.to_i
		end
		@board.move(input, symbol)		
		@board.check_for_win(symbol)	
	end

	#announces the result of the game
	def announce_winner(winner)
		case winner
		when "player 1"
			puts "Player 1 is the winner!"
		when "player 2"
			puts "Player 2 is the winner!"
		when "ai"
			puts "The computer is the winner!"
		when "player"
			puts "You are the winner!"
		when "draw"
			puts "It's a draw! There aren't any valid moves left!"	
		end
	end

	#Asks if the user(s) would like to play again. 
	def end_of_game
		puts ""
		puts "Would you like to play again? Press 'Y' to start a new game, or 'N' to quit."
		input = gets.chomp.upcase
		if input == 'Y'
			system "clear" or system "cls"
			run_game
		elsif input == 'N'
			:exit
		else
			error
			end_of_game
		end
	end

	def error
		puts "----------------------"
		puts "<ERROR> Invalid input!"
		puts "----------------------"
	end

end		

game = Game.new