require 'curses'
include Curses
require 'terminfo'

class Tetris
  def init_game
    @tetris = [
        [[1],
         [1],
         [1],
         [1]],
        [[1, 1],
         [1, 1]],
        [[1, 0],
         [1, 1],
         [1, 0]],
        [[1, 1],
         [1, 0],
         [1, 0]],
        [[1, 1],
         [0, 1],
         [0, 1]],
        [[1, 0],
         [1, 1],
         [0, 1]],
        [[0, 1],
         [1, 1],
         [1, 0]]]
    @current_tetris = [0, (TermInfo.screen_size[1]-1)/2, 0, @tetris.sample] #x,y,rotation,tetris
    @blocks = []

    #init Curses
    Curses.stdscr.nodelay = 1
    Curses.curs_set(0)
    Curses.noecho # do not show typed keys
    Curses.init_screen
    Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
    Curses.start_color
    Curses.init_pair(COLOR_YELLOW, COLOR_BLUE, COLOR_YELLOW)
    Curses.init_pair(COLOR_BLUE, COLOR_YELLOW, COLOR_BLUE)

    paint
    paint_tetris
  end

  def run
    init_game

    Thread.new do
      while true do
        go_down
        sleep 1
      end
    end

    i = 1
    while i != 0 do
      case Curses.getch
        when 'W', 'w', Curses::Key::UP
          rotate
        when 'S', 's', Curses::Key::DOWN
          go_down
        when 'A', 'a', Curses::Key::LEFT
          go_left
        when 'D', 'd', Curses::Key::RIGHT
          go_right
        when 'Q', 'q'
          i = 0
      end

    end
  end


  def paint
    Curses.clear
    draw_field
    paint_tetris
  end


  def paint_tetris
    paint_tetris_by_tetris @current_tetris

    @blocks.each { |b| paint_tetris_by_tetris b } unless @blocks.empty?
  end

  def paint_tetris_by_tetris tetris #Wichtig hier, Tetris wird gezeichnet
    x = tetris[0] #Koordinaten
    y = tetris[1] #Koordinaten
    #links oben als array [0],[0]

    to_paint = get_rotated_tetris_to_paint tetris # get_rotated_tetris_to_paint gibt ein Array mit Koordinaten zurück
    #to_paint ist array


    to_paint.each do |t|
      #jeder array t

      t.each do |tt|
        #die Elemente eines Arrays tt

        if tt == 1 #wenn Element, als Tetris-Teil, 1 ist, wird es gezeichnet, mit einem Farbblock
          Curses.setpos(x, y)
          Curses.attron(color_pair(COLOR_YELLOW) | A_NORMAL) {
            Curses.addstr('00')
          }
        end

        y+=2
      end
      y=tetris[1] #die nächste reihe des arrays
      x+=1
    end

  end

  def get_to_paint
    get_rotated_tetris_to_paint @current_tetris
  end

  def get_to_painty(tetris)
    if tetris.nil?
      return 0
    else
      get_rotated_tetris_to_paint @current_tetris
    end

  end

  def get_rotated_tetris_to_paint tetris

    to_paint = tetris[3] # Ein array mit Arrays drin

    if tetris[2] == 1
      to_paint = to_paint.transpose # Transpose: Assumes that self is an array of arrays and transposes the rows and columns: Drehung des Tetris-Blocks
    elsif tetris[2] == 2
      to_paint = to_paint.map { |p| p.reverse }
    elsif tetris[2] == 3
      to_paint = to_paint.map { |p| p.reverse }
      to_paint = to_paint.transpose
    elsif tetris[2] == 4
      tetris[2] = 0
    end
    to_paint
  end

  def draw_field
    0.upto TermInfo.screen_size[0] do |x|
      Curses.setpos(x, 0)
      Curses.attron(color_pair(COLOR_BLUE) | A_NORMAL) {
        Curses.addstr('#')
      }
      Curses.setpos(x, TermInfo.screen_size[1]-1)
      Curses.attron(color_pair(COLOR_BLUE) | A_NORMAL) {
        Curses.addstr('#')
      }
    end
    0.upto TermInfo.screen_size[1] do |y|
      Curses.setpos(0, y)
      Curses.attron(color_pair(COLOR_BLUE) | A_NORMAL) {
        Curses.addstr('#')
      }
      Curses.setpos(TermInfo.screen_size[0]-1, y)
      Curses.attron(color_pair(COLOR_BLUE) | A_NORMAL) {
        Curses.addstr('#')
      }
    end
  end

  def rotate
    @current_tetris[2] += 1
    if possible? [0, 0]
      paint
    else
      @current_tetris[2] += 1
      paint
    end
  end

  def go_right
    @current_tetris[1] += 2 if possible? [0, 2]
    paint
  end

  def go_left
    @current_tetris[1] -= 2 if possible? [0, -2]
    paint
  end

  def go_down
    @current_tetris[0] += 1 if possible? [1, 0]
    paint
  end

  def go_up
    @current_tetris[0] -= 1 if possible? [-1, 0]
    paint
  end

  def store_block
    @blocks << @current_tetris
    @current_tetris = [0, (TermInfo.screen_size[1]-1)/2, 0, @tetris.sample] # Tetris wird abgespeichert, neuer Tetris kommt.
  end

  def rotated?
    @current_tetris[2] == 1 || @current_tetris[2] == 3
  end

  ########CHECK BORDERS##########
  def possible? num

    #check_bottom(num) && not_touch_other_blocks # von mir, um zu testen

    return check_left(num) && check_right_bottom_forLong(num)  && not_touch_other_blocks if @current_tetris[3] == @tetris.first
    return check_left(num) && check_right_bottom(num) && not_touch_other_blocks
  end


  #Diese Bedingung ist zu streng, muss editiert werden
  def not_touch_other_blocks
    return true if @blocks.empty?
    @blocks.each do |b|

      # if b[0] + get_to_painty(b).size ==@current_tetris[0]+get_to_paint.size && b[1]+3 == @current_tetris[1]+get_to_paint.size # X Positon muss 1 beim gezeichneten Tetris sein.

      #if b[0]==@current_tetris[0]+get_to_paint.size && b[1]+3 == @current_tetris[1] #funktioniert nicht
      if b[0]==@current_tetris[0]+get_to_paint.size && b[1]+3 == @current_tetris[1]+get_to_paint.size  #Zusatzbedingung für Y-Achse, HIER
      #if b[0]==@current_tetris[0]+get_to_paint.size && b[1]+3 == current_tetris_padding
        store_block
      end
    end
  end

  def check_right_bottom(num)
    check_bottom(num) && current_tetris_padding+1+num[1] <= TermInfo.screen_size[1]-2
  end

  def check_bottom(num) #Checkt nur terminal boden
    return true if @current_tetris[0]+get_to_paint.size-1+num[0] <= TermInfo.screen_size[0]-2
    store_block
  end

  def current_tetris_padding
    @current_tetris[1]+get_to_paint[0].size
  end

  def check_right_bottom_forLong(num)
    return check_bottom(num) && current_tetris_padding+3+num[1] <= TermInfo.screen_size[1]-2 if rotated?
    check_bottom(num) && current_tetris_padding+num[1] <= TermInfo.screen_size[1]-2
    #true
  end
  
  def check_left(num)
    @current_tetris[1]+num[1] >= 1
  end
  ################


  #Meine Methoden:

  def check_for_lowest_left_x(tetris) #paint-methode macht das auch
    tetris[3][0]
  end

end

Tetris.new.run

