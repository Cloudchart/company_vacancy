class ImagesController < ApplicationController
  include BlockableController

  private

    def image_params
      blockable_params(:image)
    end

end
