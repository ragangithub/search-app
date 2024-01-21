class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy ]

  # GET /articles or /articles.json
  def index
  

    
      if params[:query].present?
          save_search if valid_search?
        
         @articles =  Article.where("name LIKE ?", "%#{params[:query]}%")
      else
         @articles =  Article.all
      end  
      
      if turbo_frame_request?
        render partial: "articles", locals: { articles: @articles }
      else
        render :index
      end
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to article_url(@article), notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to article_url(@article), notice: "Article was successfully updated." }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_url, notice: "Article was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:name)
    end

    
  def query_param
    params[:query]&.strip
  end

  def recent_search
    @recent_search ||= Search.order_by(current_user).first
  end
  
  def save_search
    if create_new_search?
      Search.create(query: query_param, user: current_user)
    else
      recent_search.update(query: query_param)
    end
  end
  
  def create_new_search?
    recent_search.blank? || !similarity_check(recent_search&.query, query_param)
  end

  def valid_search?
    return true if recent_search.blank?
    query_param_length = query_param.to_s.length
    !recent_search.query.include?(query_param) || recent_search.query.length < query_param_length
   
  end

  def similarity_check(str1, str2)
    levenshtein = Amatch::Levenshtein.new(str1)
    distance = levenshtein.match(str2)
    similarity = 1 - distance / [str1.length, str2.length].max.to_f
    similarity > 0.6
   
  end
end
