class PrintReturn < ActiveRecord::Base
  establish_connection :oracle_development

  def self.pickDates(date1, date2) #Query ran when we select a date range for Print returns
    query = "SELECT v.id,
              v.name printer,
              COUNT(bi.infoid) returns,
              (COUNT(bi.infoid)*2) fee,
              TRIM(TO_CHAR(MAX(dt_return), 'MONTH'))
              ||' '
              ||TRIM(TO_CHAR(MAX(dt_return),'YYYY')) RETURN_PERIOD
            FROM cink.prod_blankinfo bi
            INNER JOIN cink.vendors v
            ON bi.vendor_id = v.id
            WHERE bi.dt_return BETWEEN '#{date1}' AND '#{date2}'
            GROUP BY v.id,
              v.name
            ORDER BY v.name"

    info = PrintReturn.connection.select_rows(query)

    return info
  end

end
