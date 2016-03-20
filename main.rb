require 'rubygems'
require 'gosu'
require './nodes.rb'

class MyWindow < Gosu::Window


	def initialize
		super 640, 480, false
		self.caption = 'Hello World!'

		@linkColor1 = Gosu::Color::RED
		@linkColor2 = Gosu::Color::YELLOW
		@font = Gosu::Font.new(16)

		# gradation to understand level of nodes
		@nodeColors = Array[
			Gosu::Color.new(0xff_3858d9),
			Gosu::Color.new(0xff_714cd0),
			Gosu::Color.new(0xff_ab41c7),
			Gosu::Color.new(0xff_d938c1),
			Gosu::Color::GREEN
		]
		@nodeDistance = 50;
		@nodeSize = 10;

		# faking discussion
		@theme = Node.new("0")
		# random tree
		@theme.generateTree(2, 3, 3)
		#@theme.generateTree(2, 2, 1)

		#child = Node.new("bbb1")
		#child.addChild( Node.new("ccc1"))
		#child.addChild( Node.new("ccc2"))
		#child.addChild( Node.new("ccc3"))
		#@theme.addChild(child)
        #
		#child = Node.new("bbb1")
		#child.addChild( Node.new("ddd1"))
		#child.addChild( Node.new("ddd2"))
		#child.addChild( Node.new("ccc3"))
		#@theme.addChild(child.dup)
        #
		#child = Node.new("bbb1")
		#child.addChild( Node.new("eee1"))
		#child.addChild( Node.new("eee2"))
		#child.addChild( Node.new("ccc3"))
		#@theme.addChild(child.dup)

		# pre-calculate all nodes positions
		@theme.calculatePositions(@nodeDistance)
		#close
		STDOUT.flush
	end


	# My custom methods
	def drawCircle(x_, y_, radius_, col_)
		steps = 10
		base_radians = Math::PI * 2 / steps
		for i in 0..steps
			x = x_ + radius_ * Math::cos(base_radians * i);
			y = y_ + radius_ * Math::sin(base_radians * i);
			x_n = x_ + radius_ * Math::cos(base_radians * (i+1));
			y_n = y_ + radius_ * Math::sin(base_radians * (i+1));

			draw_line(x, y, col_, x_n, y_n, col_)
		end
	end


	# drawing a Node
	def drawNode(node_, level_=0)
		# local values for display only
		node_x, node_y = shiftToCenter(node_.x, node_.y)
		node_size = @nodeSize-(level_*2)
		#node_size = @nodeSize
		drawCircle(node_x, node_y, node_size, @nodeColors[level_])
		@font.draw(node_.content, node_x, node_y, 1)

		# turn of the children
		if node_.children.length>0 
			node_.children.each do |child|
				child_x, child_y = shiftToCenter(child.x, child.y)
				draw_line(node_x, node_y, @linkColor1, child_x, child_y, @linkColor2)
				drawNode(child, level_+1)
			end
		end
	end

	def shiftToCenter(x_, y_)
		tmp = Array[x_ + (self.width / 2), y_ + (self.height / 2)]
	end

	#GOSU methods

	def update
	end


	def button_down(id)
		if id == Gosu::KbEscape
			close
		end
	end


	def draw
		#Display of all graph
		#drawNode(@theme)
		#Display of the first branch
		drawNode(@theme.children[0])
	end
end

window = MyWindow.new
window.show
