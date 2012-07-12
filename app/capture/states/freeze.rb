module States
  module Freeze
    def unload_freeze
      @thumbs.frame_selector_visible = false
    end

    def freeze_init

    end

    def load_freeze
      @previous_button.hidden = false
      @current_state = CMGEditorManager::EDITORSTATE_FREEZE
      @thumbs.frame_selector_visible = true
      self.load_thumbs
    end
  end
end
