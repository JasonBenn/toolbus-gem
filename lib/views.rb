# encoding: UTF-8

module TerminalUtils
  SCREEN_WIDTH = [`tput cols`.to_i, 130].min
  SAVE_CURSOR = `tput sc`
  RESTORE_CURSOR = `tput rc`
  ERASE_DISPLAY = `tput clear`
  RED = `tput setaf 1`
  GREEN = `tput setaf 2`
  RESET = `tput sgr0`
end

print TerminalUtils::SAVE_CURSOR

class ConsoleManager
  include TerminalUtils

  def self.repaint(rows)
    print RESTORE_CURSOR
    num_rows = rows.flat_map(&:to_s).length
    rows.each { |row| puts row.to_s; puts }
  end

  def self.error(message)
    puts RED + message + RESET
    exit
  end
end

class ProgressBarView
  include TerminalUtils
  EXTRA_CHARS_OFFSET = 8 # brackets, % completion
  USABLE_WIDTH = SCREEN_WIDTH - EXTRA_CHARS_OFFSET

  def initialize(percent)
    @percent = Float([percent, 100.0].min)
  end

  def to_s
    complete = '#' * ((@percent / 100.0) * USABLE_WIDTH).to_i
    incomplete = ' ' * (USABLE_WIDTH - complete.length)
    [GREEN, ' [', complete, incomplete, ']', (@percent.to_i.to_s + '%').rjust(5), RESET].join
  end
end

class TableView
  include TerminalUtils

  def initialize(map)
    @map = map
  end

  def to_s
    @map.map do |(key, count)|
      color = count > 0 ? GREEN : RED
      done = count > 0 ? "✓" : " "
      description = key.truncate(SCREEN_WIDTH - 4).ljust(SCREEN_WIDTH - 3)
      [color, done, ' ', description, count.to_s, RESET].join
    end
  end
end

class StatusBoxView
  include TerminalUtils

  def initialize(statuses)
    @statuses = statuses
  end

  def to_s
    puts '-' * SCREEN_WIDTH
    puts
    num_lines = @statuses.length
    lines = @statuses.last(8).fill(num_lines, 8 - num_lines) { '' }
    lines.map { |line| line.truncate(SCREEN_WIDTH).ljust(SCREEN_WIDTH) }.join("\n")
  end
end
