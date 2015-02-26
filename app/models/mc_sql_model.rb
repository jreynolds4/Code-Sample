class McSqlModel < ActiveRecord::Base
	establish_connection :mysql_development
	self.table_name = "vp_charges"

	def grab_table_data(vendor)
		if vendor == "all" || vendor == nil
			query = "SELECT id, order_id, description, amount, printer, comments, statement_date, created_at FROM vp_charges WHERE dt_paid IS NULL AND soft_delete=0"
		else
			query = "SELECT id, order_id, description, amount, comments, statement_date, created_at FROM vp_charges WHERE printer = '#{vendor}' AND dt_paid IS NULL AND soft_delete=0"
		end

		info = McSqlModel.connection.select_rows(query)

		return info
	end

	def insert_data(vendor, printer_id, orderid, reason_insert, amount, other_val, statement_dt)

		select_query = "SELECT * FROM vp_charges"
		info = McSqlModel.connection.select_rows(select_query)

		@bool = false

		info.each do |x|
			if x[1] == orderid && x[4] == reason_insert   # if same orderid & description
				@bool = true
			end
    end

    if amount == ''
      puts 'empty string'
      amt = 0
    elsif amount.to_s.include?(',')
      puts 'comma'
      amt = amount.to_s.split(',')[0] + amount.to_s.split(',')[1]
    else
      amt = amount
    end

		if @bool == false

			@date = Date.today
			insert_query = "INSERT into vp_charges(order_id, printer, description, amount, type, dt_paid, printer_id, created_at, comments, statement_date, soft_delete) VALUES(#{orderid}, '#{vendor}', '#{reason_insert}', #{amt}, 'manual_charges', NULL, #{printer_id}, '#{@date}', '#{other_val}', '#{statement_dt}', 0)"

			McSqlModel.connection.execute(insert_query)
    end
	end

	def delete_data(id)
		@query = "UPDATE vp_charges SET soft_delete=1 WHERE id = #{id}"
		McSqlModel.connection.execute(@query)
	end

	def insert_date_paid(date, vendor)
    puts "entered insert date paid function"
    @query
    @grab = "SELECT id, statement_date FROM vp_charges WHERE soft_delete = 0"
    @elements = McSqlModel.connection.select_rows(@grab)
    puts @elements
    @elements.each { |statement_dt|
      @month = Date.parse(statement_dt[1]).mon
      if @month < Date.today.mon
        puts Date.parse(statement_dt[1])
        if vendor == "all"
          @query = "UPDATE vp_charges SET dt_paid='#{date}' WHERE dt_paid IS NULL AND soft_delete = 0 AND id = #{statement_dt[0]}"
        else
          @query = "UPDATE vp_charges SET dt_paid='#{date}' WHERE dt_paid IS NULL AND printer = '#{vendor}' AND soft_delete = 0 AND id = #{statement_dt[0]}"
        end
        McSqlModel.connection.execute(@query)
      end

    }
	end

	def update_data(id, vendor, orderid, reason_insert, amount, other_insert, statement_dt)
    if orderid == nil || orderid == ""
      o_id = "order_id = NULL"
    else
      o_id = "order_id=#{orderid}"
    end

    if amount == ''
      amount = 0
    end

		@query = "UPDATE vp_charges SET description='#{reason_insert}', #{o_id}, printer='#{vendor}', amount=#{amount}, comments='#{other_insert}', statement_date='#{statement_dt}' WHERE id=#{id}"
		McSqlModel.connection.execute(@query)
	end

end
