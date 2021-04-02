# require 'pry'


#
# A non-recursive array based representation of a binary search tree
#

class Tree

  attr_accessor :n, :key, :left, :right, :store, :stack, :stored

  def initialize
    @key, @left, @right, @stack = [],[],[],[]
    @store = {}
  end


  def read(n,line)
      key[n] = line[0]
      left[n] = line[1]
      right[n] = line[2]
  end


  def read_set(set)
    set.each_with_index do |line,n|
      self.read(n,line)
    end
  end



  def x_order
    init_iter
    stack << 0

    while !stack.empty?

      current = stack.last

      store_current(current,:pre)

      # simulated left recursion
      if left[current] != -1
        stack << left[current]
        left[current] = -1
        next
      end

      store_current(current,:in)

      # simulated right recursion
      if right[current] != -1
        stack << right[current]
        right[current] = -1
        next
      end

      store_current(current,:post)

      stack.pop

    end

    store.map{|k,v| [k,v.map{|i| key[i]}]}.to_h

  end



  def x_order_lazy(type)

    init_iter_lazy
    stack << 0

    while !stack.empty?

      current = stack.last

      store_current_lazy(current){|k| yield k} if type == :pre

      # simulated left recursion
      if left[current] != -1
        stack << left[current]
        left[current] = -1
        next
      end

      store_current_lazy(current){|k| yield k} if type == :in

      # simulated right recursion
      if right[current] != -1
        stack << right[current]
        right[current] = -1
        next
      end

      store_current_lazy(current){|k| yield k} if type == :post

      stack.pop

    end



  end


  def x_order_recursive
    out = {pre: [], in: [], post: []}
    f = ->(i){
      return if i == -1
      out[:pre] << key[i]
      f.(left[i])
      out[:in] << key[i]
      f.(right[i])
      out[:post] << key[i]
    }
    f.(0)
    out
  end

  def is_bst?(data)
    # return true if data == []
    last_key = -Float::INFINITY
    self.x_order_lazy(:in) do |key|
      return false if last_key >= key
      last_key = key
    end
    true
  end


  private


  def init_iter
    a = Array.new(key.size,false)
    self.stored = {pre:a.clone, in:a.clone, post:a.clone}
    self.store = {pre:[], in:[], post:[]}
  end

  def store_current(current,type)
    substore = store[type]
    substored = stored[type]
    substore << current unless substored[current]
    substored[current] = true
  end

  def init_iter_lazy
    self.stored = Array.new(key.size,false)
    self.store = []
  end

  def store_current_lazy(current)
    key = self.key[current]
    yield key unless stored[current]
    stored[current] = true
  end

end


def is_bst?(data)
  return true if data == []
  mytree = TreeOrders.new
  mytree.read_set(data)
  last_key = -Float::INFINITY
  mytree.x_order_lazy(:in) do |key|
    return false if last_key >= key
    last_key = key
  end
  true
end


# myinput1 = [
#   [4,1,2],
#   [2,3,4],
#   [5,-1,-1],
#   [1,-1,-1],
#   [3,-1,-1]
# ]
#
# myinput2 = [
# [4, 1, 2],
# [2, 3, 4],
# [6, 5, 6],
# [1, -1, -1],
# [3, -1, -1],
# [5, -1, -1],
# [7, -1, -1]
# ]
#
# myinput3=[
# [4, 1, -1],
# [2, 2, 3],
# [1, -1, -1],
# [5, -1, -1],
# ]

# mytree = TreeOrders.new
# mytree.read_set(myinput1)

# binding.pry
