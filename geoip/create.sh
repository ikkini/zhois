rm GeoIPCountryCSV.zip
rm GeoIPCountryWhois.csv
wget http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip
unzip GeoIPCountryCSV.zip
cp GeoIPCountryWhois.csv geoip2.csv
mv GeoIPCountryWhois.csv geoip.csv
gsed -i '1i "0","0","0","0","NIKS","NIKS"' geoip2.csv
echo '"0","0","0","0","NIKS","NIKS"' >> geoip.csv
paste -d ',' geoip.csv geoip2.csv > geoipmatrix.csv
