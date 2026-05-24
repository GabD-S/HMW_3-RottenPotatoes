class MoviesController < ApplicationController
  ALL_RATINGS = %w[G PG PG-13 R].freeze

  def index
    @all_ratings = ALL_RATINGS
    @sort_by = params[:sort_by]

    ratings_param = params[:ratings]
    @selected_ratings = if ratings_param.is_a?(ActionController::Parameters) || ratings_param.is_a?(Hash)
                          ratings_param.keys.map(&:to_s)
                        else
                          @all_ratings.dup
                        end

    movies = Movie.where(rating: @selected_ratings)
    movies = movies.order(@sort_by) if %w[title release_date].include?(@sort_by)
    @movies = movies
  end

  def show
    @movie = Movie.find(params[:id])
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      redirect_to movies_path, notice: 'Filme criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @movie = Movie.find(params[:id])
  end

  def update
    @movie = Movie.find(params[:id])
    if @movie.update(movie_params)
      redirect_to movie_path(@movie), notice: 'Filme atualizado.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Movie.find(params[:id]).destroy
    redirect_to movies_path, notice: 'Filme removido.'
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
