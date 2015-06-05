module TerminalUtils
  SCREEN_WIDTH = [`tput cols`.to_i, 100].min
  SAVE_CURSOR = `tput sc`
  RESTORE_CURSOR = `tput rc`
  ERASE_DISPLAY = `tput clear`
  RED = `tput setaf 1`
  GREEN = `tput setaf 2`
  RESET = `tput sgr0`
end


class ProgressBar
  include TerminalUtils

  def initialize(num_tasks)
    @num_tasks = num_tasks
    @usable_width = SCREEN_WIDTH - 8 # accounts for bracket and percentage complete characters
    @percent = 0.0
    SAVE_CURSOR
  end

  def done?
    @percent >= 100
  end

  def increment
    @percent += (100.0 / @num_tasks)
  end

  def to_s
    bar_width = ((@percent / 100.0) * @usable_width).to_i
    complete = '#' * bar_width
    incomplete = ' ' * (@usable_width - bar_width)

    RESTORE_CURSOR
    GREEN

    [' [', complete, incomplete, ']', (@percent.to_i.to_s + '%').rjust(5)].join
  end
end

class View
  extend TerminalUtils

  module Errors
    include TerminalUtils

    def self.unpushed_commits
      puts "#{RED}Unpushed commits! Toolbus relies on Github to show code samples, so your code should be online. Please push before running.#{RESET}"
    end

    def self.uncommitted_changes
      puts "#{RED}Uncommitted changes! Toolbus tracks completions by commit SHA1, so please commit and push before running.#{RESET}"
    end
  end

  def self.print_page

  end
end
