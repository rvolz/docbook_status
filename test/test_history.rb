# -*- encoding: utf-8 -*-
require 'minitest/spec'
require 'minitest/autorun'
require "docbook_status"

describe DocbookStatus::History do

  after(:each) do
    if File.exists?(DocbookStatus::History::HISTORY_FILE)
      File.unlink(DocbookStatus::History::HISTORY_FILE)
    end
  end

  it "initializes with minimal values" do
    h = DocbookStatus::History.new('test.xml')
    h.save
    File.exists?(DocbookStatus::History::HISTORY_FILE).must_equal(true)
    history = YAML.load_file(DocbookStatus::History::HISTORY_FILE)
    history[:file].must_equal('test.xml')
    history[:goal][:start].must_equal(Date.today)
    history[:goal][:end].must_equal(nil)
    history[:goal][:goal_total].must_equal(0)
    history[:goal][:goal_daily].must_equal(0)
  end

  it "initializes with all values" do
    h = DocbookStatus::History.new('test.xml',Date.today+10,10000,1000)
    h.save
    File.exists?(DocbookStatus::History::HISTORY_FILE).must_equal(true)
    history = YAML.load_file(DocbookStatus::History::HISTORY_FILE)
    history[:file].must_equal('test.xml')
    history[:goal][:start].must_equal(Date.today)
    history[:goal][:end].must_equal(Date.today+10)
    history[:goal][:goal_total].must_equal(10000)
    history[:goal][:goal_daily].must_equal(1000)
    h.goals.must_equal({:start => Date.today, :end=>Date.today+10, :goal_total => 10000, :goal_daily=>1000})
  end

  it "progress can be added" do
    h = DocbookStatus::History.new('test.xml')
    h.history?.must_equal(false)
    h.add(DateTime.now,100)
    h.history?.must_equal(true)
    h.today.must_equal({:min => 100, :max => 100, :start=>100, :end => 100, :ctr => 1})
    # add one word
    h.add(DateTime.now,101)
    h.today.must_equal({:min => 100, :max => 101, :start=>100, :end => 101, :ctr => 2})
    # subtract two words
    h.add(DateTime.now,99)
    h.today.must_equal({:min => 99, :max => 101, :start=>100, :end => 99, :ctr => 3})
    # add a progress from yesterday that should be ignored
    h.add(DateTime.now()-1,10)
    h.today.must_equal({:min => 99, :max => 101, :start=>100, :end => 99, :ctr => 3})
  end

  it "stores progress" do
    h = DocbookStatus::History.new('test.xml')
    h.history?.must_equal(false)
    h.add(DateTime.now,100)
    h.add(DateTime.now,101)
    h.add(DateTime.now,99)
    h.save
    h = nil
    i = DocbookStatus::History.new('test.xml')
    i.today.must_equal({:min => 99, :max => 101, :start=>100, :end => 99, :ctr => 3})
  end
end
