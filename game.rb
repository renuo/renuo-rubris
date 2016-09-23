require 'curses'
include Curses
require 'terminfo'

class Tetris

  def run
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
    Curses.curs_set(0)
    Curses.noecho # do not show typed keys
    Curses.init_screen
    Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
    Curses.start_color
# Determines the colors in the 'attron' below
    Curses.init_pair(COLOR_BLUE, COLOR_BLUE, COLOR_BLUE)
    Curses.init_pair(COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW)

    paint
    paint_tetris

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

  def paint_tetris
    x = @current_tetris[0]
    y = @current_tetris[1]

    to_paint =  @current_tetris[3]

    if @current_tetris[2] == 1
      to_paint = to_paint.transpose
    elsif @current_tetris[2] == 2
      to_paint = to_paint.map{|p| p.reverse}
    elsif @current_tetris[2] == 3
      to_paint = to_paint.map{|p| p.reverse}
      to_paint = to_paint.transpose
    elsif @current_tetris[2] == 4
      @current_tetris[2] = 0

    end


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
      y=@current_tetris[1]
      x+=1
    end
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
    paint
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

  def possible? num
    return check_left(num) && check_right_bottom(num)
  end

  def check_right_bottom(num)
    @current_tetris[0]+@current_tetris[3].size-1+num[0] <= TermInfo.screen_size[0]-2 && @current_tetris[1]+@current_tetris[3].size+num[1] <= TermInfo.screen_size[1]-2
  end

  def check_left(num)
    @current_tetris[1]+num[1] >= 1
  end

  def paint
    Curses.clear
    draw_field
    paint_tetris
  end

end


################

Tetris.new.run

