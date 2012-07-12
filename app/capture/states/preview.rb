module States
  module Preview

    def unload_preview(keep_new_images)
      @thumbs.hidden = false
      @autoplay = false
      #self.show_chrome
    end

    def load_preview
      @current_state = CMGEditorManager::EDITORSTATE_PREVIEW

      CMGProgressHudView.show_progress_in_view(@capture_controller.view, withTitle: "Hardcore previewing action")
      @freeze_mask = @mask_controller.apply(@mask_frame)
      @thumbs.hidden = true
      self.hide_chrome
      @current_asset = @asset
      self.render_preview
      @autoplay = true
    end

    def render_preview
      new_path = @capture_controller.current_file[0..-5]+'-filter.mov'
      File.delete new_path if File.exists? new_path
      url = NSURL.alloc.initFileURLWithPath(new_path)

      @filter_player = GPUImageMovie.alloc.initWithAsset(@current_asset)

      @filter_sourceover = GPUImageSourceOverBlendFilter.new
      @mask_picture = GPUImagePicture.alloc.initWithImage(@freeze_mask)
      @filter_player.addTarget(@filter_sourceover)
      @mask_picture.addTarget(@filter_sourceover)
      #@filter_sepia = GPUImageSepiaFilter.new
      #@filter_sourceover.addTarget(@filter_sepia)
      @filter_rotate = GPUImageRotationFilter.alloc.initWithRotation(KGPUImageRotateRight)
      #@filter_sepia.addTarget(@filter_rotate)
      @filter_sourceover.addTarget(@filter_rotate)
      @filter_writer = GPUImageMovieWriter.alloc.initWithMovieURL(url, size:CGSizeMake(480.0, 640.0))
      @filter_writer.hasAudioTrack = false
      @filter_player.enableSynchronizedEncodingUsingMovieWriter(@filter_writer)
      @filter_rotate.addTarget(@filter_writer)

      begin
      @filter_writer.startRecording
      @filter_player.startProcessing
      rescue => e
        $stderr.puts e.message
      end
      @filter_writer.setCompletionBlock(lambda do
        @filter_writer.finishRecording
        @filter_writer      = nil
        @filter_player      = nil
        @filter_sepia       = nil
        @filter_sourceover  = nil
        @mask_picture       = nil
        new_path            = @capture_controller.current_file[0..-5]+'-filter.mov'
        @save_button.hidden = false
        load_asset(new_path)
        CMGProgressHudView.hide_progress
      end)

    end
  end
end
