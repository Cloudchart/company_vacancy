class TextsController < ApplicationController
  include BlockableController

  private

    def text_params
      blockable_params(:content)
    end

end
