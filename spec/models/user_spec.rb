require 'spec_helper'

describe User do
  describe "Uuid" do
    
    it "should have a primary key" do
      User.primary_key.should_not be_nil
      User.primary_key.should == "uuid"
    end
    
    it "should create a uuid" do
      user = User.new
      user.save(:validate => false)
      user.id.length.should == 36
    end

  end
end