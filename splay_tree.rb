
require_relative './vertex.rb'

class SplayTreeVertex < Vertex

  #
  # Splay specific operations
  #

  def update
    # return unless self
    update_sum
    left.parent = self if left
    right.parent = self if right
  end

  def update_sum
    self.sum = key + child_sum(left) + child_sum(right)
  end

  def child_sum(child)
    if child
      child.sum
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
  # split and merge
  #

  def split
    splay
    return [self,nil] unless right
    r = right
    self.right = nil
    r.parent = nil
    [self,r]
  end

  def merge(other)
    return self unless other
    raise "must not have a right child" if right
    self.right = other
    other.parent = self
    self
  end


end


v = SplayTreeVertex.new(1)
(2..1000).each do |i|
  v = v.splay_insert(i)
end

10000.times do
  v = v.splay_find(rand(1000))
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
