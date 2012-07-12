module States
  module Mask
    def unload_mask
      @thumbs.hidden = false
      @switch_button.hidden = true
      @mask_controller.hide()
    end

    def load_mask
      @current_state = CMGEditorManager::EDITORSTATE_MASK

      @thumbs.hidden = true
      @switch_button.hidden = false
      @mask_controller.show()
      @previous_button.enabled = false
      @validate_button.enabled = false
      fetch_mask_frame
    end

    def fetch_mask_frame
      @generator = AVAssetImageGenerator.assetImageGeneratorWithAsset(@asset)
      scale = @asset.duration.timescale
      time = @thumbs.selected_frame
      @generator.maximumSize = CGSizeMake(640, 480)
      @generator.requestedTimeToleranceAfter = KCMTimeZero
      @generator.requestedTimeToleranceBefore = KCMTimeZero
      @generator.generateCGImagesAsynchronouslyForTimes([time],completionHandler: lambda do |time, image, real_time, result, error|
        if result == AVAssetImageGeneratorSucceeded
          @mask_frame = UIImage.imageWithCGImage(image)
        end
        Dispatch::Queue.main.async do
          @previous_button.enabled = true
          @validate_button.enabled = true
        end
      end)
    end
  end
end
