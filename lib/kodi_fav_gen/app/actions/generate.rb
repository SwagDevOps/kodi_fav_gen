# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('base')

# Generate a favourite file.
class KodiFavGen::App::Actions::Generate < KodiFavGen::App::Actions::Base
  autoload(:REXML, 'rexml')

  protected

  def execute
    ::KodiFavGen::Template.new.then do |template|
      ::KodiFavGen::Output.new(template).call
    rescue ::KodiFavGen::Errors::GenerationError => e
      halt("#{e.message}:\n\n#{e.history.to_json}", status: 74) # EBADMSG
    rescue REXML::ParseException => e
      halt(e.message, status: 125) # ECANCELED
    rescue ::StandardError => e
      if e.class.name&.match(/^Errno::/) and e.class.constants.include?(:Errno)
        # noinspection RubyMismatchedArgumentType
        halt(e.message, status: e.class::Errno)
      end

      raise(e)
    end
  end

  def mandatory_params
    [:path, :thumbs_path]
  end
end
