# frozen_string_literal: true

# Runs the lines of Ruby in the Usage comment at the top of each recipe, with
# the requests stubbed: an example that the recipe does not offer fails here.
# The answer to every request is an empty 200, and no status is an error: what
# is checked is that each call exists and builds a request.
#
#   gem install api_recipes --pre webmock
#   ruby scripts/check_usage.rb recipes

require 'api_recipes'
require 'webmock'
require 'yaml'

include WebMock::API

WebMock.enable!
WebMock.disable_net_connect!

files = Dir[File.join(ARGV.fetch(0, 'recipes'), '*.recipe.yml')].sort
ApiRecipes.configure do |config|
  config.logger = Logger.new(IO::NULL)
  config.apis_configs = files.to_h do |file|
    name, options = YAML.safe_load(File.read(file)).first
    [name, options.reject { |key, _| key == 'recipe' }.merge('on_bad_code' => 'ignore')]
  end
end
stub_request(:any, //).to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

failed = 0
files.each do |file|
  comment = File.readlines(file, chomp: true).take_while { |line| line.start_with?('#') }
  examples = comment.select { |line| line.start_with?('#   ') }.map { |line| line.delete_prefix('#   ') }
  if examples.empty?
    failed += 1
    puts "#{file}: no Usage comment with examples"
    next
  end
  scope = binding
  examples.each do |line|
    scope.eval(line)
  rescue StandardError, SyntaxError => e
    failed += 1
    puts "#{file}: #{line}\n  #{e.class}: #{e.message.lines.first}"
  end
  puts "#{file}: #{examples.size} lines of Usage run"
end
exit(failed.zero? ? 0 : 1)
