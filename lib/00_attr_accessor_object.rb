class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
      instance_variable = ('@' + name.to_s).to_sym
      define_method(name) do

        self.instance_variable_get(instance_variable)
      end
      setter_name = (name.to_s + '=').to_sym
      define_method(setter_name) do |val|
        self.instance_variable_set(instance_variable, val)
      end
    end
  end
end
