# encoding: UTF-8
class OrganisationRegistrationPresenter < Presenter

  # Modules
  include Bewegung::Uuid

  # TODO Find a dynamic way to add the delegators
  def_delegators :organisation, :name, :password, :password_confirmation, :permalink, :corporate_form, :email, :website, :phone_number,
  :contact_name, :contact_name=, :contact_phone, :contact_phone=, :contact_email, :contact_email=,
  :name=, :password=, :password=, :password_confirmation=, :corporate_form=, :permalink=, :email=, :website=, :phone_number=,
  :description, :description=, :terms_of_use, :terms_of_use=, :short_name, :short_name=, :corporate_form_id, :corporate_form_id=,
  :fax_number, :fax_number=, :receive_newsletter, :receive_newsletter=, :agb, :agb=,
  :contact_email_confirmation, :contact_email_confirmation=, :subscribed_newsletter=, :subscribed_newsletter

  def_delegators :address,  :street, :zip_code, :city, :street=, :zip_code=, :city=

  attr_accessor :current_step, :saveable

  def initialize(*args)
    unless args.blank?
      super *args
    else
    end
    @saveable = false
    @current_step = "step_1"
  end

  def merge(params)
    params.each_pair do |attribute, value|
      self.send :"#{attribute}=", value
    end unless params.nil?
    self.send :"#{current_step}"
    return self
  end

  def go_to_step(step)
    @current_step = step
  end

  def step_1
    if @organisation.validate_attributes(:only => [:name, :password, :password_confirmation, :contact_email, :contact_email_confirmation, :permalink])
      @current_step = "step_2"
    else
      combine_errors organisation
    end
    
  end

  def step_2
    if organisation.validate_attributes(:only => [:contact_name, :contact_phone])
      @current_step = "step_3"
    else
      combine_errors organisation
    end
  end

  def step_3  
    address_valid = address.validate_attributes(:only => [:city, :street, :zip_code])
    if organisation.validate_attributes(:only => [:corporate_form_id]) and address_valid
      @current_step = "step_4"
    else
      combine_errors organisation, address
    end
  end

  def step_4
    if organisation.validate_attributes(:only => [:description, :agb])
      @saveable = true
    else
      combine_errors organisation
    end
  end

  def step_back
    current = current_step.split("_")[1].to_i
    if current == 1 then return "step_1" else return "step_#{current-1}" end
  end

  def organisation
    @organisation ||= Organisation.new
  end

  def address
    @address ||= Address.new
  end

  def save
    unless @saveable then return false end

    organisation.save_with_validation(false)
    address.addressable = organisation
    address.save
  end

end
