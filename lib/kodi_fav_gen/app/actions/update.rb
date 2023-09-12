# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../actions')

# Update favourites through version-contol.
class KodiFavGen::App::Actions::Update < KodiFavGen::App::Actions::Base
  autoload(:Pathname, 'pathname')

  protected

  def mandatory_params
    [
      :update_path,
      :update_branch,
    ]
  end

  def execute
    Dir.chdir(update_path.realpath.to_path) do
      git.update(branch: update_branch)
    end
  end

  private

  # @return [KodiFavGen::Git]
  def git
    ::KodiFavGen::Git.new
  end

  # @return [Pathname]
  def update_path
    config.get(:update_path, exception: true) { Pathname.new(_1) }
  end

  # @return [String]
  def update_branch
    config.get(:update_branch, exception: true).to_s
  end
end
