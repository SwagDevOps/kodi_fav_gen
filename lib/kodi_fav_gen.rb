# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Namespace module
module KodiFavGen
  File.realpath(__FILE__).gsub(/\.rb/, '').then do |path|
    {
      App: :app,
      Config: :config,
      Glob: :glob,
      Output: :output,
      Template: :template,
      Thumb: :thumb,
    }.each do |k, v|
      autoload(k, "#{path}/#{v}")
    end
  end

  KodiFavGen::App.call if __FILE__ == $0
end

