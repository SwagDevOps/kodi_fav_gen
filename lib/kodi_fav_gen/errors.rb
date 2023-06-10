# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Namespace
module KodiFavGen::Errors
  # Base error.
  module Error
  end

  File.realpath(__FILE__).gsub(/\.rb/, '').then do |path|
    {
      GenerationError: :generation_error,
      MissingFileError: :missing_file_error,
    }.each do |k, v|
      autoload(k, "#{path}/#{v}")

      self.const_get(k).tap do |klass|
        # Ensure shared inheritance
        if %r{^#{self.name}::[A-Z].*}.match(klass.name)
          klass.__send__(:include, Error)
        end
      end
    end
  end
end
