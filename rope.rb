require_relative './splay_tree.rb'

#
# Abstract String structured as a binary search tree for fast split and merge operations
# The keys of the nodes do not preserve ordering
# Ordering determined by tree structure and in-order traversal of tree
class Rope < SplayTreeVertex

  def split(i)
    node = find_by_order(i)
    node.split_left
  end


  def cut(i,j,k)
    l = self
    arr = []
    [i,j,k].sort.reverse.each do |n|
      r,l = l.split(n)
      arr << r
    end
    arr << l
    arr.reverse
  end

  #
  # ^ \ \ \

  def self.join(fragments)
    v = fragments.first
    fragments[1..-1].each do |w|
      v = w.merge_left(v)
    end
    v
  end


  attr_reader :string, :tree

  private

  attr_writer :string, :tree

end

n = Rope.generate_random_tree(1000)

order1 = n.to_inorder

a = n.cut(50,150,350)

order2 = []
a.each do |v|
  order2 = order2+v.to_inorder
end

nn = Rope.join(a)
order3 = nn.to_inorder






class BSTString < Rope

  def initialize(string)
    @string = string
    super(string.size)
    i = 0
    @tree.in_order do |v|
      v.key = string[i]
      i += 1
    end
  end

  def to_s
    to_inorder.join
  end

end
