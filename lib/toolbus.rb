require 'pry'
require 'json/pure'

SCREEN_WIDTH = [`tput cols`.to_i, 100].min
def save_cursor; `tput sc`; end
def restore_cursor; `tput rc`; end
def erase_display; `tput clear`; end
def red; `tput setaf 1`; end
def green; `tput setaf 2`; end
def reset; `tput sgr0`; end

require_relative './view.rb'

def print_line(message, color)
  puts [color, message, reset].join
end


api_response = JSON.parse(File.read(File.open('./spec/fixture/sample.json')))
times_encountered = api_response['data'].map { |feature| ["[#{feature['module']}]: #{feature['name']}", 0] }.to_h

progress = ProgressBar.new(times_encountered.length)
until true || progress.done? do
  puts progress
  # debug_counter = 0
  times_encountered.each do |(key, value)|
    # debug_counter += 1
    # puts debug_counter
    progress.increment
    times_encountered[key] += 1 if rand(100) < 40
    color = value > 0 ? green : red
    done = value > 0 ? "✓" : " "
    count = value.to_s
    message = done + ' ' + key.ljust(SCREEN_WIDTH - 3) + count
    print_line message, color
  end

  num_requirements = times_encountered.inject(0) { |accum, (k, v)| accum + v }
  num_features = times_encountered.select { |k, v| v > 0 }.length
  puts "Found #{num_requirements} requirements in #{num_features} features!"
  sleep 0.4
end

def git_status_clean?
  `git status -s`.length == 0
end

def println(color, message)
  print color
  puts message
  print RESET
end

class Toolbus
  def self.scan

    # VALIDATION PHASE
    # ERROR unless git status clean
    # unless git_status_clean?
    #   println RED, "Uncommitted changes! Toolbus tracks completions by commit SHA1, so please commit and push before running."
    #   exit
    # end
    # ERROR unless latest SHA1 is on github

    # GET all features for our tools and version

    # UPDATE GRAMMAR LIBRARY
    # check all grammar_urls for files we don't have

    # GET those files

    # DATA PREPARATION
    # TRANSLATE globs to mapping of full_path => array of grammars

    # SCANNING AND PUSHING PHASE
    # EACH file with tasks
      # EACH feature
        # IF feature found?
          # add feature completion to POST request
          # update progress values!
        # increment progress bar
        # refresh view
      # POST new feature completions.
        # 

  end
end

Toolbus.scan
binding.pry
