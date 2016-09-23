require 'curses'
include Curses
require 'terminfo'

class Main

  def run
    @position = [1, 1]
    @tetris = [
        [[1, 0],
         [1, 0],
         [1, 0],
         [1, 0]],
        [[1, 1],
         [1, 1],
         [0, 0],
         [0, 0]],
        [[1, 0],
         [1, 1],
         [1, 0],
         [0, 0]],
        [[1, 1],
         [1, 0],
         [1, 0],
         [0, 0]],
        [[1, 1],
         [0, 1],
         [0, 1],
         [0, 0]],
        [[1, 0],
         [1, 1],
         [0, 1],
         [0, 0]],
        [[0, 1],
         [1, 1],
         [1, 0],
         [0, 0]]]
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
          go_up
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
    to_paint = @tetris.sample

    x = 0
    y = 0
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
      y=0
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

  def go_right
    @position[1] += 2 if possible? [0, 2]
    paint
  end


  def go_left
    @position[1] -= 2 if possible? [0, -2]
    paint
  end

  def go_down
    @position[0] += 1 if possible? [1, 0]
    paint
  end

  def go_up
    @position[0] -= 1 if possible? [-1, 0]
    paint
  end

  def possible? num
    return check_left_top(num) && check_right_bottom(num)
  end

  def check_right_bottom(num)
    @position[0]+num[0] <= TermInfo.screen_size[0]-2 && @position[1]+num[1] <= TermInfo.screen_size[1]-2
  end

  def check_left_top(num)
    @position[0]+num[0] >= 1 && @position[1]+num[1] >= 1
  end

  def paint
    Curses.clear
    draw_field
    paint_tetris
    Curses.setpos(@position[0], @position[1])
    Curses.attron(color_pair(COLOR_YELLOW) | A_NORMAL) {
      Curses.addstr('00')
    }
  end

end


################

Main.new.run

