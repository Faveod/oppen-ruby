# frozen_string_literal: true

require_relative 'lib'

describe 'Documentation' do
  it 'must cover everything' do
    report = `bundle exec yard stats --list-undoc`
    documented = report.lines.detect { |line| line =~ /% documented/ }

    assert_equal('100.00% documented', documented.strip, report)
  end
end
