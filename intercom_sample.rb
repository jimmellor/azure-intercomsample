require 'rubygems'
require 'intercom'
require 'pp'
require 'time'
require 'azure'
require 'json'

conf_file = File.read('intercom_sample.conf')
intercom_sample_settings = JSON.parse(conf_file)

intercom_app_id = intercom_sample_settings['intercom_app_id']
intercom_api_key = intercom_sample_settings['intercom_api_key']
azure_storage_account_name = intercom_sample_settings['azure_storage_account_name']
azure_storage_access_key = intercom_sample_settings['azure_storage_access_key']
intercom_partition_key  = intercom_sample_settings['intercom_partition_key']
sample_interval = intercom_sample_settings['sample_interval']
intercom_table_name = intercom_sample_settings['intercom_table_name']

last_request_at = Time.now.to_i - sample_interval.to_i

Azure.config.storage_account_name = azure_storage_account_name
Azure.config.storage_access_key = azure_storage_access_key

tables = Azure.tables

# check if the intercom-data table exits
intercom_data_table = nil

tables.query_tables.each do |table|
  if table[:properties]['TableName'] == intercom_table_name
    intercom_data_table = table
  end
end

# if the intercom data table doesn't exist, create it.
if !intercom_data_table
  tables.create_table(intercom_table_name)
end

intercom_connection = Intercom::Client.new(app_id: intercom_app_id, api_key: intercom_api_key)

intercom_connection.users.all.each do |user|
  # get the time the user last requested something
  user_last_request_at = user.last_request_at.to_i

  # check it was after the last time we collected data
  if user_last_request_at >= last_request_at
    intercom_data_sample = {
    :PartitionKey => intercom_partition_key,
    :RowKey => user_last_request_at.to_s,
    :email => user.email,
    :last_request_at => user.last_request_at.to_s,
    :location_lat => user.location_data.latitude.to_s,
    :location_long => user.location_data.longitude.to_s,
    :location_city => user.location_data.city_name,
    :zonza_site => user.custom_attributes["site"]
    }
    tables.insert_entity(intercom_table_name, intercom_data_sample)
  end
end
