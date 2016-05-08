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
		@displayLabels = false
		# shift display values for panning and centering
		@panX = self.width/2
		@panY = self.height/2
		@zoom = 1

		# gradation to understand level of nodes
		# gradient generator found at: http://www.perbang.dk/rgbgradient/
		@nodeColors = Array[
			Gosu::Color.new(0xff_4f24ff),
			Gosu::Color.new(0xff_4a5ac9),
			Gosu::Color.new(0xff_459194),
			Gosu::Color.new(0xff_40c85e),
			Gosu::Color.new(0xff_3bff29)
		]
		@nodeDistance = 50
		@nodeSize = 10
		@highlight = nil	# currently highlighted nodes
		@over = nil			# currenlty over node

		# faking discussion
		@theme = Node.new("n0")
		# random tree
		#@theme.generateTree(2, 2, 1)	# simple setup
		#@theme.generateTree(2, 3, 3)
		#@theme.generateTree(0, 6, 3)
		#@theme.generateTree(2, 4, 4)	# harder setup
		@theme.generateTree(5, 10, 10)	# even harder setup

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
		#@nodes = @theme.calculatePositions(@nodeDistance)
		@nodes = @theme.calculatePositionsDot()
		#puts "Nodes: #{@nodes.length}"
		STDOUT.flush
		
		#close
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


	# adding zoom support
	def shiftToCenter(x_, y_)
		new_x = x_ + @panX
		new_x -= @panXstart - mouse_x if @panXstart
		new_y = y_ + @panY
		new_y -= @panYstart - mouse_y if @panYstart
		# zoom test
		new_x += new_x * @zoom
		new_y += new_y * @zoom
		#recenter after zoom
		new_x -= self.width/2*@zoom
		new_y -= self.height/2*@zoom
		#return
		Array[ new_x , new_y]
	end


	# drawing a Node
	def drawNode(node_, level_=0)
		z = 1
		z = 2 if node_.highlight
		# local values for display only
		node_x, node_y = shiftToCenter(node_.x, node_.y)

		if node_.over
			node_color = Gosu::Color::WHITE
		else
			if level_<LevelMax
				node_color = @nodeColors[level_]
			else
				node_color = @nodeColors[LevelMax]
			end
		end

		#node_size = @nodeSize
		drawCircle(node_x, node_y, @nodeSize, node_color, z)

		# draw node text (content)
		@font.draw(node_.content, node_x, node_y, 1) if @displayLabels

		# draw link with parent if any
		if node_.parent
			parent_x, parent_y = shiftToCenter(node_.parent.x, node_.parent.y)
			if node_.highlight
				linkColor1 = @linkColor1
				linkColor2 = @linkColor2
			else
				linkColor1 = linkColor2 = Gosu::Color::GRAY
			end
			draw_line(parent_x, parent_y, linkColor1, node_x, node_y, linkColor2, z)
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
				@over = @highlight = node
				puts "over!"
				STDOUT.flush
			end
		}

		# if no over, we clear highlight of previous branch
		if !is_over && @highlight
			@highlight.setHighlightTrunk(false)
			@over = @highlight = nil
		end
	end


	# mouse related!
	# ==============
	def needs_cursor?
		true
	end


	# inputs, keyboard and mouse
	# ==========================
	def button_down(id)
		#puts id

		# closing the APP
		if id == Gosu::KbEscape
			close
		end

		# left mouse click
		if id == Gosu::MsLeft
			if @over
				# click on a node
				newNode = Node.new("#{@over.content}/#{@over.children.count+1}")
				@over.addChild(newNode)
				@over.calculatePositions(@nodeDistance)
				@nodes << newNode
			else
				# click anywhere to pan
				@panXstart, @panYstart = mouse_x, mouse_y
			end
		end

		if id == Gosu::MsWheelDown
			#puts "Zoom in"
			@zoom = @zoom - 0.1 if @zoom>0.1
		end

		if id == Gosu::MsWheelUp
			#puts "Zoom out"
			@zoom = @zoom + 0.1
		end

		# display of labels switch
		if id == Gosu::KbL
			@displayLabels = !@displayLabels
		end
	end


	def button_up(id)

		# mouse
		if id == Gosu::MsLeft
			# stop panning
			@panX -= @panXstart - mouse_x if @panXstart
			@panY -= @panYstart - mouse_y if @panYstart
			@panXstart = @panYstart = nil
		end
	end


	# rendering
	# =========
	def draw
		#Display of all graph
		drawNode(@theme)

		#Display of the first branch
		#drawNode(@theme.children[0])
	end

end # end class

window = MyWindow.new
window.show

# vim: foldmethod=marker
