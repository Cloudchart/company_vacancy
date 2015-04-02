require 'rails_helper'

RSpec.describe PostsController, type: :controller do

  describe 'GET #index' do
    it 'responds successfully with HTTP 200 and renders the index template' do
      sign_in(create(:user))
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
        put :update, id: post.id, post: { title: 'New title' }, format: :json
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when user is authorized' do
      it 'responds successfully with HTTP 200 and updates attributes' do
        company = create(:company)
        sign_in(create(:user_with_roles, owner: company))
        post = create(:post, owner: company)
        put :update, id: post.id, post: { title: 'New title' }, format: :json
        post.reload
        expect(response).to be_success
        expect(response).to have_http_status(200)
        expect(post.title).to eq('New title')
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not authorized' do
      it 'responds with HTTP 302 (redirected)' do
        sign_in(create(:user))
        company = create(:company)
        post :create, company_id: company.id, post: { title: 'New title' }, format: :json
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when user is authorized' do
      before(:each) do
        @company = create(:company)
        sign_in(create(:user_with_roles, owner: @company))
      end

      it 'responds successfully with HTTP 200, creates post' do
        post :create, company_id: @company.id, post: { title: 'New title' }, format: :json
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'uses existing blank post when available' do
        blank_post = create(:blank_post, owner: @company)
        post :create, company_id: @company.id, post: { title: 'New title' }, format: :json
        expect(response).to be_success
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['uuid']).to eq(blank_post.id)
      end
    end
  end

end
