# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Main application
#
# Samples of use
# ```shell
# kodi-favgen path='samples'
# kodi-favgen path='samples' output='/dev/stdout'
# ```
class KodiFavGen::App
  ::File.realpath(__FILE__).gsub(/\.rb/, '').then do |path|
    {
      Actions: :actions,
    }.each do |k, v|
      autoload(k, "#{path}/#{v}")
    end
  end

  class << self
    # @param [Array<String>] argv
    # @param [Hash{String, Symbol => String}] defaults
    def call(argv = nil, defaults = {})
      (argv || ARGV).fetch(0).then do |action_name|
        ::KodiFavGen::App::Actions.call(action_name, argv, defaults).call
      end
    end
  end
end
