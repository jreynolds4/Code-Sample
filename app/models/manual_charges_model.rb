class ManualChargesModel < ActiveRecord::Base
	establish_connection :oracle_development
	def self.grab_manual_charges
		query = "SELECT DISTINCT v.id,
		 	 o.printer
		 	FROM cink.prod_overview o
		 	INNER JOIN cink.prod_sched s
		 	ON o.orderid = s.orderid
		 	INNER JOIN cink.vendors v
			ON o.printer     = v.name
		 	WHERE s.dt_ship >= TRUNC(sysdate - 60)
		 	AND NOT EXISTS
		 	(SELECT ve.id
		 	FROM cink.vendors ve
		 	JOIN cink.vendors_vendorgroups vvg
		 	ON ve.id = vvg.vendor_id
		 	JOIN cink.vendorgroups vg
		 	ON vvg.vendorgroup_id    = vg.id
		 	WHERE vvg.VENDORGROUP_ID = 824
		 	AND v.id                 = ve.id
		 	)"

		info = ManualChargesModel.connection.select_rows(query)

		info.sort_by! do |x|		# sorts in alphabetical order
			x[1]
		end

		return info
	end

	def self.make_hash
		vendors = self.grab_manual_charges

		hash = Hash[vendors.map {|key, value| [value, key]}] #makes a hash storing printer names as keys and id's as values

		return hash

	end
end
