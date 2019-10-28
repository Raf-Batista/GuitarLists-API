class UsersController < ApplicationController

  def index
    @users = User.all

    render json: @users.to_json(
      include: {
        #JSON will return guitars that belong to sellers
        guitars: {
          #JSON will not return these attributes that belong to guitars
          except: [:created_at, :updated_at]
          }
        },
        #JSON will not return these attributes that belong to sellers
        except: [:created_at, :updated_at, :password_digest]
        ),
      status: 200
  end

  def show
    @user = User.find_by(id: params[:id])
    if @user
      render json: @user.to_json(
        include: {
          guitars: {
            except: [:created_at, :updated_at]
            }
          },
          except: [:created_at, :updated_at, :password_digest])
    else
        render json: {errors: 'User not found'}
    end
  end

    def create
      @user = User.new(user_params)
      if @user.save
        UserMailer.welcome(@user).deliver_now
        token = login(@user)
        render json: {email: @user.email, username: @user.username, token: token, id: @user.id}
      else
        render json: { errors: @user.errors.full_messages }
      end
    end

    def update
      @user = User.find(params[:id])
      if verify(@user.id, params[:token])
        @user.update(user_params)
        render json: @user
      else
        render json: {errors: "You are not logged in"}
      end
    end

    def destroy
      if !verify(params[:id], params[:token])
        render json: {errors: 'There was an error'} and return
      end
      if User.delete(params[:id]) != 0 # Deleting a record that doesn't exist will return a 0
        render json: {message: 'Your account has been deleted'}
      end
    end

    def message 
      if verify(params[:user][:id], params[:user][:token])
          user = User.find_by(id: params[:user][:id])
          seller = User.find_by(id: params[:seller])
          guitar = Guitar.find_by(id: params[:guitar][:id])
          UserMailer.message_user(user, params[:message], seller, guitar).deliver_now
      end
    end 

    private

    def user_params
      params.require(:user).permit(:email, :username, :password)
    end
end
