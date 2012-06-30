 # -*- encoding:utf-8 -*-

require 'yaml'
module DocbookStatus

  # Manages the history of writing progress in two modes. In session
  # or demon mode the history shows progress for the user session. In
  # normal mode the history is only maintained for calendar days,
  # weeks, months.
  #
  # The writing progress can (but must not) measured with these optional
  # items:
  # * start date (date of initialization)
  # * scheduled end date
  # * total word count goal
  # * daily word count goal
  #
  # * file name
  # * goal total
  # * goal daily
  # * start date
  # * planned end date
  # current entries
  # * timestamp
  # * word count
  # archive entries
  # * date
  # * start
  # * end
  # * min
  # * max
  # * ctr (number of entries for the day)
  #
  class History

    # History file, YAML format
    HISTORY_FILE = 'dbs_work.yml'

    # Does the history file exist?
    def self.exists?()
      File.exists?(HISTORY_FILE)
    end

    # Load the exisiting writing history
    def initialize(name,end_planned=nil,goal_total=0,goal_daily=0)
      if File.exists?(HISTORY_FILE)
        @history = YAML.load_file(HISTORY_FILE)
      else
        @history = {:file => name,
          :goal => {
            :start => Date.today,
            :end => end_planned,
            :goal_total => goal_total,
            :goal_daily => goal_daily},
          :current => [],
          :archive => {}}
      end
    end

    def planned_end(date)
      @history[:goal][:end]=date
    end

    def total_words(tw)
      @history[:goal][:goal_total]=tw
    end

    def daily_words(tw)
      @history[:goal][:goal_daily]=tw
    end

    # Add to the history
    def add(ts,word_count)
      # Ruby 1.8 doesn't have DateTime#to_date, so we check that here
      begin
        k = ts.to_date
      rescue NoMethodError
        k = Date.parse(ts.to_s)
      end
      unless (@history[:archive][k].nil?)
        @history[:archive][k][:min] = word_count if @history[:archive][k][:min] > word_count
        @history[:archive][k][:max] = word_count if @history[:archive][k][:max] < word_count
        @history[:archive][k][:end] = word_count
        @history[:archive][k][:ctr] += 1
      else
        @history[:archive][k] = {:min => word_count, :max => word_count, :start => word_count, :end => word_count, :ctr => 1}
      end
    end

    # Is there already a history?
    def history?
      @history[:archive].length != 0
    end

    # Convenience - returns the statistics for today
    def today
      @history[:archive][Date.today]
    end

    # Return the goals
    def goals
      @history[:goal]
    end

    # Save the writing history
    def save
      File.open(HISTORY_FILE, 'w') {|f| YAML.dump(@history,f)}
    end
  end
end
