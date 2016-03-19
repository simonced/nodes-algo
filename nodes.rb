
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

	def calculatePositions(nodeDistance_)
		# turn of the children
		if @children.length>0 
			i = 0
			nodes_count = @children.length
			nodes_count += 1 if(@parent)
			angle = (Math::PI * 2) / nodes_count
			@children.each do |child|
				# each child location in a circular manner
				child.angle = angle * i
				# if we have a parent
				child.angle -= Math::PI/2-@angle if(@parent)
				# child position
				child.x = @x + nodeDistance_ * Math::cos(child.angle)
				child.y = @y + nodeDistance_ * Math::sin(child.angle)
				# children of child
				child.calculatePositions(nodeDistance_)
				i += 1
			end
		end

		puts @content, "x: #{@x} y: #{@y}"
		puts "parent a: #{@angle}" if(@parent)

	end

end
