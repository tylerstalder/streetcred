class ParticipantsController < ApplicationController

  def index
    @participants = User.all.sort_by {|x| x.actions.try(:count)}.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @participants }
    end
  end

  def show
    @participant = User.find(params[:id])
    @active_campaigns = Campaign.active
    @completed_campaigns = Campaign.completed
    @earned_awards = @completed_campaigns.select {|x| x.requirements_met_by_individual?(@participant)}
    gon.markers = @participant.actions.all.reject{|x| x.latitude.blank? || x.longitude.blank?}.collect {|x| {type: 'Feature', geometry: {type: 'Point', coordinates: [x.longitude, x.latitude]}, properties: { title: x.user.try(:display_name), description: "#{x.action_type.try(:channel).try(:name)}<br />#{x.action_type.try(:name)}<br />#{x.created_at.strftime('%m/%d/%Y')}", 'marker-size' => 'small', 'marker-color' => '#ff502d'}}}


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @participant }
    end
  end

  def search
    @participant = User.where(email: params[:email]).first
    if @participant.blank?
      flash[:alert] = "We're sorry, but no profiles matched that email address. Please create a new account."
      redirect_to new_user_registration_path
    end
  end
end
