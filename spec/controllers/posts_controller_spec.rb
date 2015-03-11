require 'rails_helper'

RSpec.describe PostsController, type: :controller do

  describe 'GET #index' do
    it 'responds successfully with HTTP 200 and renders the index template' do
      sign_in
      company = create(:company)
      get :index, company_id: company.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response).to render_template(:index)
    end
  end

  describe 'PUT #update' do
    context 'when user is not authorized' do
      it 'responds with HTTP 302 (redirected)' do
        sign_in(create(:user))
        company = create(:company)
        post = create(:post, owner: company)
        put :update, id: post.id, post: { title: 'New title' }
        expect(response).to have_http_status(302)
      end
    end

    context 'when user is authorized' do
      it 'responds successfully with HTTP 200 and updates attributes' do
        company = create(:company)
        sign_in(create(:user_with_roles, owner: company))
        post = create(:post, owner: company)
        put :update, id: post.id, post: { title: 'New title' }, format: :json
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end
    end
  end

end
