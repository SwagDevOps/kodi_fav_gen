# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Image processing.
class KodiFavGen::Output
  autoload(:Pathname, 'pathname')

  DEFAULT_FILE = '.kodi/userdata/favourites.xml'

  # @param [KodiFavGen::Template] subject
  # @param [KodiFavGen::Config, nil] config
  def initialize(subject, config: nil)
    @subject = subject
    @config = config || ::KodiFavGen::Config.new
  end

  # Write to file.
  #
  # @return [Pathname]
  def call
    self.file.tap do |file|
      subject.call.then do |result|
        file.write(result.output)

        unless result.errors.to_h.empty?
          ::KodiFavGen::Errors::GenerationError.new(nil, history: result.errors).then do |e|
            raise(e)
          end
        end
      end
    end
  end

  protected

  # @return [KodiFavGen::Template]
  attr_reader :subject

  # @return [KodiFavGen::Config]
  attr_reader :config

  # Get the path to the writing file.
  #
  # @return [Pathname]
  def file
    config.get(:output, exception: true) { Pathname.new(_1) }
  end
end
