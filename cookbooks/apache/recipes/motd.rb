hostname = node['hostname']

file '/etc/motd' do
	content "The hostname is: #{hostname}"
end
