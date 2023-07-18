# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../actions')

# Prints config contents (as pretty-printed JSON).
class KodiFavGen::App::Actions::Config < KodiFavGen::App::Actions::Base
  autoload(:JSON, 'json')

  protected

  def execute
    JSON.pretty_generate(payload).then do |output|
      $stdout.puts(output)
    end
  end

  # Get a Hash representation for config.
  #
  # Keys are sorted to improve ease of reading.
  #
  # @return [Hash{Symbol => Object]
  def payload
    self.config.to_h.sort.to_h
  end
end
