class Plan < ActiveRecord::Base
  has_many :sites
  has_many :subscriptions
  has_and_belongs_to_many :service_categories
  
  attr_accessor :billing_interval
  
  before_save :set_interval
  
  def next_bill_date
    case self.interval
    when "month"
      case self.interval_count
      when 1
        return Time.now.at_beginning_of_month.next_month.utc
      when 6
        case Time.now.utc.month
        when 1..6
          return Time.new(Time.now.utc.year, 7, 1).utc
        when 7..12
          return Time.new(Time.now.utc.year+1, 1, 1).utc
        end
      end

    when "year"
      return Time.new(Time.now.utc.year+1, 1, 1).utc

    end
  end
  
  def days_until_next_bill_date
    current_date = Time.now.utc
    next_date = self.next_bill_date
    return ((next_date - current_date)/1.day).ceil
  end
  
  def days_between_interval
    case self.interval
    when "month"
      case self.interval_count
      when 1
        return ((Time.now.at_beginning_of_month.next_month.utc - Time.now.at_beginning_of_month.utc)/1.day).ceil
      when 6
        case Time.now.utc.month
        when 1..6
          return ((Time.new(Time.now.year, 6, 30).utc - Time.new(Time.now.year, 1, 1).utc)/1.day).ceil
        when 7..12
          return ((Time.new(Time.now.year, 12, 31).utc - Time.new(Time.now.year, 7, 1).utc)/1.day).ceil
        end
      end

    when "year"
      return ((Time.new(Time.now.year+1, 1, 1).utc - Time.new(Time.now.year, 1, 1).utc)/1.day).ceil

    end
  end
  
  def prorated_charge
    if self.prorate 
      return ((self.price/self.days_between_interval)*self.days_until_next_bill_date).to_f.round(2)
    else
      return self.price
    end
  end
  
  def self.intervals
    return ["month" => "Month", "biannual" => "6 Months", "annual" => "Year"]
  end
  
  def interval_map(task)

    @intervals = {
      'month' => {'interval_count' => 1, 'interval' => 'month'},
      'biannual' => {'interval_count' => 6, 'interval' => 'month'},
      'year' => {'interval_count' => 1, 'interval' => 'year'},
    }
    
    case task
    when "count"
      return @intervals[self.billing_interval]['interval_count']
    when "interval"
      return @intervals[self.billing_interval]['interval']
    end
  end
  
  
  private
    def set_interval
      self.interval_count=self.interval_map('count')
      self.interval=self.interval_map('interval')
    end
end
