module States
  module Generate

    # {{{ GIF generation
    def generate_gif
      o = [('a'..'z'), ('0'..'9')].map {|i| i.to_a }.flatten
      name = (0..32).map{ o[rand(o.length)] }.join + '.gif'

      path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).lastObject.stringByAppendingPathComponent(name)
      url = NSURL.alloc.initFileURLWithPath(path)

      # {{{ Setup reader
      @player_item.removeObserver(self, forKeyPath: "status", context: @player_context) unless @player_item.nil?
      NSNotificationCenter.defaultCenter.removeObserver(self, name:AVPlayerItemDidPlayToEndTimeNotification, object:@player_item)
      @player_item = nil
      @player = nil

      error_ptr = Pointer.new(:object)
      reader = AVAssetReader.assetReaderWithAsset(@asset, error:error_ptr)

      output_settings = {KCVPixelBufferPixelFormatTypeKey => KCVPixelFormatType_32BGRA}

      track = @asset.tracksWithMediaType(AVMediaTypeVideo).first
      reader_video_track_output = AVAssetReaderTrackOutput.assetReaderTrackOutputWithTrack(track, outputSettings:output_settings)

      reader.addOutput(reader_video_track_output)
      if reader.startReading == false
        NSLog("Error reading")
        return
      end
      # }}}

      # {{{ Setup CG
      frame_count = (((CMTimeGetSeconds(track.timeRange.duration) * track.nominalFrameRate) + 0.5) / 3).ceil
      dst_ref = CGImageDestinationCreateWithURL(url, KUTTypeGIF, frame_count, nil)
      frame_props = { KCGImagePropertyGIFDictionary => { KCGImagePropertyGIFDelayTime => 0.1 } }
      gif_props  = { KCGImagePropertyGIFDictionary => { KCGImagePropertyGIFLoopCount => 0 } }
      color_space = CGColorSpaceCreateDeviceRGB()
      # }}}

      current_frame = 0
      while reader.status == AVAssetReaderStatusReading
        sample_buffer_ref = reader_video_track_output.copyNextSampleBuffer
        unless sample_buffer_ref.nil? or current_frame % 3 != 0
          pixel_buffer = CMSampleBufferGetImageBuffer(sample_buffer_ref)

          CVPixelBufferLockBaseAddress(pixel_buffer,0)
          base_address = CVPixelBufferGetBaseAddress(pixel_buffer)
          bytes_per_row = CVPixelBufferGetBytesPerRow(pixel_buffer)
          width = CVPixelBufferGetWidth(pixel_buffer)
          height = CVPixelBufferGetHeight(pixel_buffer)

          CVPixelBufferUnlockBaseAddress(pixel_buffer,0)

          context_ref = CGBitmapContextCreate(base_address, width, height, 8, bytes_per_row, color_space, KCVPixelFormatType_32RGBA);
          new_image = CGBitmapContextCreateImage(context_ref)

          CGContextRelease(context_ref)

          CGImageDestinationAddImage(
            dst_ref,
            new_image,
            frame_props
          )
          CMSampleBufferInvalidate(sample_buffer_ref)
          #CFRelease(sample_buffer_ref)
        end
        current_frame += 1
      end
      CGColorSpaceRelease(color_space)
      CGImageDestinationSetProperties(dst_ref, gif_props)
      CGImageDestinationFinalize(dst_ref)
      Dispatch::Queue.main.sync do
        self.gif_generation_did_finish_with_path path
      end
    end

    def gif_generation_did_finish_with_path(path)
      @meta_controller.gif_generation_done(path)
    end

    def meta_controller_did_finish_successfully(sender)
      @capture_controller.delegate.capture_did_finish(@capture_controller, @meta_controller.current)
    end
    # }}}

    def load_generate
      @current_state = CMGEditorManager::EDITORSTATE_GENERATE

      @meta_controller = CMGMetaController.alloc.init
      @meta_controller.delegate = self
      @capture_controller.presentModalViewController(@meta_controller, animated: false)
      @generate_queue = Dispatch::Queue.new('net.epic.generate')
      @generate_queue.async do
        begin
          path = self.generate_gif
        rescue => e
          alert = CMGModelessAlertView.show_alert_in_view(@meta_controller.view, "GIF Generation failed", e.message, nil, UIImage.imageNamed("images/background-alert-red.png"))
        end
      end
    end
  end
end
