# Build template data class.
class Chart
  def initialize(data)
    @data = data
  end

  # Support templating of member data.
  def get_binding
    binding
  end

  def build
    # Create template.
    template = %{
      <!DOCTYPE HTML>
      <html>
          <head>
              <meta charset="utf-8"><link rel="icon" href="https://static.jianshukeji.com/highcharts/images/favicon.ico">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <style>
                  /* css 代码  */
              </style>
              <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
              <script src="https://img.hcharts.cn/highcharts/highcharts.js"></script>
              <script src="https://img.hcharts.cn/highcharts/modules/exporting.js"></script>
              <script src="https://img.hcharts.cn/highcharts-plugins/highcharts-zh_CN.js"></script>
          </head>
          <body>
              <div>
                <select id='item1'></select>
                <select id='item2'></select>
                <select id='item3'></select>
              </div>
              <div id="container" style="min-width:400px;height:400px"></div>
              <script>
              var data = <%= @data %>;

              // 设置一级类目下拉选择框
              $.each(data, function(key, value){
                $("#item1").append('<option></option>');
                var option = $('<option/>');
                option.attr({ 'value': key }).text(key);
                $("#item1").append(option);
              });

              $("#item1").on('change', function(){
                $("#item2").empty();
                $("#item3").empty();

                var item1_value = $(this).val();
                $("#item2").append('<option></option>');
                for(var item in data[item1_value]){
                  $("#item3").append('<option></option>');
                  var option = $('<option/>');
                  if(item != "x_data"){
                    option.attr({ 'value': item }).text(item);
                    $("#item2").append(option);
                  }
                }
              });

              $("#item2").on('change', function(){
                $("#item3").empty();

                var item1_value = $("#item1").val();
                var item2_value = $(this).val();
                $("#item3").append('<option></option>');
                for(var item in data[item1_value][item2_value]){
                  var option = $('<option/>');
                  option.attr({ 'value': item }).text(item);
                  $("#item3").append(option);
                }
              });

              $("#item3").on('change', function(){
                var item1_value = $("#item1").val(),
                    item2_value = $("#item2").val(),
                    item3_value = $(this).val();
                init_chart(item1_value, item2_value, item3_value);
              });

              function init_chart(key1, key2, key3){
                var x_datas = data[key1]["x_data"];
                var series_data = [];

                for(var item in data[key1][key2][key3]){
                  console.log(item);
                  item_value = data[key1][key2][key3][item]
                  if(item.indexOf('增长率') != -1){
                    series_data.push({name: item, type: 'column', yAxis: 1,data: item_value})
                  }else{
                    series_data.push({name: item, type: 'spline', yAxis: 0,data: item_value})
                  }
                }

                var chart = Highcharts.chart('container', {
                    chart: {
                        zoomType: 'x'
                    },
                    title: {
                      text: '多妙屋--'+key1
                    },
                    xAxis: [{
                        categories: x_datas,
                        crosshair: false,
                        // tickmarkPlacement: 'on'
                    }],
                    yAxis: [{ // Primary yAxis
                        // lineWidth: 1,
                        // gridLineWidth: 1,
                        // gridLineColor: '#197F07',
                        labels: {
                            format: '{value} 万元',
                            style: {
                                color: Highcharts.getOptions().colors[3]
                            }
                        },
                        title: {
                            // text: '支付商品件数',
                            text: '',
                            style: {
                                color: Highcharts.getOptions().colors[3]
                            }
                        },
                        opposite: false
                    }, { // Tertiary  yAxis
                        // gridLineWidth: 1,
                        // gridLineColor: '#197F07',
                        title: {
                            text: '增长率 %',
                            style: {
                                color: Highcharts.getOptions().colors[1]
                            }
                        },
                        labels: {
                            format: '{value}',
                            style: {
                                color: Highcharts.getOptions().colors[1]
                            }
                        },
                        opposite: true,
                        linkedTo: 0,
                        min:-10,
                        max:10
                    }],
                    tooltip: {
                        shared: true
                    },
                    legend: {
                        layout: 'horizontal',
                      
                        backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
                    },
                    series: series_data
                });
              }
              </script>
          </body>
      </html>
    }.gsub(/^  /, '')

    template
  end

end