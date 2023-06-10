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
# kodi-favgen directory='samples'
# kodi-favgen directory='samples' output='/dev/stdout'
# ```
class KodiFavGen::App
  autoload(:REXML, 'rexml')

  class << self
    # @api private
    MANDATORY_PARAMS = [:directory]

    def call(argv = nil)
      ::KodiFavGen::Config.call(argv || ARGV.dup).yield_self do |config|
        MANDATORY_PARAMS.each do |key|
          halt("#{key} must be set", status: 22) if config.get(key).nil?
        end

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
    end

    protected

    # @param [String, nil] message
    # @param [Fixnum] status
    def halt(message, status: 1)
      if message&.is_a?(String) and message.to_s.strip != ''
        if status.to_i.zero?
          puts(message)
        else
          warn(message)
        end
      end

      exit(status.to_i)
    end
  end
end
