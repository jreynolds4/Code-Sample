class PrSql < ActiveRecord::Base
  establish_connection :mysql_development
  self.table_name = "vp_charges"
# Store data in the vp_charges table
  def insert_data(printerid, vendor, returns, fee, creation_date)

      @date = Date.today
      creation_date = Date.parse(creation_date)
      insert_query = "INSERT into vp_charges(printer, type, amount, returns, dt_paid, printer_id, created_at, statement_date) VALUES('#{vendor}', 'Returns made', #{fee}, #{returns}, '#{@date}', #{printerid}, '#{creation_date}', '#{Date.today}')"

      PrSql.connection.execute(insert_query)
  end

  def verify_insert(date1, date2)
    if date1 == ""
      result = 1
    else
      date = Date.parse(date1).strftime('%Y-%m')
      query = "SELECT * FROM vp_charges WHERE type = 'Returns made' AND created_at = '#{date}-01 00:00:00'"
      result = PrSql.connection.select_rows(query)
    end
    return result
  end
end
