require 'yaml'
MESSAGES = YAML.load_file('rpssl_messages.yml')

# Format prompt message
module PromptFunction
  def prompt(message)
    puts "=> #{message}"
  end

  def prompt_message(message)
    puts "=> #{MESSAGES[message]}"
  end

  def clear_prompt
    sleep(2)
    system('clear')
  end

  def quick_clear_prompt
    sleep(1)
    system('clear')
  end
end

# Invalid input process
module InvalidFunction
  def invalid_input
    prompt(MESSAGES['valid_input'])
    sleep(0.80)
    # system('clear')
  end
end

# Keeps track of moves and what each move beats
class Move
  attr_reader :choice

  ABBREVIATION = {
    'r' => 'rock',
    'p' => 'paper',
    's' => 'scissors',
    'k' => 'spock',
    'l' => 'lizard'
  }.freeze

  WINNING_MOVES = {
    'lizard' => %w[spock paper],
    'spock' => %w[scissors rock],
    'paper' => %w[rock spock],
    'rock' => %w[scissors lizard],
    'scissors' => %w[paper lizard]
  }.freeze

  def initialize(choice)
    @choice = return_move(choice)
  end

  def valid_input?(choice)
    ABBREVIATION.keys.include?(choice)
  end

  def return_move(choice)
    ABBREVIATION.fetch(choice) if valid_input?(choice)
  end

  def to_s
    @choice
  end

  def win?(other)
    WINNING_MOVES[choice].include?(other.choice)
  end
end

# Keeps track of player names
class Player
  include PromptFunction
  include InvalidFunction

  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = Score.new
  end
end

# Keeps track of human's moves
class Human < Player
  def set_name
    n = ''
    loop do
      puts 'Enter a name:'
      n = gets.chomp.capitalize.strip
      break unless n.empty?

      puts invalid_input
    end
    self.name = n
  end

  def choose
    choice = nil
    prompt(MESSAGES['choices'])
    loop do
      # prompt(MESSAGES['choices'])
      choice = gets.chomp
      break if Move.new(choice).valid_input?(choice)

      invalid_input
    end
    self.move = Move.new(choice)
  end
end

# Keeps track of computer's moves
class Computer < Player
  def set_name
    self.name = %w[R2D2 BB-8 Chappie Wall-E].sample
  end

  def choose
    self.move = Move.new(Move::ABBREVIATION.keys.sample)
  end
end

# Keep track of score
class Score
  attr_accessor :points

  def initialize
    @points = 0
  end
end

# Game orchestration engine
class RPSGame
  include PromptFunction
  include InvalidFunction

  WINNING_SCORE = 3

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def play
    loop do
      clear_prompt
      loop do
        players_choose
        display_results
        clear_prompt
        break if human.score.points == WINNING_SCORE || computer.score.points == WINNING_SCORE
      end

      prompt(grand_winner)
      break unless play_again?
      reset_game
    end
    display_goodbye_prompt
  end

  private

  def display_goodbye_prompt
    prompt(MESSAGES['goodbye'])
    sleep(0.75)
    prompt('Closing Game...')
    clear_prompt
  end

  def play_again?
    answer = nil
    loop do
      puts MESSAGES['play_again']
      answer = gets.chomp
      break if %w[y n].include?(answer.downcase)

      invalid_input
    end
    answer == 'y'
  end

  def players_choose
    display_score

    human.choose
    computer.choose
  end

  def display_moves
    prompt("#{human.name} chose #{human.move}, #{computer.name} chose #{computer.move}")
  end

  def determine_winner
    if human.move.win? computer.move
      [human, computer]
    elsif computer.move.win? human.move
      [computer, human]
    else
      ['tie', 'tie']
    end
  end

  def display_results
    quick_clear_prompt
    display_score
    display_moves
    sleep(1)

    winner, loser = determine_winner

    if winner == 'tie'
      prompt("It's a tie!")
    else
      prompt_message("#{winner.move}#{loser.move}")
      sleep(1)
      prompt("#{winner.name} wins!")
    end

    update_score
  end

  def update_score
    if human.move.win? computer.move
      human.score.points += 1
    elsif computer.move.win? human.move
      computer.score.points += 1
    end
  end

  def display_score
    puts "CURRENT SCORE:".center(30)
    puts "#{human.name}: #{human.score.points} | #{computer.name}: #{computer.score.points}\n".center(30)
  end

  def grand_winner
    display_score
    human.score.points == WINNING_SCORE ? "#{human.name} wins the game!" : "#{computer.name} wins the game!"
  end

  def reset_game
    [human, computer].each { |player| player.score.points = 0 }
  end
end

class RPSProgram
  include PromptFunction

  def start
    display_welcome_prompt
    RPSGame.new.play
  end

  private

  def display_welcome_prompt
    prompt(MESSAGES['welcome'])
    sleep(1.5)
    prompt(MESSAGES['instruction'])
    clear_prompt
  end
end

RPSProgram.new.start
