require 'pry'

class Vertex
  def initialize(key=0, sum=nil, left=nil, right=nil, parent=nil)
    @key, @sum, @left, @right, @parent =  key, sum, left, right, parent
    @sum = @key if @key
  end
  attr_accessor :sum, :left, :right, :parent
  attr_reader :key

  # Basic Operations

  def find(k)
    if k > key
      if right
        right.find(k)
      else
        return self
      end
    elsif k < key
      if left
        left.find(k)
      else
        return self
      end
    else
      return self
    end
  end


  def insert(k)
    find(k).add_leaf(k)
  end


  def delete
    raise "must not be root" unless parent
    if !right
      if left
        promote(left)
      else
        parent_clear
      end
      clear
    else
      x = next_node
      self.key = x.key
      if x.right
        x.promote(x.right)
      else
        x.parent_clear
      end
      x.clear
    end
  end

  def promote(other)
    parent_clear
    parent.add_vertex(other)
  end

  def replace(other)

  end

  def clear
    self.left = nil
    self.right = nil
    # parent_clear
    self.parent = nil
  end

  def parent_clear
    if parent.right == self
      parent.right = nil
    else
      parent.left = nil
    end
  end

  #
  # Tree Relations
  #

  def root
    return self unless parent
    parent.root
  end

  def next_node
    if right
      return right.left_descendent
    else
      return right_ancestor
    end
  end

  def left_descendent
    if left
      return left.left_descendent
    else
      return self
    end
  end

  def right_ancestor
    return self unless parent
    if key < parent.key
      return parent
    else
      return parent.right_ancestor
    end
  end

  def range_search(a,b)
    l = []
    v = find(a)
    while v.key <= b do
      l << v if v.key >= a
      v = v.next_node
    end
    l
  end


  #
  #
  # Tree Traversals
  #

  def in_order(&block)
    left.in_order(&block) if left
    yield self
    right.in_order(&block) if right
  end

  def pre_order(&block)
    yield self
    left.pre_order(&block) if left
    right.pre_order(&block) if right
  end

  def post_order(&block)
    left.post_order(&block) if left
    right.post_order(&block) if right
    yield self
  end

  def to_inorder
    [].tap{|a| in_order{|x| a << x.key }}
  end

  def to_preorder
    [].tap{|a| pre_order{|x| a << x.key }}
  end

  def to_postorder
    [].tap{|a| post_order{|x| a << x.key }}
  end
  #
  #
  # Diagnostic Tests
  #

  def is_bst?
    last_key = -Float::INFINITY
    in_order do |vertex|
      key = vertex.key
      return false if last_key >= key
      last_key = key
    end
    true
  end

  def size
    sum = 0
    in_order do |v|
      sum += 1
    end
    sum
  end


  def size_memoized
    return @size if @size
    if leaf?
      @size = 1
      return @size
    end
    @size = [child_size(left),child_size(right)].sum + 1
    @size
  end

  def size_memo_clear
    in_order do |v|
      v.instance_variable_set :@size, nil
    end
  end

  def child_size(child)
    if child
      child.size_memoized
    else
      0
    end
  end


  def height
    return 1 if leaf?
    [child_height(left),child_height(right)].max + 1
  end

  def child_height(child)
    if child
      child.height
    else
      0
    end
  end


  def balance
     return 0 if leaf?
     right_size = child_size(right).to_f
     left_size = child_size(left).to_f
     (right_size - left_size)/[right_size,left_size].max
  end

  def average_balance
    sum = 0
    i = 0
    in_order do |v|
      sum += v.balance
      i += 1
    end
    size_memo_clear
    sum/i
  end

  def leaf?
    !right && !left
  end


  #
  #
  # IO
  #

  def to_a

    indicies = {}
    each_with_index do |v,i|
      indicies[v] = i
    end

    arr = []
    each do |v|
      ileft = indicies[v.left] || -1
      iright = indicies[v.right] || -1
      arr << [v.key,ileft,iright]
    end
    arr

  end


  def each_with_index
    i = 0
    each do |v|
      yield v,i
      i += 1
    end
  end

  def each
    enumerate = ->(v){
      yield v
      enumerate.(v.right) if v.right
      enumerate.(v.left) if v.left
    }
    enumerate.(self)
  end

  # protected

  def self.from_a(data)
    key = data[0][0]
    v = self.new(key,key)
    constructor = ->(v,i){
      # return nil if i == -1
      ileft = data[i][1]
      iright = data[i][2]
      if ileft != -1
        v.add_leaf_raw(data[ileft][0],:left)
        constructor.(v.left,ileft)
      end
      if iright != -1
        v.add_leaf_raw(data[iright][0],:right)
        constructor.(v.right,iright)
      end
    }
    constructor.(v,0)
    v
  end


  def add_vertex(v,strict: true)
    if v.key > key
      raise "right leaf already exists" if right && strict
      add_vertex_raw(v,:right)
    elsif v.key < key
      raise "left leaf already exists" if left && strict
      add_vertex_raw(v,:left)
    else
      raise "node with key #{v.key} already exists"
    end
  end

  def add_leaf(k)
    v = self.class.new(k)
    add_vertex(v)
  end

  # def add_leaf(k)
  #   if k > key
  #     raise "right leaf already exists" if right
  #     add_leaf_raw(k,:right)
  #   elsif k < key
  #     raise "left leaf already exists" if left
  #     add_leaf_raw(k,:left)
  #   else
  #     raise "node with key #{key} already exists"
  #   end
  # end

  def add_leaf_raw(k,side)
    v = self.class.new(k,k,nil,nil,self)
    add_vertex_raw(v,side)
  end

  def add_vertex_raw(v,side)
    v.parent = self
    case side
    when :left
      self.left = v
    when :right
      self.right = v
    end
  end

  private

  attr_writer :key


end


# myinput1 = [
#   [4,1,2],
#   [2,3,4],
#   [5,-1,-1],
#   [1,-1,-1],
#   [3,-1,-1]
# ]
#
# v= Vertex.from_a(myinput1)
#
# binding.pry
