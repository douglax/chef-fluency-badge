#
# Cookbook:: postgresql
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


package 'postgresql' do
	notifies :run, 'execute[postgresql-init]', :immediately 
end

execute 'postgresql-init' do
	command '/usr/pgsql-9.4/bin/postgresql94-setup initdb'
	action :nothing
end

service 'postgresql' do
end
