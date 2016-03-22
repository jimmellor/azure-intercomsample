# azure-intercomsample

Push your Intercom.io data to an Azure Table

##Installation & config

Modify the intercom_sample.conf.example file and rename it intercom_sample.conf to contain your credentials and stuff.

Field to table mappings are hard-coded lines 54 -. You might want to change those.

##Usage

Do

```
ruby intercom_sample.rb
```

Pop in on cron at whatever interval you've specified in intercom_sample.conf.