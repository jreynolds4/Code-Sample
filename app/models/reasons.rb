class Reasons < ActiveRecord::Base
  establish_connection :mysql_development
  self.table_name = 'vp_opt_out_reasons'
end