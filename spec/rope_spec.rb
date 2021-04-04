require 'rspec'
require 'pry'

require_relative '../rope.rb'


describe Rope do

    l = 1000

    it 'should pass a stress test for splitting and re-joining rope' do
      tree_size = 1000
      sample_space_size = 2000

      l.times do

        size = rand(tree_size)+3

        node = Rope.generate_random_tree(size,sample_space_size)
        order1 = node.to_inorder
        set = (0...size).to_a.shuffle!
        a,b,c = [set.pop,set.pop,set.pop].sort
        # pp size
        # pp [a,b,c]
        arr = node.cut(a,b,c)

        order2 = []
        arr.each do |v|
          if v
            order = v.to_inorder
          else
            order = []
          end
          order2 = order2+order
        end

        nn = Rope.join(arr)
        order3 = nn.to_inorder

        expect(order2).to eq order1
        expect(order3).to eq order1
      end

    end

end
