module Statux
end

class ActiveRecord::Base

  # opts can be:
  # array
  # array, opts
  # string, array, opts
  def self.statux(*opts)
    name = [Symbol,String].include?(opts.first.class) ? opts.shift.to_s : 'status'
    vals = opts.shift.map(&:to_s)
    opts = opts.shift || {}

    required = opts[:required]
    column_name = opts[:column].try(:to_s) || name
    constant = opts[:constant] || name.pluralize.upcase
    
    prefx = "Statux(#{self.name}):"
    Rails.logger.error("#{prefx} column #{column_name} not found ! aborting ") and return unless column_names.include?(column_name.to_s) 
    Rails.logger.error("#{prefx} already used constant #{constant} !! disabling statux for #{name}") and return if const_defined? constant

    const_set name.pluralize.upcase, vals

    if opts[:initial]
      after_initialize do |record|
        record.status ||= opts[:initial]  if record.new_record?
      end
    end

    model_class = self

    if name != column_name
      define_method name do
        self[column_name] #.read_attribute(column_name)
      end
      define_method "#{name}=" do |x|
        self[column_name]=x.to_s #.write_attribute(column_name, x.to_s)
      end
      define_method "#{name}?" do |*x|
        x.map(&:to_s).include?(self[column_name]) #.read_attribute(column_name))
      end
    end

    vals.each do |stat|
      if method_defined?("#{stat}?")
        Rails.logger.error("#{prefx} Method already defined ##{stat}? skipping !!") 
      else
        define_method :"#{stat}?" do
          self.read_attribute(column_name) == stat.to_s
        end
      end
      scope stat, ->(){ where({column_name => stat}) }
    end

    # Class methods

    model_metaclass = class << model_class; self; end

    model_metaclass.instance_eval do
      define_method name.pluralize do
        const_get constant
      end
    end

    # Define validations
    validates_inclusion_of column_name, in: vals, allow_nil: !required
  end

end
