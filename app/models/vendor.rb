class Vendor < ActiveRecord::Base
  establish_connection :mysql_development
  self.table_name = 'reporting_dw.vp_vendor_mapping'
  #grab the vendors for GVP
  scope :gvp_vendor_names, -> {
    select('reporting_dw.vp_vendor_mapping.vendor_name')}
end
