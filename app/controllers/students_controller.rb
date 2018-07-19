class StudentsController < ApplicationController
 def index
   @filterrific = initialize_filterrific(
      Student,
      params[:filterrific],
      select_options: {
        sorted_by: Student.options_for_sorted_by,
        with_country_id: Country.options_for_select
      },
      persistence_id: 'shared_key',
      default_filter_params: {},
      available_filters: [:sorted_by, :with_country_id],
    ) or return
   @students = @filterrific.find.page(params[:page])

   respond_to do |format|
     format.html
     format.js
   end
    
   rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
 end
end
