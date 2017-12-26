# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).


#    Distribution Centers (add your future distribution centers in below symbol chain)

    DistributionCenters = %w[thailand singapore]

    DistributionCenters.each do |dc|
        DistributionCenter.create!(name: dc.titleize) unless
            DistributionCenter.find_by_name(dc.titleize)
    end

