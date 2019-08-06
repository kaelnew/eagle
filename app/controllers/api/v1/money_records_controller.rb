class Api::V1::MoneyRecordsController < Api::V1::ApplicationController
  before_action :check_params, only: %i(create update)
  before_action :set_money_record, only: %i(update destroy)
  before_action :set_page_default_params, only: :index

  def static
    @mrs = current_user.money_records
    @income_mrs = @mrs.income
    @outgo_mrs = @mrs.outgo
    @invest_mrs = @outgo_mrs.tagged_with(:invest)
    @total_invest = @invest_mrs.sum(:amount).to_f #总的投资
    @total_invest_return = @income_mrs.tagged_with(:invest).sum(:amount).to_f #总的投资回报
    @total_houseloan = @mrs.tagged_with(:houseloan).sum(:amount).to_f # 总的已还房贷
    @total_houserent = @mrs.tagged_with(:houserent).sum(:amount).to_f #总的房租支出
  end

  def static_tag_percent
    @mrs = current_user.money_records
    @mrs = @mrs.by_subject(params[:subjects].split(Setting.params_separator)) if params[:subjects].present?
    @mrs = @mrs.start_at(params[:start_at]) if params[:start_at].present?
    @mrs = @mrs.end_at(params[:end_at]) if params[:end_at].present?
    @income_mrs = @mrs.income
    @outgo_mrs = @mrs.outgo
    @income_tags = MoneyRecord.tags(@income_mrs)
    @outgo_tags = MoneyRecord.tags(@outgo_mrs)
    field = params[:personal_share_flag] == 'true' ? :personal_share : :amount
    @totals = [Chart::Pie.new(@income_mrs.sum(field).to_f, MoneyRecord.income_flag_label(:income)).add_value_to_name,
               Chart::Pie.new(@outgo_mrs.sum(field).to_f, MoneyRecord.income_flag_label(:outgo)).add_value_to_name]

    @incomes = @income_tags.collect {|tag| Chart::Pie.new(@income_mrs.tagged_with(tag).sum(field).to_f, Setting.money_records_tags[tag]).add_value_to_name}
    @outgos = @outgo_tags.collect {|tag| Chart::Pie.new(@outgo_mrs.tagged_with(tag).sum(field).to_f, Setting.money_records_tags[tag]).add_value_to_name}
  end

  def index
    @mrs = current_user.money_records.happened_at_desc.page(params[:page]).per(params[:per])
    @invest_mrs = current_user.money_records.outgo.tagged_with(:invest)
  end

  def create
    mr = current_user.money_records.new(money_record_params)
    if mr.save
      mr.tag_list = params[:tag]
      mr.save
      render_suc
    else
      render json: {code: responses.client_error.code, msg: mr.error_msg}
    end
  end

  def update
    if @mr.update(money_record_params)
      if !params[:tag].in?(@mr.tag_list)
        @mr.tag_list = params[:tag]
        @mr.save
      end
      render_suc
    else
      render json: {code: responses.client_error.code, msg: @mr.error_msg}
    end
  end

  def destroy
    @mr.destroy!
    render_suc
  end

  def options
    @tag_options = MoneyRecord.tag_formatted_options
    @subject_options = MoneyRecord.subject_formatted_options
  end

  private

  def check_params
    return render json: {code: responses.client_error.code,
      msg: I18n.t('money_record.tag_blank_error')} if params[:tag].blank?
    params[:tag] = params[:tag].to_s
    parent_id = params[:money_record][:parent_id]
    return render_unauthorized if parent_id.present? &&
      current_user.money_records.find_by(id: parent_id).nil?
  end

  def money_record_params
    @mrp = params.require(:money_record).permit(:happened_at, :income_flag, :amount, :subject, :personal_share, :parent_id, :remark)
    if @mrp[:parent_id].present?
      parent = MoneyRecord.find_by(id: @mrp[:parent_id])
      if parent
        @mrp[:subject] = parent.subject
        @mrp[:personal_share] = parent.personal_share_ratio * @mrp[:amount].to_f
      end
    end
    @mrp
  end

  def set_money_record
    @mr = current_user.money_records.find(params[:id])
  end

end
