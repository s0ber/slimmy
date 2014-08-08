require 'json'
require 'haml'

def set_children_for_node(node, children_raw)
  node[:children] = []

  children_raw.each do |child_raw|
    node[:children] << {type: child_raw.type, data: child_raw[:value]}
    set_children_for_node(node[:children].last, child_raw[:children])
  end
end

file_path = ARGV[0]
template = File.read(file_path)
root_raw = Haml::Engine.new(template).parser.root

root_node = {type: root_raw.type, data: root_raw[:value]}
set_children_for_node(root_node, root_raw[:children])

print JSON.pretty_generate(root_node)
