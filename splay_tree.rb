
require_relative './vertex.rb'

class SplayTreeVertex < Vertex

  attr_accessor :size

  def initialize(*args)
    super(*args)
    update_size
  end

  #
  # Splay specific operations
  #

  def update
    # return unless self
    update_size
    left.parent = self if left
    right.parent = self if right
  end

  def update_size
    self.size = 1 + child_size(left) + child_size(right)
  end

  def child_size(child)
    if child
      child.size || child.get_size
    else
      0
    end
  end


  def small_rotation

    return unless parent
    parent = self.parent
    grandparent = parent.parent

    if parent.left == self
      m = right
      self.right = parent
      parent.left = m
    else
      m = left
      self.left = parent
      parent.right = m
    end
    parent.update
    update
    self.parent = grandparent

    if grandparent
      if grandparent.left == parent
        grandparent.left = self
      else
        grandparent.right = self
      end
    end

  end


  def zig_zig
    return unless parent
    parent.small_rotation
    small_rotation
  end

  def zig_zag
    small_rotation
    small_rotation
  end

  def big_rotation
    return unless parent
    return unless parent.parent
    if parent.left == self and parent.parent.left == parent
      # Zig-zig
      zig_zig
    elsif parent.right == self and parent.parent.right == parent
      # Zig-zig
      zig_zig
    else
      # Zig-zag
      zig_zag
    end
  end

  # Makes splay of the given vertex and makes
  # it the new root.
  def splay
    while parent
      unless parent.parent
        small_rotation
        break
      end
      big_rotation
    end
    return self
  end


  #
  # Basic operations
  #

  def splay_find(k)
    n = find(k)
    n.splay
    return n
  end

  def splay_insert(k)
    insert(k)
    splay_find(k)
  end

  def splay_delete
    return self if leaf? && !parent
    next_node.splay
    splay
    l = left
    r = right
    return remove_root_largest unless right
    r.left = l
    l.parent = r
    r.parent = nil
    clear
    r
  end

  def remove_root_largest
    l = left
    l.parent = nil
    clear
    l
  end

  #
  # Split and Merge
  #

  def split
    splay
    return [self,nil] unless right
    r = right
    self.right = nil
    r.parent = nil
    update_size
    [self,r]
  end

  def merge(other)
    return self unless other
    raise "must not have a right child" if right
    self.right = other
    other.parent = self
    update_size
    self
  end

  #
  # Order Statistics
  #

  # Find nth element using size memo
  def find_by_order(n)
    raise "position must be positive" if n < 0
    raise "position must be smaller than size of tree" if n >= size
    if child_size(left) > n
      left.find_by_order(n)
    elsif child_size(left) < n
      right.find_by_order( n - 1 - child_size(left))
    elsif child_size(left) == n
      return self
    end
  end

  #
  # Diagnostic
  #

  def size_correct?
    in_order do |v|
      return false if v.get_size != v.size
    end
    return true
  end

end


v = SplayTreeVertex.new(1)
(2..1000).each do |i|
  v = v.splay_insert(i)
end

100.times do
  v = v.splay_find(rand(1000))
end

(0...1000).each do |i|
  w = v.find_by_order(i)
  pp w.key
end

# myinput1 = [
#   [4,1,2],
#   [2,3,4],
#   [5,-1,-1],
#   [1,-1,-1],
#   [3,-1,-1]
# ]
#
# v= SplayTreeVertex.from_a(myinput1)
# w = v.find(1)

binding.pry
