2025-12-03 README

This code stack quality controls CoMeT data (UNL or CMU) from 2024 and 2025 data collection (the '2024' data format).  The output is an ASCII file matched to each original (full) file.  Output format depends on the CoMeT and will be described below.

Data are expected to live the following directory structure:
[Project name]
  [date] 
    CoMeT-[label]
	    Original data
	    QC’d data
"Project name" can be any alphanumeric string.  "Date" must be in YYYYMMDD format.  "Label" needs to be a number or "alpha".

Output data have a 28 (31) line header for CoMeTs 2, 3, alpha (1).  Each of the 22 fields in the data for CoMeTs 2, 3, and alhpa are comma deliminated and are as follows:
Type,Parameter_name,standard_name,long_name,units
string,date,date_string,DDMMYY,UTC
string,time,time_string,HHMMSS.s,UTC
float,latitude,latitude,Latitude,degrees_north
float,longitude,longitude,Longitude,degrees_east
float,altitude,altitude,Height above mean sea level,meters
float,pressure,air_pressure,Air pressure,hPa
float,temperature_fast,air_temperature,Air Temperature (Fast Response),Celsius
float,temperature_slow,air_temperature,Air Temperature (Slow Response),Celsius
float,rh_slow,relative_humidity,Relative Humidity (Slow Response),percent
float,rh_fast,relative_humidity,Relative Humidity (Calculated Using Fast Temperature),percent
float,dewpoint,dew_point_temperature,Dew Point Temperature (Derived),Celsius
float,water_vapor_mixing_ratio,humidity_mixing_ratio,Water Vapor Mixing Ratio (Derived),g/kg
float,theta,air_potential_temperature,Potential Temperature (Derived),Kelvin
float,theta_v,virtual_potential_temperature,Virtual Potential Temperature (Derived),Kelvin
float,theta_e,equivalent_potential_temperature,Equivalent Potential Temperature (Derived),Kelvin
float,wind_speed,wind_speed,Wind Speed (Derived),m/s
float,wind_direction,wind_from_direction,Wind Direction (Derived),degrees
float,vehicle_heading,platform_course,Vehicle Heading,degrees
float,vehicle_speed,platform_speed_wrt_ground,Vehicle Speed,m/s
double,computer_time,time,Computer Time,seconds since 1970-01-01 00:00:00
double,logger_time,time,Logger Time,seconds since 1970-01-01 00:00:00
string,error_string,error_string,Error String,String

Each of the 31 fields in the data for CoMeT 1 are comma deliminated and are as follows:
Type,Parameter_name,standard_name,long_name,units
string,date,date_string,DDMMYY,UTC
string,time,time_string,HHMMSS.s,UTC
float,latitude,latitude,Latitude,degrees_north
float,longitude,longitude,Longitude,degrees_east
float,altitude,altitude,Height above mean sea level,meters
float,pressure,air_pressure,Air pressure,hPa
float,temperature_fast,air_temperature,Air Temperature (Fast Response),Celsius
float,temperature_slow,air_temperature,Air Temperature (Slow Response),Celsius
float,rh_slow,relative_humidity,Relative Humidity (Slow Response),percent
float,rh_fast,relative_humidity,Relative Humidity (Calculated Using Fast Temperature),percent
float,dewpoint,dew_point_temperature,Dew Point Temperature (Derived),Celsius
float,water_vapor_mixing_ratio,humidity_mixing_ratio,Water Vapor Mixing Ratio (Derived),g/kg
float,theta,air_potential_temperature,Potential Temperature (Derived),Kelvin
float,theta_v,virtual_potential_temperature,Virtual Potential Temperature (Derived),Kelvin
float,theta_e,equivalent_potential_temperature,Equivalent Potential Temperature (Derived),Kelvin
float,anemometer_speed,wind_speed,Anemometer Speed,m/s
float,anemometer_direction,wind_from_direction,Anemometer Direction,degrees
float,wind_speed,wind_speed,Wind Speed (Derived),m/s
float,wind_direction,wind_from_direction,Wind Direction (Derived),degrees
float,vehicle_heading,platform_course,Vehicle Heading,degrees
float,vehicle_speed,platform_speed_wrt_ground,Vehicle Speed,m/s
long,number_satellites,number_of_GPS_satellites,Number of GPS Satellites,number
float,GPS_magnetic_variation,gps_magnetic_variation,GPS Magnetic Variation,degrees
float,horizontal_position_error,horizontal_position_error,Estimated GPS Horizontal Position Error,meters
float,vertical_position_error,vertical_position_error,Estimated GPS Vertical Position Error,meters
float,spherical_position_error,spherical_position_error,Overall GPS Spherical Position Error,meters
double,computer_time_gps,time,Computer Time of GPS Unit,seconds since 1970-01-01 00:00:00
double,computer_time_pressure,time,Computer Time of Pressure Unit,seconds since 1970-01-01 00:00:00
double,computer_time_thv,time,Computer Time of T/H Unit,seconds since 1970-01-01 00:00:00
double,computer_time_fluxgate,time,Computer Time of Fluxgate Compass,seconds since 1970-01-01 00:00:00
string,error_string,error_string,Error String,String
