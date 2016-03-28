class Node

	attr_reader :x, :y, :children, :parent, :content, :angle
	attr_writer :x, :y, :parent, :angle

	# attributes for interractions
	attr_reader :over, :highlight
	attr_writer :over, :highlight

	def initialize(content_)
		@parent = nil
		@children = Array.new
		@content = content_
		@x, @y = 0, 0
		@angle = 0
	end

	def addChild(child_)
		child_.parent = self
		@children.push(child_)
	end

	# calculate children positions
	# @param int level_ child level
	# @param float nodeDistance_ node distance
	# @return Array flat list of all nodes
	def calculatePositions(nodeDistance_, level_=0)
		#print "." * level_ + @content
		#print "\n"
		# returning list of positions
		nodesList = Array.new
		# first, ourself
		nodesList << self

		# turn of the children
		if @children.length>0
			i = 0

			if @parent
				#child
				nodes_count = @children.length + 1
				childAngle = (Math::PI) / nodes_count
				childAngleOffset = (Math::PI/2 - @angle - childAngle)
			else
				#root
				nodes_count = @children.length
				childAngle = (Math::PI * 2) / nodes_count
				childAngleOffset = 0
			end

			# depending on the level. we increase the distance a little
			nodeDistance = nodeDistance_ + ((nodeDistance_/5) * level_)

			@children.each do |child|
				# each child location in a circular manner
				child.angle = childAngle*i - childAngleOffset
				# child position
				child.x = @x + nodeDistance * Math::cos(child.angle)
				child.y = @y + nodeDistance * Math::sin(child.angle)
				# children of child
				nodesList += child.calculatePositions(nodeDistance_, level_+1)
				i += 1
			end
		end

		#puts @content, "x: #{@x} y: #{@y}"
		#puts "parent a: #{@angle}" if(@parent)

		#return list we had
		nodesList
	end


	# calculate nodes positions, but with Graphviz
	def calculatePositionsDot()
		dotfile = "tmp.dot"
		command = "dot -Tplain -Ktwopi #{dotfile}"
		commandGraph = "dot -Tpng -Ktwopi -otmp.png #{dotfile}"
		struct = "digraph tmp {\n"
		struct << "ordering=out\n"
		#struct << "ranksep=3\n"
		struct << "pack=50\n"
		struct << "overlap=false\n"
		struct << "ratio=auto\n"
		struct << _getChildrenDot()
		struct << "}"
		#puts struct

		# Struct save
		File.open(dotfile, 'w') { |file| file.write(struct) }

		# command
		result = `#{command}`
		positions = {}
		scale = 20	# scale of nodes spreading
		#puts result
		result.each_line { |line|
			#puts line
			parts = line.match(/^node (.*?) (.*?) (.*?) /)
			if parts 
				 positions[parts[1]] = [parts[2].to_f*scale, parts[3].to_f*scale]
			end
		}
		puts positions.inspect
		#`#{commandGraph}`

		#last, we set posisionts
		_setChildrenDot(positions)

	end


	# recursive setting of positions calculated by Dot
	def _setChildrenDot(positions_)
		@x, @y = positions_[@content]
		@children.each{ |child|
			child._setChildrenDot(positions_)
		}
	end


	def _getChildrenDot
		struct = ""
		#only for root
		struct << "#{@content} [root=\"true\"]\n" if !@parent
		@children.each{ |n|
			#self and direct child
			line = "#{@content} -> #{n.content}\n"
			struct << line
			#then loop next level
			struct << n._getChildrenDot
		}
		struct
	end


	# random tree generation
	def generateTree(child_min_=1, child_max_=4, level_max_=2, level_=0)
		for i in 1..(rand(child_min_..child_max_).to_i)
			# TODO create incremented Ids instead of using Content
			newchild =  Node.new("#{@content}x#{i}")
			newchild.parent = self
			# not continuing a branch everytime
			if(level_<level_max_ && rand > 0.3)
				newchild.generateTree(child_min_, child_max_, level_max_, level_+1)
			end
			@children.push(newchild)
		end
	end


	# highlight the tree branch on mouse over
	def setHighlightTrunk(flag_)
		@highlight = flag_
		@parent.setHighlightTrunk(flag_) if @parent
	end

end
