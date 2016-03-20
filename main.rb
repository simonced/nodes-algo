require 'rubygems'
require 'gosu'
require './nodes.rb'

class MyWindow < Gosu::Window

	DisplayLabels = false
	LevelMax = 4

	def initialize
		super 640, 480, false
		self.caption = 'Hello World!'

		@linkColor1 = Gosu::Color::RED
		@linkColor2 = Gosu::Color::YELLOW
		@font = Gosu::Font.new(16)

		# gradation to understand level of nodes
		# gradient generator found at: http://www.perbang.dk/rgbgradient/
		@nodeColors = Array[
			Gosu::Color.new(0xff_4f24ff),
			Gosu::Color.new(0xff_4a5ac9),
			Gosu::Color.new(0xff_459194),
			Gosu::Color.new(0xff_40c85e),
			Gosu::Color.new(0xff_3bff29)
		]
		@nodeDistance = 50;
		@nodeSize = 10;

		# faking discussion
		@theme = Node.new("0")
		# random tree
		#@theme.generateTree(2, 2, 1)
		#@theme.generateTree(2, 3, 3)
		@theme.generateTree(0, 6, 3)
		#@theme.generateTree(2, 4, 4)

		# tests >>>
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
		# <<<

		# pre-calculate all nodes positions
		@nodes = @theme.calculatePositions(@nodeDistance)
		#close
		puts "Nodes: #{@nodes.length}"
		STDOUT.flush

	end


	# My custom methods
	def drawCircle(x_, y_, radius_, col_, z_=1)
		# >>>
		steps = 10
		base_radians = Math::PI * 2 / steps
		for i in 0..steps
			x = x_ + radius_ * Math::cos(base_radians * i);
			y = y_ + radius_ * Math::sin(base_radians * i);
			x_n = x_ + radius_ * Math::cos(base_radians * (i+1));
			y_n = y_ + radius_ * Math::sin(base_radians * (i+1));

			draw_line(x, y, col_, x_n, y_n, col_, z_)
		end
		# <<<
	end # end drawCircle


	def shiftToCenter(x_, y_)
		tmp = Array[x_ + (self.width / 2), y_ + (self.height / 2)]
	end


	# drawing a Node
	def drawNode(node_, level_=0)
		z = 1
		z = 2 if node_.highlight
		# local values for display only
		node_x, node_y = shiftToCenter(node_.x, node_.y)

		if node_.over
			node_size = @nodeSize + (@nodeSize/10)
			node_color = Gosu::Color::WHITE
		else
			if level_<LevelMax
				node_size = @nodeSize-(level_/LevelMax)
				node_color = @nodeColors[level_]
			else
				node_size = @nodeSize-(level_*LevelMax)
				node_color = @nodeColors[LevelMax]
			end
		end

		#node_size = @nodeSize
		drawCircle(node_x, node_y, node_size, node_color, z)

		# draw node text (content)
		@font.draw(node_.content, node_x, node_y, 1) if DisplayLabels

		# draw link with parent if any
		if node_.parent
			parent_x, parent_y = shiftToCenter(node_.parent.x, node_.parent.y)
			if node_.highlight
				linkColor1 = @linkColor1
				linkColor2 = @linkColor2
			else
				linkColor1 = linkColor2 = Gosu::Color::GRAY
			end
			draw_line(node_x, node_y, linkColor1, parent_x, parent_y, linkColor2, z)
		end

		# turn of the children
		if node_.children.length>0 
			node_.children.each do |child|
				drawNode(child, level_+1)
			end
		end
	end

	#======================================================================
	#GOSU methods

	def update
		is_over = false
		# searching for node under pointer
		@nodes.each{ |node|
			node_x, node_y = shiftToCenter(node.x, node.y)
			# intersection of pointer on node?
			over = Gosu::distance(mouse_x, mouse_y, node_x, node_y)<=10
			node.over = over
			# then, we set the tree back to root in highlight mode
			# clear previous node highlight
			if @highlight && @highlight != node && over
				@highlight.setHighlightTrunk(false)
			end
			if over
				is_over = true
				node.setHighlightTrunk(true)
				@highlight = node
			end
		}

		# if no over, we clear highlight of previous branch
		if !is_over && @highlight
			@highlight.setHighlightTrunk(false)
			@highlight = nil
		end
	end


	def needs_cursor?
		true
	end


	def button_down(id)
		if id == Gosu::KbEscape
			close
		end
	end


	def draw
		#Display of all graph
		drawNode(@theme)

		#Display of the first branch
		#drawNode(@theme.children[0])
	end

end # end class

window = MyWindow.new
window.show
