require 'json'
require 'haml'

def copy_children(node, children_raw)
  node[:children] = []

  children_raw.each_with_index do |child_raw, index|
    node[:children][index] = {type: child_raw.type, data: child_raw[:value]}
    copy_children(node[:children][index], child_raw[:children])
  end
end

file_path = ARGV[0]
template = File.read(file_path)
root_raw = Haml::Engine.new(template).parser.root

root_node = {type: root_raw.type, data: root_raw[:value]}
copy_children(root_node, root_raw[:children])

print JSON.pretty_generate(root_node)
