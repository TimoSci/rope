require 'rspec'
require 'pry'
require 'benchmark'
require_relative '../vertex.rb'
  # load Dir["./*.rb"].select{|f| f !~ /spec/}[0]
# class Wrapper
#   # load '.rb'
#   load Dir["./*.rb"].select{|f| f !~ /spec/}[0]
#
# end

# require Dir["./*.rb"].select{|f| f !~ /spec/}[0]
# class Wrapper
#   # load '.rb'
#   load Dir["./*.rb"].select{|f| f !~ /spec/}[0]
# end

EXAMPLE1=[
  [4,1,2],
  [2,3,4],
  [5,-1,-1],
  [1,-1,-1],
  [3,-1,-1]
]

describe Vertex do

  v = Vertex.new(1)

  it 'should be a binary search tree after trivial insertions' do

    expect(v.is_bst?).to be true
    v.insert(0)
    expect(v.is_bst?).to be true
    v.insert(2)
    expect(v.is_bst?).to be true

  end

  it 'should do trivial finds correctly' do

    (0..2).each do |i|
      expect(v.find(i).key).to eq i
    end

      expect(v.find(3).key).to eq 2
      expect(v.find(-1).key).to eq 0

  end

  it 'should be a binary search tree after trivial deletions' do

    (v.find(0).delete)
    expect(v.is_bst?).to be true
    (v.find(2).delete)
    expect(v.is_bst?).to be true

  end




  it 'should be a binary search tree for known examples' do
    myinput = EXAMPLE1

    vertex = Vertex.from_a(myinput)
    expect(vertex.is_bst?).to be true

      myinput = [
        [0 ,7, 2],
        [10 ,-1, -1],
        [20, -1, 6],
        [30, 8, 9],
        [40, 3, -1],
        [50, -1, -1],
        [60, 1, -1],
        [70, 5, 4],
        [80, -1, -1],
        [90, -1, -1]
      ]

      vertex = Vertex.from_a(myinput)
      expect(vertex.is_bst?).to be false

  end


  it 'should correctly delete a leaf node' do
    myinput = EXAMPLE1
    vertex = Vertex.from_a(myinput)

    vertex.find(3).delete
    expect(vertex.to_inorder).to eq [1,2,4,5]
  end


  it 'should correctly delete a node without a right child' do
    myinput = EXAMPLE1
    vertex = Vertex.from_a(myinput)

    vertex.insert(8)
    vertex.insert(6)
    vertex.find(8).delete
    expect(vertex.to_inorder).to eq [1,2,3,4,5,6]
    expect(vertex.is_bst?).to be true
  end

  it 'should correctly delete a node without a left child' do
    myinput = EXAMPLE1
    vertex = Vertex.from_a(myinput)

    vertex.insert(8)
    vertex.insert(6)
    vertex.find(5).delete
    expect(vertex.to_inorder).to eq [1,2,3,4,6,8]
    expect(vertex.is_bst?).to be true
  end

  it 'should correctly delete a node with right and left children' do
    myinput = EXAMPLE1
    vertex = Vertex.from_a(myinput)

    vertex.find(2).delete
    expect(vertex.to_inorder).to eq [1,3,4,5]
    expect(vertex.is_bst?).to be true
  end

  it 'should correctly delete a node with a right and left children and a next element' do
    myinput = EXAMPLE1
    vertex = Vertex.from_a(myinput)

    vertex.insert(10)
    vertex.insert(6)
    vertex.insert(20)
    vertex.insert(15)
    vertex.insert(11)

    vertex.find(10).delete
    expect(vertex.to_inorder).to eq [1,2,3,4,5,6,11,15,20]
    expect(vertex.is_bst?).to be true
  end

  it 'should correctly delete a node with a right and left children and a next element with right child' do
    myinput = EXAMPLE1
    vertex = Vertex.from_a(myinput)

    vertex.insert(10)
    vertex.insert(6)
    vertex.insert(20)
    vertex.insert(15)
    vertex.insert(11)
    vertex.insert(12)
    vertex.insert(13)

    vertex.find(10).delete
    expect(vertex.to_inorder).to eq [1,2,3,4,5,6,11,12,13,15,20]
    expect(vertex.is_bst?).to be true
  end


  it 'should pass a stress test' do
    m=1000
    10.times do
    set = (1..m).to_a
      set.shuffle!
      vertex = Vertex.new(set.pop)

      until set.empty?
        x = set.pop
        old_a = vertex.to_inorder
        vertex.insert(x)
        new_a = vertex.to_inorder
        expect(vertex.is_bst?).to be true
        # expect(new_size).to eq old_size+1
        diff = new_a - old_a
        expect(diff[0]).to eq x
        expect(vertex.find(x).key).to eq x
      end

      # pp vertex.to_inorder

      (m/2).times do
        v = vertex.find(rand(m))
        expected_diff = []
        old_a = vertex.to_inorder
        if v.parent
          expected_diff << v.key
          v.delete
        end
        new_a =  vertex.to_inorder
        expect(vertex.is_bst?).to be true
        diff = old_a - new_a
        expect(diff).to eq expected_diff
      end

    end
  end



end



class Helpers

class << self

def grow_tree(tree)
  key = tree.map{|n| n[0]}.max + 1
  new_i = tree.size
  (0...(tree.size)).each do |j|
    [1,2].each do |side|
      if tree[j][side] == -1
        new_tree = tree.clone.map(&:clone)
        new_tree[j][side] = new_i
        yield new_tree + [[key,-1,-1]]
      end
    end
  end
end

def grow_trees(set)
  set.each do |tree|
    grow_tree(tree){|t| yield t}
  end
end

def enumerate_trees(n=3)
  set = [[[1,-1,-1]]]
  n.times do
    new_set = []
    grow_trees(set){|t| new_set << t; yield t}
    set = new_set
  end
end

end

end
