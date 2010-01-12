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
      if instance_variable_get("@#{name}").nil?
        default_value = self.class.defaults[name].dup rescue self.class.defaults[name]
        instance_variable_set("@#{name}", default_value)
      end
      instance_variable_set("@#{name}", args.first) unless args.empty?
      instance_variable_get("@#{name}")
    end

    define_method "#{name}=" do |value|
      instance_variable_set("@#{name}", value)
    end
  end
end
