# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'colored'

require_relative '../lib/oppen'

# Display helpers.
def title(str) = puts str.green
