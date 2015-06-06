require 'json/pure'
require 'open-uri'
require_relative './views.rb'
require_relative './utils.rb'

TOOLBUS_ROOT = File.join(`gem which toolbus`.chomp.chomp("/lib/toolbus.rb"))

class Toolbus
  include GitUtils

  def initialize
    validate_repo
    @features = fetch_features
  end

  def validate_repo
    ConsoleManager.error "Unpushed commits! Push or stash before running." unless latest_commit_online?
    ConsoleManager.error "Uncommitted changes! Stash or commit and push before running." unless git_status_clean?
  end

  def fetch_features
    # TODO: GET all features for our tools and versions, once that API exists
    JSON.parse(File.read(File.open(File.join(TOOLBUS_ROOT, 'spec/fixture/sample.json'))))['data']
  end

  SCAN_TIME_SECONDS = 4.0
  def scan
    statuses = []
    progress = 0.0
    @features.map { |feature| feature.default = 0 } # helps measure progress
    num_steps = scanning_plan.inject(0) { |total, (file, blueprints)| total + blueprints.length }

    scanning_plan.each_with_index do |(file, search_for), file_index|
      statuses << "Scanning #{file}"
      search_for.each do |search_for|
        id = search_for.keys.first
        blueprint = search_for.values.first

        progress += 1
        begin
          match = SyntaxTree.new(file).include?(SyntaxTree.new(blueprint))
        rescue Parser::SyntaxError
          statuses << "Syntax Error: #{file}"
          next
        end

        if match
          feature = @features.find { |feature| feature['id'] == id }
          feature['count'] += 1
          statuses << "POST /completions: repo_url: #{repo_url}, feature_id: #{id}, commit: ???, filename: #{file}, first_line: #{match[:first_line]}, last_line: #{match[:last_line]}"
        end

        percent_complete = (progress / num_steps) * 100
        ConsoleManager.repaint([
          ProgressBarView.new(percent_complete),
          TableView.new(features_found),
          StatusBoxView.new(statuses),
          "Found #{num_completions} total completions across #{num_features_completed}/#{@features.count} features across #{file_index}/#{scanning_plan.count} files!"
        ])
        sleep SCAN_TIME_SECONDS / num_steps
      end
    end
  end

  private 
  
  def scanning_plan
    hash_with_array_values = Hash.new { |h, k| h[k] = [] }

    @features.inject(hash_with_array_values) do |plan, feature|
      Dir.glob(feature['search_in']).each do |file|
        plan[file] << { feature['id'] => feature['search_for'] }
      end
      plan
    end
  end

  def feature_module_and_name(feature)
    [feature['module'], ': ', feature['name']].join
  end

  def features_found
    Hash[@features.map { |feature| [feature_module_and_name(feature), feature['count']] }]
  end

  def num_completions
    @features.inject(0) { |total, feature| total + feature['count'] }
  end

  def num_features_completed
    @features.select { |feature| feature['count'] > 0 }.count
  end
end
