# Ruby Console Tetris

### Clone and Play (Quick Start)

```
git clone git@github.com:renuo/ruby-tetris.git && cd ruby-tetris && bundle install && ruby game.rb
```

#### Clone Game and Setup

```
git clone git@github.com:renuo/ruby-tetris.git
cd ruby-tetris
bin/setup
```

or

```
git clone git@github.com:renuo/ruby-tetris.git
cd ruby-tetris
bundle install
```

#### Start Game

```
bin/run
```

or 

```
ruby game.rb
```

### Game Instructions

`[Q]` Exit Game

`[W]` Rotate (or Arrow Up)

`[S]` Move Down (or Arrow Down)

`[A]` Move Left (or Arrow Left)

`[D]` Move Right (or Arrow Right)

### Used Gems
* colorize
* curses
* ruby-terminfo

### Tetris Blocks
####`@tetris`

#### Line
```
 [1]
 [1]
 [1]
 [1]
```
#### Square
```
 [1, 1]
 [1, 1]
 ```
#### Tee
```
 [1, 0]
 [1, 1]
 [1, 0]
 ```
#### J-shape
```
 [1, 1]
 [1, 0]
 [1, 0]
 ```
#### L-shape
```
 [1, 1]
 [0, 1]
 [0, 1]
 ```
#### S-shape
```
 [1, 0]
 [1, 1]
 [0, 1]
```
#### Z-shape
```
 [0, 1]
 [1, 1]
 [1, 0]
```
 
### Code
 
#### @current_tetris

```
@current_tetris = [      0     ,     0      ,   0    , @tetris.sample]
#current_tetris = [X-coordinate,Y-coordinate,rotation,  tetris       ]
```