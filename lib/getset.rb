module Getset
  def defaults
    @@defaults ||= {}
  end

  def properties(*names)
    names.each do |name|
      case name
      when Symbol
        create_property_accessors(name)
      when Hash
        name.each do |k,v|
          self.defaults ||= {}
          self.defaults[k] = v
          create_property_accessors(k)
        end
      end
    end
  end
  alias_method :property, :properties

  def create_property_accessors(name)
    define_method name do |*args|
      instance_variable_set("@#{name}", self.class.defaults[name].dup) if instance_variable_get("@#{name}").nil?
      instance_variable_set("@#{name}", args.first) unless args.empty?
      instance_variable_get("@#{name}")
    end

    define_method "#{name}=" do |value|
      instance_variable_set("@#{name}", value)
    end
  end
end
