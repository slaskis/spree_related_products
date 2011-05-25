Product.class_eval do
  has_many :relations, :as => :relatable

  def self.relation_types
    RelationType.find_all_by_applies_to(self.to_s, :order => :name)
  end

  def method_missing(method,*args)
    if relation_type = self.class.relation_types.detect {|rt| rt.name.downcase.gsub(" ", "_").pluralize == method.to_s.downcase }
      relations.find_all_by_relation_type_id(relation_type.id).map(&:related_to).select {|product| product.deleted_at.nil? && Time.now.to_i >= product.available_on.to_i }
    else
      super
    end
  end
end