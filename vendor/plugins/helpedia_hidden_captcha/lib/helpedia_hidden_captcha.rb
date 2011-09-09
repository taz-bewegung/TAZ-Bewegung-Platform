module Helpedia

  module HiddenCaptcha

    module Validations
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Validates whether the value of the specified attribute passes the captcha challenge
        #
        # class User < ActiveRecord::Base
        # validates_with_hidden_captcha # end
        #
        # Configuration options:
        # * <tt>message</tt> - A custom error message (default is: " can not create this because you are the sux.")
        # * <tt>on</tt> Specifies when this validation is active (default is :create, other options :save, :update)
        # * <tt>if</tt> - Specifies a method, proc or string to call to determine if the validation should
        # occur (e.g. :if => :allow_validation, or :if => Proc.new { |user| user.signup_step > 2 }). The
        # method, proc or string should return or evaluate to a true or false value.
        def validates_with_hidden_captcha(options = {})
          attr_accessor :value_for_text_input

          configuration = { :message => ' can not create this because you are the sux.', :on => :create }
          configuration.merge(options)

          validates_each(:value_for_text_input, configuration) do |record, attr_name, value|
            record.errors.add(:value_for_text_input, configuration[:message]) unless record.send(:value_for_text_input).blank?
          end
        end
      end
    end

    module Helper

      def hidden_captcha_field(object, options={})
        style = options.delete(:style) || ''
        style = style.blank? ? "display: none;" : "#{style}; display: none;"
        ActionView::Helpers::InstanceTag.new(object, :value_for_text_input, self).to_input_field_tag("text", options.merge(:style=>style))
      end
    end
  end
end
