class Student < ApplicationRecord

 filterrific :default_filter_params => { :sorted_by => 'created_at DESC' },
              :available_filters => %w[
                sorted_by
                search_query
                with_country_id
                with_created_at_gte
              ]

 belongs_to :country

 scope :search_query, lambda { |query|

  return nil  if query.blank?

  terms = query.downcase.split(/\s+/)

  terms = terms.map { |e|
    (e.gsub('*', '%') + '%').gsub(/%+/, '%')
  }

  num_or_conds = 2
  where(
    terms.map { |term|
      "(LOWER(students.first_name) LIKE ? OR LOWER(students.last_name) LIKE ?)"
    }.join(' AND '),
    *terms.map { |e| [e] * num_or_conds }.flatten
  )
}

 scope :sorted_by, lambda { |sort_option|
  direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
  case sort_option.to_s
  when /^name/
    order("LOWER(students.name) #{ direction }")
  when /^email/
    order("LOWER(students.email) #{ direction }")
  when /^country/
    order("LOWER(students.country) #{ direction }")
  when /^registered_at/
    order("LOWER(students.decorated_created_at) #{ direction }")
  else
    raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
  end
}

 scope :with_country_id, lambda { |country_ids|

 where(country_id: [*country_ids])
}

 scope :with_created_at_gte, lambda { |ref_date|

 where('students.created_at >= ?', reference_time)
}

 def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Registration date (newest first)',
       'created_at_desc'],
      ['Registration date (oldest first)', 
      	'created_at_asc'],
      ['Country (a-z)', 'country_name_asc']
    ]
 end

end
