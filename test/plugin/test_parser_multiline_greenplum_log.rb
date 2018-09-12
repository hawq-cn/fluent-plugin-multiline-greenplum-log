require "helper"
require "fluent/plugin/parser_multiline_greenplum_log.rb"

class MultilineGreenplumLogParserTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::MultilineGreenplumLogParser).configure(conf)
  end
end
