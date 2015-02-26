class McReasonsModel < ActiveRecord::Base
	establish_connection :mysql_development
	self.table_name = "vp_manual_charges_reasons"

	def grab_table_data
		query = "SELECT * FROM vp_manual_charges_reasons"

		info = McReasonsModel.connection.select_rows(query)

		return info
	end

end
