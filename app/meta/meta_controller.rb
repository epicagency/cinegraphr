class CMGMetaController < UIViewController
  attr_reader :current
  attr_accessor :delegate

  def meta_done(sender)
    unless @delegate.nil?
      @delegate.meta_controller_did_finish_successfully(self)
    end
  end

  def gif_generation_done(path)
    self.view.generateactivity.stopAnimating
    self.view.ok_button.enabled = true
    @current['path'] = path
  end

  # {{{ Location handling
  def locationManager(manager, didUpdateToLocation:newLocation, fromLocation:oldLocation)
    @cl.stopUpdatingLocation
    self.reverse_geocode(newLocation)
  end

  def locationManager(manager, didChangeAuthorizationStatus:status)
    # TODO: handle authorization status
  end

  def locationManager(manager, didFailWithError: error)
    alert = UIAlertView.new
    alert.title = 'Error'
    alert.message = error.localizedDescription
    alert.addButtonWithTitle('OK')
    alert.show
  end

  def reverse_geocode(location)
    @current['location'] = {
      'lat' => location.coordinate.latitude,
      'lng' => location.coordinate.longitude
    }
    completed = Proc.new {|placemark, error|
      self.view.geoactivity.stopAnimating
      if not placemark.nil? and placemark.size > 0
        pl = placemark[0]
        self.view.geotag_label.text = "Geotagged: #{pl.locality}, #{pl.country}"
        @current['tag'] = "#{pl.locality}, #{pl.country}"
      else
        self.view.geotag_label.text = "Geotagged: (error)"
      end
    }

    @clg = CLGeocoder.alloc.init
    @clg.reverseGeocodeLocation(location, completionHandler: completed)
  end

  def toggle_geocode

    if self.view.geotag.isOn
      self.view.geoactivity.startAnimating
      @cl = CLLocationManager.alloc.init
      @cl.delegate = self
      @cl.desiredAccuracy = KCLLocationAccuracyHundredMeters
      @cl.purpose = "Tagging your Cinemagraphs"
      if !@cl.location.nil? and @cl.location.horizontalAccuracy <= 100
        self.reverse_geocode(@cl.location)
      else
        @cl.startUpdatingLocation
      end
    else
      self.view.geoactivity.stopAnimating
      self.view.geotag_label.text = "Geotagged"
    end
  end
  # }}}

  # {{{ init & load
  def init
    super

    @current = {
      'caption' => '',
      'tag' => '',
      'path' => '',
      'timestamp' => NSDate.date
    }

    self
  end

  def loadView
    mv = CMGMetaView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    mv.geotag.addTarget(self, action: "toggle_geocode", forControlEvents:UIControlEventValueChanged)
    mv.ok_button.enabled = false
    mv.ok_button.addTarget(self, action: "meta_done:", forControlEvents:UIControlEventValueChanged)
    mv.caption.becomeFirstResponder
    mv.generateactivity.startAnimating
    self.view = mv
  end
  # }}}

end
