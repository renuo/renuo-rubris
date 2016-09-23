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
    Curses.stdscr.nodelay = 1
    Curses.curs_set(0)
    Curses.noecho # do not show typed keys
    Curses.init_screen
    Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
    Curses.start_color
    Curses.init_pair(COLOR_BLUE, COLOR_BLUE, COLOR_BLUE)
    Curses.init_pair(COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW)

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

  def paint_tetris_by_tetris tetris
    x = tetris[0]
    y = tetris[1]

    to_paint = get_to_paint_by_tetris tetris


    to_paint.each do |t|

      t.each do |tt|

        if tt == 1
          Curses.setpos(x, y)
          Curses.attron(color_pair(COLOR_YELLOW) | A_NORMAL) {
            Curses.addstr('00')
          }
        end

        y+=2
      end
      y=tetris[1]
      x+=1
    end

  end

  def get_to_paint
    get_to_paint_by_tetris @current_tetris
  end

  def get_to_paint_by_tetris tetris

    to_paint = tetris[3]

    if tetris[2] == 1
      to_paint = to_paint.transpose
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


  ########CHECK BORDERS##########
  def possible? num
    return check_left(num) && check_right_bottom_forLong(num) if @current_tetris[3] == @tetris.first
    return check_left(num) && check_right_bottom(num) && not_touch_other_blocks
  end

  def not_touch_other_blocks
    return true if @blocks.empty?
    @blocks.each do |b|
      if b[0]==@current_tetris[0]+get_to_paint.size
        store_block
      end
    end
  end

  def check_right_bottom(num)
    check_bottom(num) && current_tetris_padding+1+num[1] <= TermInfo.screen_size[1]-2
  end

  def current_tetris_padding
    @current_tetris[1]+get_to_paint[0].size
  end

  def check_bottom(num)
    return true if @current_tetris[0]+get_to_paint.size-1+num[0] <= TermInfo.screen_size[0]-2
    store_block
  end

  def store_block
    @blocks << @current_tetris
    @current_tetris = [0, (TermInfo.screen_size[1]-1)/2, 0, @tetris.sample]
  end

  def check_right_bottom_forLong(num)
    return check_bottom(num) && current_tetris_padding+3+num[1] <= TermInfo.screen_size[1]-2 if rotated?
    check_bottom(num) && current_tetris_padding+num[1] <= TermInfo.screen_size[1]-2
  end

  def rotated?
    @current_tetris[2] == 1 || @current_tetris[2] == 3
  end

  def check_left(num)
    @current_tetris[1]+num[1] >= 1
  end

end


################

Tetris.new.run

