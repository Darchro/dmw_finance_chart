require 'sinatra'
require 'rack/cors'

require "erb"
require 'roo'
require 'json'

require_relative "lib/chart.rb"

class ChartsApp < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/uploads' do
    #文件临时存储在服务器上
    file_name = params[:file][:filename]
    file = params[:file][:tempfile]

    File.open("./public/download_tmp/#{file_name}", 'wb') do |f|
      f.write(file.read)
    end

    #处理数据
    @data = xls_parse(file_name)
    
    #生成一个html文件
    render_chart(@data, file_name)

    send_file "./public/download_tmp/#{file_name.split('.').first}.html", :filename => "#{file_name.split('.').first}.html", :type => 'Application/octet-stream'
  end

  private
  def xls_parse(file_name)
    xls_file = "./public/download_tmp/#{file_name}" # "数据_0720.xlsx"
    file = Roo::Excelx.new(xls_file, {:expand_merged_ranges => true})
    sheets = file.sheets

    data_hash = {}
    x_data = %w(1月 2月 3月 4月 5月 6月 7月 8月 9月 10月 11月 12月)
    sheets.each do |sheet_name|
      sheet = file.sheet(sheet_name)
      data_hash[sheet_name] = {"x_data" => x_data} unless data_hash.has_key?(sheet_name)
      ((sheet.first_row + 1)..sheet.last_row).each do |n|
        row_data = sheet.row(n)
        t1 = row_data[0] #类目一名称
        data_hash[sheet_name][t1] = {} unless data_hash[sheet_name].has_key?(t1)
        t2 = row_data[1] #类目二名称
        data_hash[sheet_name][t1][t2] = {} unless data_hash[sheet_name][t1].has_key?(t2)
        year = row_data[2] #数据所属年份
        year_data = year.include?('增长率') ? row_data[3, 12].collect{|data| (data * 100).round(2) rescue nil} : row_data[3, 12].collect{|data| data.round(2) rescue nil}
        data_hash[sheet_name][t1][t2][year] = year_data
      end
    end
    return data_hash.to_json
  rescue IOError => e
    warn "没有找到对应的文件"
  end

  def render_chart(data, file_name)
    chart = Chart.new data

    template = chart.build
    rhtml = ERB.new(template)

    # # Produce result.
    content = rhtml.result(chart.get_binding)

    File.open("./public/download_tmp/#{file_name.split('.').first}.html", 'w') do |f|
      f.write(content)
    end

  end

end
