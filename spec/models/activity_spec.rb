require 'spec_helper'

describe Activity do
  describe "Scopes" do

    it "should respond to active" do
      Activity.respond_to?(:active).should be_true
    end

    it "should respond to running" do
      Activity.respond_to?(:running).should be_true
    end

    it "should respond to recent" do
      Activity.respond_to?(:recent).should be_true
    end

    it "should respond to latest" do
      Activity.respond_to?(:latest).should be_true
    end

    it "should respond to finished" do
      Activity.respond_to?(:finished).should be_true
    end

    it "should respond to with_image" do
      Activity.respond_to?(:with_image).should be_true
    end

    it "should respond to ordered" do
      Activity.respond_to?(:ordered).should be_true
    end

    it "should respond to limit" do
      Activity.respond_to?(:limit).should be_true
    end

  end
end