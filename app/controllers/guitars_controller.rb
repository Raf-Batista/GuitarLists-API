class GuitarsController < ApplicationController
  def index
    @guitars = Guitar.all
    render json: @guitars.to_json(except: [:created_at, :updated_at]), status: 200
  end

  def show
    @guitar = Guitar.find_by(id: params[:id])
    if @guitar && @guitar.user_id == params[:user_id].to_i
      render json: @guitar.to_json(except: [:created_at, :updated_at]), status: 200
    else
      render json: {errors: 'Not Found'}
    end
  end

  def create
    if verify(params[:user_id], params[:token])
      @guitar = Guitar.new(guitar_params)
      @guitar.user = User.find(params[:user_id])
      @guitar.save ? render(json: @guitar.to_json(except: [:created_at, :updated_at])) : render(json: @guitar.errors.full_messages)
    else
      render json: {errors: "You are not logged in"}
    end
  end

  def update
    if verify(params[:user_id], params[:token])
      @guitar = Guitar.find(params[:id])
      @guitar.update(guitar_params)
      @guitar.save ? render(json: @guitar) : render(json: {errors: @guitar.errors.full_messages})
    else
      render json: {errors: "You are not logged in"}
    end
  end

  def destroy
    user = User.find_by(id: params[:user_id])
    guitar = Guitar.find_by(id: params[:id])
    if user.id == guitar.user_id 
      Guitar.delete(params[:id])
      render json: {message: 'Guitar was deleted'}
    else 
      render json: {errors: 'There was an error'}
    end 
  end

  private

  def guitar_params
    params.require(:guitar).permit(:model, :spec, :price, :condition, :location)
  end
end
