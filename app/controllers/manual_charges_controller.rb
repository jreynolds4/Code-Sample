class ManualChargesController < ApplicationController
  $vendor
  $insert_confirm = false
  $invalid = false

  def main
    puts "entered main function"

    puts Date.today.mon

    set_tab :manual_charges
  	@load_date = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    @r_val = nil
    @a_val = nil

    @delete_confirm = false
  	
	  @orderid = params[:orderid]
  	@reason = params[:reason]
  	@amount = params[:amount]
    @vendor = params[:vendors]
    @other = params[:other]
    @date_format = params[:statement_dt]

    $vendor = @vendor

    @sorts = ["Vendor", "Order ID", "Reason", "Amount"]
    @sort = params[:sort]

    @vendors = ManualChargesModel.grab_manual_charges
    @hash_table = ManualChargesModel.make_hash
  	@model = McSqlModel.new
    @reasons_model = McReasonsModel.new
    @reasons = @reasons_model.grab_table_data

    @delete = params[:delete]

    if @delete != nil
      delete_info(@delete)
      @delete_confirm = true
    end

  	@info = @model.grab_table_data(@vendor)
    sort_data(@sort, @info)

  end

  def delete_info(delete)
    @model = McSqlModel.new
    @model.delete_data(delete)
  end

  def sort_data(sort, info)
    case (sort)
      when 'Order ID' then
        info.sort_by! do |x|		# sorts in numerical order by order id
          x[1].to_i
        end
      when 'Reason' then
        info.sort_by! do |x|		# sorts in alphabetical order by reason
          x[2]
        end
      when 'Amount' then
        info.sort_by! do |x|		# sorts in numerical order by amount
          x[3].to_i
        end
      else
        info.sort_by! do |x|		# sorts in alphabetical order by vendor
          x[4]
        end
    end
  end

  def confirm_sub
    puts "entered submit function"
    @orderid = params[:orderid]
    @reason = params[:reason]
    @amount = params[:amount]
    @vendor = params[:vendors]
    @other = params[:other]
    @date_format = params[:statement_dt]
    @id = params[:id]

    @hash_table = ManualChargesModel.make_hash

    insert_new_data(@orderid, @reason, @amount, @other, @vendor, @date_format, @hash_table)
    puts "executed insert data function"
    update_old_data(@id, @vendor, @orderid, @reason, @amount, @other, @date_format)

    redirect_to '/manual_charges/main'

  end

  def mark_paid
    puts "entered mark paid function"
    puts @dt_paid = Date.today
    @vendor = params[:vendors]
    @model = McSqlModel.new
    @model.insert_date_paid(@dt_paid, @vendor)
    puts "executed insert date paid function"
    redirect_to '/manual_charges/main'
  end

  def insert_new_data(order_id, reason, amount, other, vendor, statement_dt, hash_table)
    @model = McSqlModel.new

    for i in 0..order_id.length

      @str = i.to_s

      if statement_dt[@str] != nil

        if vendor == "all"
          @vend = params[:vend]
          @vend = @vend[@str]
        else
          @vend = vendor
        end

        if reason != nil && reason != ""
          @r_val = reason[@str]
        end
        if amount != nil && amount != ""
          @a_val = @amount[@str]
          if @a_val.to_s.include?(',')
            puts 'comma'
            @a_val = @a_val.to_s.split(',')[0] + @a_val.to_s.split(',')[1]
          end
        end
        if other != nil && other != ""
          @o_val = other[@str]
        end

        if order_id == nil || order_id[@str] == ""
          o_id = "NULL"
        else
          o_id = order_id[@str]
        end

        @date = Date.parse(statement_dt[@str])

        # Rows with all empty text boxes get ignored. For orderid and amount, only values containing only numbers are
        # considered valid.

        if @vend == "" && o_id == "NULL" && @r_val == "" && @a_val == ""
          puts "ENTERED IF STATEMENT"
          $invalid = false
        elsif ((o_id.match('\A\d+\z') == nil) && (o_id != 'NULL')) || ((@a_val.match('[a-zA-z]') != nil) && (@a_val != '')) # verify validity
          puts "ENTERED ELSIF STATEMENT"
          puts o_id
          puts @a_val
          $invalid = true
          $insert_confirm = false
        else
          puts "ENTERED ELSE STATEMENT"
          @model.insert_data(@vend, hash_table[@vend], o_id, @r_val, @a_val, @o_val, @date)
          $insert_confirm = true
          $invalid = false
        end

      end
    end

  end

  def update_old_data(id, vendor, orderid, reason, amount, other, statement_dt)
    if id != nil
      id.each do |x|

        @str = x[0]
        puts x

        @date = Date.parse(statement_dt[@str])

        if id != nil || id[@str] != nil
          if reason != nil && reason != ""
            @r_val = reason[@str]
          end
          if amount != nil && amount != ""
            @a_val = amount[@str]
            @a_val = @a_val.split
            if @a_val.length != 1
              @a_val = @a_val[1]
            else
              @a_val = @a_val[0]
            end
          end
          if other != nil && other != ""
            @o_val = other[@str]
          end

          puts "AMOUNT >>>> #{@a_val}"

          if vendor == "all"
            @vend = params[:vend]
            @vend = @vend[@str]

            @model.update_data(id[@str], @vend, orderid[@str], @r_val, @a_val, @o_val, @date)
          else
            @model.update_data(id[@str], vendor, orderid[@str], @r_val, @a_val, @o_val, @date)
          end

        end
      end
    end
  end

end
