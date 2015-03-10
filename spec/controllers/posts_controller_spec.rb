require 'rails_helper'

RSpec.describe PostsController, type: :controller do

  describe 'GET #index' do
    it 'responds successfully with an HTTP 200 status code and renders the index template' do
      allow(controller).to receive(:user_authenticated?).and_return(true)
      allow(controller).to receive(:current_user).and_return(create(:guest))
      company = create(:company)
      get :index, company_id: company.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response).to render_template(:index)
    end

  end

  # describe 'PUT #update' do
  #   it 'updates post' do
  #     # user = create(:user)
  #     user_stubbed = build_stubbed(:user)
  #     guest_stubbed = build_stubbed(:guest)
  #     Rails.logger.info("\n #{'*'*25} #{user_stubbed.inspect} #{'*'*25} \n")
  #     Rails.logger.info("\n #{'*'*25} #{guest_stubbed.inspect} #{'*'*25} \n")
  #     # allow(controller).to receive(:current_user).and_return(user)
  #     # post = create
  #     expect(controller.current_user.guest?).to eq(true)

  #   end
  # end

end
