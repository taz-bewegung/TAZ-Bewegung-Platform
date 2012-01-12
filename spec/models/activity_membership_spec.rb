require 'spec_helper'

describe ActivityMembership do
  describe "Scopes" do

    it "should respond to active" do
      ActivityMembership.respond_to?(:active).should be_true
    end
    
    it "should respond to active_with_user" do
      ActivityMembership.respond_to?(:active_with_user).should be_true
    end
    
    it "should respond to latest" do
      ActivityMembership.respond_to?(:latest).should be_true
    end

    it "should respond to limit" do
      ActivityMembership.respond_to?(:limit).should be_true
    end
    
    it "should respond to pending" do
      ActivityMembership.respond_to?(:pending).should be_true
    end

  end
end