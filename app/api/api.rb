# require 'grape'

class Api < Grape::API
  version 'v1', using: :header, vendor: 'ip-checker'
  format :json
  prefix :api

  # TODO: Use guids instead ids?
  resource :ips do
    # POST /ips - Add an IP address with parameters (enabled: bool, ip: ipv4/ipv6 address)
    params do
      requires :ip, type: String, desc: 'IP Address'
      requires :enabled, type: Boolean, desc: 'Enable flag'
    end
    post do
      ip = ::Ip.create(ip_address: params[:ip], enabled: params[:enabled])
      present ip, with: V1::Entities::Ip
    end

    route_param :id do
      # POST /ips/:id/enable - Enable statistics collection for IP
      post 'enable' do
        ip = ::Ip[params[:id]]
        error!({ error: 'IP not found' }, 404) unless ip
        ip.update(enabled: true)
        present ip, with: V1::Entities::Ip
      end

      # POST /ips/:id/disable - Disable statistics collection for IP
      post 'disable' do
        ip = ::Ip[params[:id]]
        error!({ error: 'IP not found' }, 404) unless ip
        ip.update(enabled: false)
        present ip, with: V1::Entities::Ip
      end

      # GET /ips/:id/stats - Get statistics for the address (time_from: datetime, time_to: datetime)
      params do
        requires :time_from, type: DateTime, desc: 'Start time for statistics'
        requires :time_to, type: DateTime, desc: 'End time for statistics'
      end
      get 'stats' do
        ip = ::Ip[params[:id]]
        error!({ error: 'IP not found' }, 404) unless ip
        result = QueryStatisticsService.call(ip_id: ip.id, time_from: params[:time_from], time_to: params[:time_to])
        error!({ error: result.failure }, 404) unless result.success?
        present result.value!, with: V1::Entities::Statistics
      end

      # DELETE /ips/:id - Disable collection and delete the address
      delete do
        ip = ::Ip[params[:id]]
        error!({ error: 'IP not found' }, 404) unless ip
        ip.destroy
        { message: 'IP deleted successfully.' }
      end
    end
  end
end