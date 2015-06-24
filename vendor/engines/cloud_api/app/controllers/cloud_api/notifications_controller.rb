require_dependency "cloud_api/application_controller"

module CloudApi
  class NotificationsController < CloudApi::ApplicationController

    def report_content
      report = Report.new(report_content_params)

      if report.valid?
        SlackWebhooksWorker.perform_async('reported_content', current_user.id, report.attributes)

        respond_to do |format|
          format.json { render json: :ok, status: 200 }
        end
      else
        respond_to do |format|
          format.json { render json: { errors: report.errors }, status: 422 }
        end
      end
    end

  private

    def report_content_params
      params.require(:report).permit(:url, :reason)
    end

  end
end
