module States
  module Trim
    def load_trim
      @current_state = CMGEditorManager::EDITORSTATE_TRIM
      @previous_button.hidden = true
      @thumbs.handlebar_visible = true
      self.load_thumbs
    end

    def unload_trim
      @thumbs.handlebar_visible = false
      @previous_button.enabled = false
      @validate_button.enabled = false
      trim_asset
    end

    def trim_asset
      @export_session = AVAssetExportSession.alloc.initWithAsset(@asset, presetName: AVAssetExportPreset640x480)
      # FIXME: new_path shouldn't need to be an ivar
      @new_path = @capture_controller.current_file[0..-5]+'-trim.mov'
      File.delete @new_path if File.exists? @new_path
      url = NSURL.alloc.initFileURLWithPath(@new_path)
      @export_session.outputURL = url
      @export_session.outputFileType = AVFileTypeQuickTimeMovie
      start, stop = @thumbs.selected_range
      @export_session.timeRange = CMTimeRangeMake(
        CMTimeMakeWithSeconds(start, 600),
        CMTimeMakeWithSeconds(stop - start, 600),
      )
      @export_session.exportAsynchronouslyWithCompletionHandler(lambda do
        Dispatch::Queue.main.async do
          @previous_button.enabled = true
          @validate_button.enabled = true
          case @export_session.status
          when AVAssetExportSessionStatusFailed
            CMGModelessAlertView.show_alert_in_view(@capture_controller.view, "Trim failed", @export_session.error.localizedDescription, nil, UIImage.imageNamed("images/background-alert-red.png"))
          when AVAssetExportSessionStatusCancelled
            CMGModelessAlertView.show_alert_in_view(@capture_controller.view, "Trim failed", "The action was canceled", nil, UIImage.imageNamed("images/background-alert-yellow.png"))
          else
            self.load_asset(@new_path)
          end
        end
      end)
    end
  end
end
