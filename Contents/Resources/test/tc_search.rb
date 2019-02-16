#!/System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/bin/ruby

require "test/unit"
require 'Shellwords'

require_relative '../bundle/bundler/setup'
require 'repla'

require Repla::shared_test_resource("ruby/test_constants")
require Repla::Test::TEST_HELPER_FILE

require_relative "lib/test_data_helper"
require_relative "lib/test_data_parser"
require_relative "lib/test_javascript_helper"
require_relative "lib/test_data_tester"

require_relative "../lib/dependencies"

class TestDependencies < Test::Unit::TestCase
  def test_dependencies
    passed = Repla::Search.check_dependencies
    assert(passed, "The dependencies check should have passed.")
  end
end

class TestSearch < Test::Unit::TestCase

  SEARCH_FILE = File.join(File.dirname(__FILE__), "..", 'search.rb')
  def test_controller
    test_data_directory = Repla::Search::Tests::TestData::test_data_directory
    test_search_term = Repla::Search::Tests::TestData::test_search_term
    command = "#{Shellwords.escape(SEARCH_FILE)} \"#{test_search_term}\" #{Shellwords.escape(test_data_directory)}"
    `#{command}`

    window_id = Repla::Test::Helper::window_id
    window = Repla::Window.new(window_id)

    files_json = Repla::Search::Tests::JavaScriptHelper::files_hash_for_window_manager(window)
    files_hash = Repla::Search::Tests::Parser::parse(files_json)

    test_data_json = Repla::Search::Tests::TestData::test_data_json
    test_files_hash = Repla::Search::Tests::Parser::parse(test_data_json)

    file_hashes_match = Repla::Search::Tests::TestDataTester::test_file_hashes(files_hash, test_files_hash)
    assert(file_hashes_match, "The file hashes should match.")

    window.close
  end

end
