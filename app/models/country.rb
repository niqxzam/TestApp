class Country < ApplicationRecord

 def self.options_for_select
  order('LOWER(name)').map { |e| [e.name, e.id] }
 end

 has_many :students
 
end
