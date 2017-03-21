file 'default www' do
	path '/var/www/html/index.html'
	content 'Hello world!'
end

webnodes = search('node', 'role:web')

webnodes.each do |node|
  puts node
end
