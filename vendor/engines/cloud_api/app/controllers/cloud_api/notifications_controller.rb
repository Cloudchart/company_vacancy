require_dependency "cloud_api/application_controller"

module CloudApi
  class NotificationsController < CloudApi::ApplicationController

    def report_content
      report = Report.new(report_content_params)

      if report.valid?
        if should_perform_sidekiq_worker?
          SlackWebhooksWorker.perform_async('reported_content', current_user.id, report.attributes)
        end

        render json: :ok, status: 200
      else
        render json: { errors: report.errors }, status: 422
      end
    end

    def post_to_slack
      if should_perform_sidekiq_worker?
        SlackWebhooksWorker.perform_async(params[:event_name], current_user.id,
          { request_env: request.env }.merge(params[:options])
        )
      end

      render json: :ok, status: 200
    end

  private

    def report_content_params
      params.require(:report).permit(:url, :reason)
    end

  end
end
