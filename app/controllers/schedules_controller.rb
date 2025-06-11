class SchedulesController < ApplicationController
  def index
    schedules = Schedule.all
    @filtered_schedules = filter_schedules(schedules)
    render json: @filtered_schedules, status: :ok
  end
  
  def show
    # IDでスケジュールを検索
    @schedule = Schedule.find(params[:id])
    # レスポンスを返す
    render json: @schedule, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Schedule not found' }, status: :not_found
  end
  
  def create
    @schedule = Schedule.new(schedule_params)
    if @schedule.save
      render json: @schedule, status: :created
    else
      render json: { errors: @schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    @schedule = Schedule.find(params[:id])
    if @schedule.update(schedule_params)
      render json: @schedule, status: :ok
    else
      render json: { errors: @schedule.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Schedule not found' }, status: :not_found
  end
  
  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Schedule not found' }, status: :not_found
  end

  private

  def schedule_params
    params.require(:schedule).permit(:title, :description, :start_time, :end_time, :location, :status, :priority, :user_id, :all_day)
  end

  def filter_schedules(schedules)
    # パラメータに応じてscopeをチェーンしていく
    
    # ユーザーIDによる絞り込み
    if params[:user_id].present?
      schedules = schedules.by_user(params[:user_id])
    end

    # ステータスによる絞り込み
    if params[:status].present?
      schedules = schedules.by_status(params[:status])
    end

    # 最小優先度による絞り込み
    if params[:min_priority].present?
      schedules = schedules.by_min_priority(params[:min_priority])
    end
    
    # 最大優先度による絞り込み
    if params[:max_priority].present?
      schedules = schedules.by_max_priority(params[:max_priority])
    end

    # 期間による絞り込み (time_rangeという1つのパラメータで制御する)
    # このように1つのパラメータで複数のscopeを使い分けると、APIが使いやすくなる
    case params[:time_range]
    when 'upcoming'
      schedules = schedules.upcoming
    when 'past'
      schedules = schedules.past
    when 'today'
      schedules = schedules.today
    end

    # 日付範囲指定による絞り込み (より柔軟な検索)
    if params[:start_date].present?
      schedules = schedules.where('start_time >= ?', Date.parse(params[:start_date]).beginning_of_day)
    end
    if params[:end_date].present?
      schedules = schedules.where('end_time <= ?', Date.parse(params[:end_date]).end_of_day)
    end

    # 全てのフィルタリングが適用された最終的な結果を返す
    schedules
  end
end
