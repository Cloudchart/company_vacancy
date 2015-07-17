class ExtractDomainsFromExistingOrigins < ActiveRecord::Migration
  def up
    Pin.where.not(origin: nil).where.not(origin: '').each do |pin|
      if uri = pin.origin_uri
        domain = Domain.find_by(name: uri.host)
        unless domain
          domain = Domain.create(name: uri.host, status: :allowed)
          say "#{domain.name} created", true
        end
      end
    end
  end

  def down
    say 'Nothing to be done'
  end
end
