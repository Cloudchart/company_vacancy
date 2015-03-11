require 'rails_helper'

RSpec.describe PostsController, type: :controller do

  describe 'GET #index' do
    it 'responds successfully with an HTTP 200 status code and renders the index template' do
      sign_in
      company = create(:company)
      get :index, company_id: company.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response).to render_template(:index)
    end
  end

  describe 'PUT #update' do
    it 'should not update post without rights' do
      sign_in(create(:user))
      company = create(:company)
      post = create(:post, owner: company)
      put :update, id: post.id, post: { title: 'New title' }
      expect(response).to have_http_status(302)
    end
  end

end
