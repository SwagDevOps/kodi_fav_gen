# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('base')

# Action changing window (navigate).
#
# @see https://kodi.wiki/view/Opening_Windows_and_Dialogs
class KodiFavGen::Actions::ActivateWindow < KodiFavGen::Actions::Base
  def to_s
    "ActivateWindow(10025,&quot;#{super}&quot;,return)"
  end
end
