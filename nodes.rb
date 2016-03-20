
class Node

	attr_reader :x, :y, :children, :parent, :content, :angle
	attr_writer :x, :y, :parent, :angle

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

	def calculatePositions(nodeDistance_, level_=0)
		print "." * level_ + @content
		#print " a: "
		#print (Math::PI/@angle)*180
		print "\n"

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
				child.calculatePositions(nodeDistance_, level_+1)
				i += 1
			end
		end

		#puts @content, "x: #{@x} y: #{@y}"
		#puts "parent a: #{@angle}" if(@parent)
	end


	def generateTree(child_min_=1, child_max_=4, level_max_=2, level_=0)
		for i in 1..(rand(child_min_..child_max_).to_i)
			newchild =  Node.new("#{level_}#{i}")
			newchild.parent = self
			if(level_<level_max_)
				newchild.generateTree(child_min_, child_max_, level_max_, level_+1)
			end
			@children.push(newchild)
		end
	end
end
