# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('base')

# Describe an action related to a YouTybe channel.
#
# @see https://kodi.wiki/view/Add-on:YouTube
class KodiFavGen::Actions::YoutubeChannel < KodiFavGen::Actions::Base
  def to_s
    action.to_s
  end

  protected

  # Get plugin URL.
  #
  # @return [String]
  def url
    "plugin://plugin.video.youtube/channel/#{"#{self.value}"}".then do |url|
      options[:path].then do |path|
        path ? "#{url}/%s/" % path.to_s.gsub(/^\/+/, '').gsub(/\/+$/, '') : url
      end
    end
  end

  # @return [KodiFavGen::Actions::ActivateWindow]
  def action
    # noinspection RubyMismatchedReturnType
    ::KodiFavGen::Actions.call(:activate_window, self.url)
  end
end
