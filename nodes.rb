
class Node

	attr_reader :x, :y, :children, :parent, :content
	attr_writer :x, :y, :parent

	def initialize(content_)
		@parent = nil
		@children = Array.new
		@content = content_
		@x, @y = 0, 0
	end

	def addChild(child_)
		child_.parent = self
		@children.push(child_)
	end

	def calculatePositions(nodeDistance_)
		# Depending on the level, we should have different node colors
		if @parent
			#TODO orient child differently
			#drawCircle(node_.x, node_.y, @nodeSize, @nodeColor)
		end

		# turn of the children
		if @children.length>0 
			i = 0
			nodes_count = @children.length
			nodes_count += 1 if(@parent)
			child_angle = (Math::PI * 2) / nodes_count
			@children.each do |child|
				# each child location in a circular manner
				child.x = @x + nodeDistance_ * Math::cos(child_angle * i)
				child.y = @y + nodeDistance_ * Math::sin(child_angle * i)
				# children of child
				child.calculatePositions(nodeDistance_)
				i += 1
			end
		end

		puts @content, "x: #{@x} y: #{@y}"
	end

end
