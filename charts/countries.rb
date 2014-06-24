# Encoding: utf-8
require 'hiredis'
require 'redis'

head = %Q(<html>
  <head>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
    <script type='text/javascript'>
     google.load('visualization', '1', {'packages': ['geochart']});
     google.setOnLoadCallback(drawRegionsMap);
)
puts head + 'function drawRegionsMap() {
        var data = google.visualization.arrayToDataTable([
'

puts '[\'Country\', \'Port 873\'],'
geoip = Redis.new(db: 1, driver: 'hiredis', timeout: 30)

geoip.keys('res:*').each do |result|
  country = result.split(':')
  puts "['#{country[1]}', #{geoip.llen(result)}],"
end
puts ']); var options = {
colorAxis: {colors: [\'#ffffb2\', \'#fed976\', \'#feb24c\', \'#fd8d3c\', \'#fc4e2a\', \'#e31a1c\', \'#b10026\'], values: [1,10,100,1000,10000,100000,1000000]}
};'

puts 'var chart = new google.visualization.GeoChart(document.getElementById(\'chart_div\'));
        chart.draw(data, options); };'
tail = %Q(</script>
  </head>
  <body>
    <div id="chart_div" style="width: 900px; height: 500px;"></div>
  </body>
</html>)
puts tail
