require 'json'

Puppet::Type.type(:influx_database).provide :ruby do

  def auth_data
    user_str = ""
    if resource[:superuser]
      user_str = " -username #{resource["superuser"]} -password #{resource["superpass"]} "
    end
    user_str
  end


  def destroy
    `influx -host 127.0.0.1 #{auth_data} -execute 'DROP DATABASE #{resource[:name]}'`
  end

  def create
    `influx -host 127.0.0.1 #{auth_data} -execute 'CREATE DATABASE #{resource[:name]}'`
  end

  def exists?
    sleep (20)
    
    dbcmd =  `influx -host 127.0.0.1 #{auth_data} -execute 'SHOW DATABASES' -format json`
    dbjson = JSON.parse(dbcmd)
    if dbjson["results"][0]["series"][0]["values"].any? { |i| i.include? resource[:name] }
      return true
    end
    false
  end

end
