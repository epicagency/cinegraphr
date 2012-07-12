class CMGMaskController < UIViewController
  MASKSTATE_CLEAR = 0
  MASKSTATE_DRAW = 1

  attr_accessor :state

  def state=(state)
    @state = state
    @mask_view.draw_clear = (state == MASKSTATE_CLEAR)
  end

  def apply(image)
    @mask_view.render_mask(image)
  end

  # {{{ Touch handling
  def touchesBegan(touches, withEvent:event)
    return unless @enabled
    @last_ts = Time.new
    @points.removeAllObjects()
    @points << touches.anyObject.locationInView(@mask_view)
    @mask_view.setNeedsDisplay()
  end

  def touchesMoved(touches, withEvent: event)
    return unless @enabled
    @points << touches.anyObject.locationInView(@mask_view)
    @mask_view.setNeedsDisplay()
  end

  def touchesEnded(touches, withEvent: event)
    return unless @enabled
    d = Time.new
    diff_s = d.to_i - @last_ts.to_i
    diff_u = d.usec - @last_ts.usec
    if diff_s > 0 or diff_u > 200000
      @points << touches.anyObject.locationInView(@mask_view)
      #new_points = self.douglas_peucker(@points, epsilon: 2)
      #new_points = self.catmull_rom_spline(new_points, segments: 4)
      #@points.removeAllObjects()
      #@points.addObjectsFromArray(new_points)
      @mask_view.flatten()
      @points.removeAllObjects()
      @mask_view.setNeedsDisplay()
    else
      @points.removeAllObjects()
      @mask_view.setNeedsDisplay()
      self.parentViewController.current_manager.toggle_chrome
    end
  end
  # }}}

  # {{{ View management
  def hide
    @mask_view.hidden = true
    @enabled = false
  end

  def show
    @enabled = true
    @mask_view.hidden = false
  end

  def reset
    @mask_view.reset()
    @points = @mask_view.points
    self.state = MASKSTATE_DRAW
  end

  def init
    super
    @enabled = true
    @state = MASKSTATE_DRAW
    self
  end

  def loadView
    self.view = @mask_view = CMGMaskView.alloc.initWithFrame(CGRectZero)
    @mask_view.clipsToBounds = true
    @mask_view.alpha = 0.75
    @points = @mask_view.points
  end
  # }}}

  # {{{ Line smoothing
  def douglas_peucker(points, epsilon:epsilon)
    count = points.count
    return points if count < 3

    # Find the point with the maximum distance
    dmax = 0
    index = 0
    first = points.first
    last = points.last
    points.each_with_index {|point,i|
      next if i == 0
      d = perpendicular_distance(point, start: first, finish: last)
      if d > dmax
        index = i
        dmax = d
      end
    }
    # If max distance is greater than epsilon, recursively simplify
    results = nil
    if dmax > epsilon
      res1 = self.douglas_peucker(points[0..index+1], epsilon: epsilon)
      res2 = self.douglas_peucker(points[index..count-index], epsilon: epsilon)
      res1.removeLastObject
      res1.addObjectsFromArray(res2)
      results = res1
    else
      results = points
    end
    return results
  end

  def perpendicular_distance(point, start: start, finish: finish)
    v1 = CGPointMake(finish.x - start.x, finish.y - start.y)
    v2 = CGPointMake(point.x - start.x, point.y - start.y)
    lenV1 = Math.sqrt(v1.x * v1.x + v1.y * v1.y)
    lenV2 = Math.sqrt(v2.x * v2.x + v2.y * v2.y)
    pre = (v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2)
    pre = 1.0 if pre > 1.0
    angle = Math.acos(pre)
    return Math.sin(angle) * lenV2
  end

  def catmull_rom_spline(points, segments: segments)
    count = points.count
    return if count < 4

    b = []
    # precompute interpolation parameters
    t = 0.0
    dt = 1.0 / segments.to_f
    segments.times {|i|
      t += dt
      tt = t*t
      ttt = tt*t
      b[i] = []
      b[i][0] = 0.5 * (-ttt + 2.0 * tt - t);
      b[i][1] = 0.5 * (3.0 * ttt -5.0 * tt +2.0);
      b[i][2] = 0.5 * (-3.0 * ttt + 4.0 * tt + t);
      b[i][3] = 0.5 * (ttt - tt);
    }
    results = []
    results << points.first

    i = 0
    pointI = points[i]
    pointIp1 = points[i+1]
    pointIp2 = points[i+2]
    (segments-2).times {|k|
      j = k + 1
      px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x
      py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y
      results << CGPointMake(px, py)
    }
    (segments-3).times {|k|
      i = k+1
      # the first interpolated point is always the original control point
      results << points[i]
      pointIm1 = points[i - 1]
      pointI = points[i]
      pointIp1 = points[i+1]
      pointIp2 = points[i+2]
      (segments-1).times {|l|
        j = l+1
        px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x
        py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y
        results << CGPointMake(px, py)
      }
    }
    i = count-2 # second to last control point
    results << points[i]
    pointIm1 = points[i-1]
    pointI = points[i]
    pointIp1 = points[i+1]
    (segments-1).times {|k|
      j = k+1
      px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
      py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
      results << CGPointMake(px, py)
    }
    # the very last interpolated point is the last control point
    results << points.last
    return results
  end
  # }}}
end
