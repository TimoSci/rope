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

  def cut_and_paste(i,j,k)
    raise "insert point must be smaller or larger than cut point" if k >= i && k <= j
    arr = cut(i,j,k)
    temp = arr[1]
    arr[1] = arr[2]
    arr[2] = temp
    self.class.join(arr)
  end



end




class BSTString

  def initialize(string)
    @tree = Rope.generate_random_tree(string.size)
    i = 0
    @tree.in_order do |v|
      v.key = string[i]
      i += 1
    end
  end

  attr_accessor :tree

  def to_s
    tree.to_inorder.join
  end

  def cut_and_paste(i,j,k)
    self.tree = tree.cut_and_paste(i,j,k)
    to_s
  end

end

# n = Rope.generate_random_tree(100)

s = BSTString.new("helloworld")

binding.pry
