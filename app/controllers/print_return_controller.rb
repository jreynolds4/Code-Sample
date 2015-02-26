class PrintReturnController < ApplicationController

  $info_for_commit
  $verify_commit
  $success
  $empty_date

  def main
    set_tab :print_return

    @date1 = params[:date1]
    @date2 = params[:date2]

    if(@date1 == nil || @date2 == nil)
      @info = []
    else

      @first = @date1.to_s + ' 00:00:00' # first date from midnight
      @second = @date2.to_s + ' 23:59:59' # second date until 11:59 PM

      @info = PrintReturn.pickDates(@first, @second)
    end

    $info_for_commit = @info

  end

  def pickDates

    @date1 = params[:date1]
    @date2 = params[:date2]

    @info = PrintReturn.pickDates(@date1, @date2)

  end

  def commit
    @model = PrSql.new
    @date1 = params[:date1]
    @date2 = params[:date2]

    puts "PRINT"
    print @date1

    if @date1 == "" || @date2 == ""
      $empty_date = true
    else
      verification = @model.verify_insert(@date1, @date2)

      if verification == []
        $info_for_commit.each { |vendor|
          @model.insert_data(vendor[0], vendor[1], vendor[2], vendor[3], vendor[4])
        }
        $success = true
      else
        $verify_commit = true
      end
    end
    redirect_to '/print_return/main'
  end
end
