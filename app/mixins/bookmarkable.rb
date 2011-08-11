=begin
  This file is part of bewegung.

  Bewegung is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Foobar is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with bewegung.  If not, see <http://www.gnu.org/licenses/>.
=end

module Bookmarkable

  def self.included(base)

    base.send :include, InstanceMethods
    base.class_eval do

      # Add associations
      has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy
      has_many :bookmark_users, :through => :bookmarks, :source => :user, :class_name => "User"

    end
  end

  module InstanceMethods

    def bookmarkable_for?(user)
      return true if user.blank?

      user.bookmarks.exists?({ :bookmarkable_type => self.class.to_s,
                                  :bookmarkable_id => self.id }) or self.owner == user
    end

    def bookmarked_by?(user)
      return false if user.blank?

      user.bookmarks.exists?({:bookmarkable_type => self.class.to_s,
                              :bookmarkable_id => self.id})
    end
  end
end