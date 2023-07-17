# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Namespace
module KodiFavGen::Concerns
  File.realpath(__FILE__).gsub(/\.rb/, '').then do |path|
    {
      Halt: :halt,
    }.each do |k, v|
      autoload(k, "#{path}/#{v}")
    end
  end
end
