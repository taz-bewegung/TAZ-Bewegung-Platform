# encoding: UTF-8
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

# The (polymorphic) commentable module enables models to be commentable.
# The model needs a field comment_state to store if comments are allowed.
module Commentable
  # Constants
  COMMENTS_ALLOWED = "1" unless defined?(COMMENTS_ALLOWED)
  COMMENTS_ALLOWED_FOR_USERS = "2" unless defined?(COMMENTS_ALLOWED_FOR_USERS)
  COMMENTS_NOT_ALLOWED = "3" unless defined?(COMMENTS_NOT_ALLOWED)
  COMMENTABLE = [["Erlaubt", COMMENTS_ALLOWED],
                ["Nur für registrierte Benutzer", COMMENTS_ALLOWED_FOR_USERS],
                ["Nicht erlaubt", COMMENTS_NOT_ALLOWED]] unless defined?(COMMENTABLE)
  def self.included(base)

    base.class_eval do

      # Add association
      has_many :comments, :as => :commentable, :dependent => :destroy

      def commentable_humanized
        COMMENTABLE[self.commentable.to_i-1].first
      end

      # Ad
      state_machine :comment_state, :initial => :allowed do
        state :allowed do
          def label
            I18n.t(:"comments.comments_allowed")
          end
        end
        state :users_only do
          def label
            I18n.t(:"comments.comments_allowed_for_users")
          end
        end
        state :not_allowed do
          def label
            I18n.t(:"comments.comments_not_allowed")
          end
        end
      end

    end
  end
end