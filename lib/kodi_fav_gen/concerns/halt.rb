# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../concerns')

# Provides halt method.
#
# outputs message to stdout on success or stderr on failure
module KodiFavGen::Concerns::Halt
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
