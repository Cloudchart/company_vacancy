require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe 'GET #index' do
    before(:each) do
      @company = create(:company)
    end

    it 'responds successfully with an HTTP 200 status code' do
      get :index, company_id: @company.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the index template' do
      get :index, company_id: @company.id
      expect(response).to render_template('index')
    end

    # it 'loads all of the posts into @posts' do
      # post1, post2 = Post.create!, Post.create!
      # get :index

      # expect(assigns(:posts)).to match_array([post1, post2])
    # end
  end
end
